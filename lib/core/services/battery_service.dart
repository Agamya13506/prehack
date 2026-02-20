import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'contact_service.dart';

class BatteryService {
  static const String _enabledKey = 'battery_alert_enabled';
  static const String _thresholdKey = 'battery_threshold';
  
  final Battery _battery = Battery();
  StreamSubscription? _batterySubscription;
  final Function()? onLowBattery;
  
  static const int defaultThreshold = 15;

  BatteryService({this.onLowBattery});

  Future<void> init() async {}

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

  void startMonitoring() {
    _batterySubscription = _battery.onBatteryStateChanged.listen((state) {
      if (state == BatteryState.discharging) {
        _checkBatteryLevel();
      }
    });
  }

  void stopMonitoring() {
    _batterySubscription?.cancel();
    _batterySubscription = null;
  }

  Future<void> _checkBatteryLevel() async {
    final level = await _battery.batteryLevel;
    final threshold = await getThreshold();
    final enabled = await isEnabled();
    
    if (enabled && level <= threshold) {
      await _sendLowBatteryAlert(level);
    }
  }

  Future<void> _sendLowBatteryAlert(int level) async {
    final contactService = ContactService();
    final contacts = await contactService.getContacts();
    
    if (contacts.isEmpty) return;
    
    final smsService = SmsService();
    await smsService.sendLocationSms(contacts, 'Battery critical ($level%)');
  }

  void dispose() {
    stopMonitoring();
  }
}
