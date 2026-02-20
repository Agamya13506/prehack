import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BatteryAwareService {
  static const String _enabledKey = 'battery_aware_enabled';
  static const String _thresholdKey = 'battery_threshold';
  
  final Battery _battery = Battery();
  StreamSubscription? _batterySubscription;
  final Function(int)? onLowBattery;
  final Function()? onCriticalBattery;
  
  static const int defaultThreshold = 20;
  static const int criticalThreshold = 10;

  BatteryAwareService({this.onLowBattery, this.onCriticalBattery});

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  Future<int> getThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_thresholdKey) ?? defaultThreshold;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
    
    if (enabled) {
      startMonitoring();
    } else {
      stopMonitoring();
    }
  }

  Future<void> setThreshold(int threshold) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_thresholdKey, threshold);
  }

  Future<int> getBatteryLevel() async {
    return await _battery.batteryLevel;
  }

  Future<BatteryState> getBatteryState() async {
    return await _battery.batteryState;
  }

  void startMonitoring() {
    _batterySubscription = _battery.onBatteryStateChanged.listen((state) {
      _checkBatteryState(state);
    });
    
    _checkBatteryState(BatteryState.unknown);
  }

  void _checkBatteryState(BatteryState state) async {
    final level = await getBatteryLevel();
    final threshold = await getThreshold();
    
    if (level <= criticalThreshold || state == BatteryState.discharging) {
      onCriticalBattery?.call();
    } else if (level <= threshold) {
      onLowBattery?.call(level);
    }
  }

  void stopMonitoring() {
    _batterySubscription?.cancel();
    _batterySubscription = null;
  }

  void dispose() {
    stopMonitoring();
  }
}
