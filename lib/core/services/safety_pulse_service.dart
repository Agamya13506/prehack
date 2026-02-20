import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'contact_service.dart';
import 'location_service.dart';

class SafetyPulseService {
  static const String _enabledKey = 'safety_pulse_enabled';
  static const String _intervalKey = 'safety_pulse_interval';
  static const String _lastPulseKey = 'safety_pulse_last';
  
  Timer? _pulseTimer;
  bool _isActive = false;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final Function()? onPulseTriggered;
  
  static const int defaultIntervalMinutes = 30;

  SafetyPulseService({this.onPulseTriggered});

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
      startPulse();
    } else {
      stopPulse();
    }
  }

  Future<void> setInterval(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_intervalKey, minutes);
    
    if (_isActive) {
      stopPulse();
      startPulse();
    }
  }

  void startPulse() {
    if (_isActive) return;
    _isActive = true;
    
    _scheduleNextPulse();
  }

  void _scheduleNextPulse() async {
    final interval = await getIntervalMinutes();
    
    _pulseTimer?.cancel();
    _pulseTimer = Timer(Duration(minutes: interval), () {
      _triggerPulse();
    });
  }

  void _triggerPulse() async {
    const androidDetails = AndroidNotificationDetails(
      'safety_pulse',
      'Safety Pulse',
      channelDescription: 'Periodic safety check pulse',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const details = NotificationDetails(android: androidDetails);
    
    await _notifications.show(
      1,
      'Safety Pulse',
      'Tap to confirm you are safe. Your contacts will be notified.',
      details,
    );
    
    onPulseTriggered?.call();
    
    if (_isActive) {
      _scheduleNextPulse();
    }
  }

  Future<void> sendPulseNow() async {
    final locationService = LocationService();
    final position = await locationService.getCurrentPosition();
    final contacts = await ContactService().getContacts();
    
    String message = 'Safety Pulse: Checking in! ';
    if (position != null) {
      message += 'Location: ${locationService.getGoogleMapsLink(position.latitude, position.longitude)}';
    }
    
    final smsService = SmsService();
    await smsService.sendLocationSms(contacts, message);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastPulseKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<DateTime?> getLastPulseTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastPulseKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  void stopPulse() {
    _isActive = false;
    _pulseTimer?.cancel();
    _pulseTimer = null;
  }

  void dispose() {
    stopPulse();
  }
}
