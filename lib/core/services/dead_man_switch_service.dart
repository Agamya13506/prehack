import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeadManSwitchService {
  static const String _enabledKey = 'dead_man_enabled';
  static const String _intervalKey = 'dead_man_interval';
  
  Timer? _checkTimer;
  Timer? _responseTimer;
  bool _isWaitingForResponse = false;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final Function()? onTimeout;
  final Function()? onSafeCheckIn;
  
  static const int defaultIntervalMinutes = 10;
  static const int defaultResponseSeconds = 60;

  DeadManSwitchService({this.onTimeout, this.onSafeCheckIn});

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(initSettings);
  }

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  Future<int> getIntervalMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_intervalKey) ?? defaultIntervalMinutes;
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

  Future<void> setInterval(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_intervalKey, minutes);
  }

  void startMonitoring() async {
    final interval = await getIntervalMinutes();
    _checkTimer = Timer.periodic(Duration(minutes: interval), (_) {
      _triggerCheckIn();
    });
  }

  void stopMonitoring() {
    _checkTimer?.cancel();
    _responseTimer?.cancel();
    _isWaitingForResponse = false;
  }

  void _triggerCheckIn() async {
    if (_isWaitingForResponse) return;
    
    _isWaitingForResponse = true;
    
    const androidDetails = AndroidNotificationDetails(
      'dead_man_switch',
      'Safety Check',
      channelDescription: 'Periodic safety check-in',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const details = NotificationDetails(android: androidDetails);
    
    await _notifications.show(
      0,
      'Are you safe?',
      'Tap to confirm you are safe. SOS will be sent in 60 seconds.',
      details,
    );
    
    _responseTimer = Timer(const Duration(seconds: defaultResponseSeconds), () {
      if (_isWaitingForResponse) {
        onTimeout?.call();
      }
    });
  }

  void confirmSafe() {
    _isWaitingForResponse = false;
    _responseTimer?.cancel();
    onSafeCheckIn?.call();
  }

  void dispose() {
    stopMonitoring();
  }
}
