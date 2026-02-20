import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ShakeSensitivity { low, medium, high }

class ShakeService {
  static const String _sensitivityKey = 'shake_sensitivity';
  
  StreamSubscription? _accelerometerSubscription;
  final List<DateTime> _shakeTimestamps = [];
  Function()? onShakeDetected;
  
  static const int _requiredShakes = 3;
  static const Duration _shakeWindow = Duration(seconds: 2);
  static const Duration _debounceTime = Duration(milliseconds: 500);
  
  static const Map<ShakeSensitivity, double> _thresholds = {
    ShakeSensitivity.low: 15.0,
    ShakeSensitivity.medium: 12.0,
    ShakeSensitivity.high: 9.0,
  };

  ShakeSensitivity _currentSensitivity = ShakeSensitivity.medium;

  ShakeService({this.onShakeDetected});

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final sensitivityStr = prefs.getString(_sensitivityKey);
    _currentSensitivity = ShakeSensitivity.values.firstWhere(
      (s) => s.name == sensitivityStr,
      orElse: () => ShakeSensitivity.medium,
    );
  }

  Future<void> setSensitivity(ShakeSensitivity sensitivity) async {
    _currentSensitivity = sensitivity;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sensitivityKey, sensitivity.name);
  }

  ShakeSensitivity get sensitivity => _currentSensitivity;

  void startListening() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      final magnitude = sqrt(
        event.x * event.x + 
        event.y * event.y + 
        event.z * event.z
      );
      
      final threshold = _thresholds[_currentSensitivity]!;
      
      if (magnitude > threshold) {
        _onShake();
      }
    });
  }

  void _onShake() {
    final now = DateTime.now();
    
    if (_shakeTimestamps.isNotEmpty) {
      final lastShake = _shakeTimestamps.last;
      if (now.difference(lastShake) < _debounceTime) {
        return;
      }
    }
    
    _shakeTimestamps.add(now);
    
    _shakeTimestamps.removeWhere((t) => 
      now.difference(t) > _shakeWindow
    );
    
    if (_shakeTimestamps.length >= _requiredShakes) {
      _shakeTimestamps.clear();
      onShakeDetected?.call();
    }
  }

  void stopListening() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }

  void dispose() {
    stopListening();
  }
}
