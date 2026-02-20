import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SafeArrivalService {
  static const String _enabledKey = 'safe_arrival_enabled';
  static const String _destinationLatKey = 'safe_arrival_dest_lat';
  static const String _destinationLngKey = 'safe_arrival_dest_lng';
  static const String _activeKey = 'safe_arrival_active';
  
  StreamSubscription? _locationSubscription;
  bool _isActive = false;
  final Function()? onSafeArrival;
  final Function()? onArrivalTimeout;
  
  static const double arrivalRadiusMeters = 100;
  static const int timeoutMinutes = 60;

  SafeArrivalService({this.onSafeArrival, this.onArrivalTimeout});

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  Future<bool> isActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_activeKey) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
  }

  Future<void> startMonitoring(double destLat, double destLng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_activeKey, true);
    await prefs.setDouble(_destinationLatKey, destLat);
    await prefs.setDouble(_destinationLngKey, destLng);
    
    _isActive = true;
    _startLocationCheck();
  }

  void _startLocationCheck() {
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) {
      _checkArrival(position);
    });
  }

  void _checkArrival(Position position) async {
    if (!_isActive) return;
    
    final prefs = await SharedPreferences.getInstance();
    final destLat = prefs.getDouble(_destinationLatKey);
    final destLng = prefs.getDouble(_destinationLngKey);
    
    if (destLat == null || destLng == null) return;
    
    final distance = Geolocator.distanceBetween(
      position.latitude, position.longitude,
      destLat, destLng,
    );
    
    if (distance <= arrivalRadiusMeters) {
      await confirmSafeArrival();
    }
  }

  Future<void> confirmSafeArrival() async {
    _isActive = false;
    _locationSubscription?.cancel();
    _locationSubscription = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_activeKey, false);
    await prefs.remove(_destinationLatKey);
    await prefs.remove(_destinationLngKey);
    
    onSafeArrival?.call();
  }

  Future<void> cancelMonitoring() async {
    _isActive = false;
    _locationSubscription?.cancel();
    _locationSubscription = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_activeKey, false);
    await prefs.remove(_destinationLatKey);
    await prefs.remove(_destinationLngKey);
  }

  void dispose() {
    _locationSubscription?.cancel();
  }
}
