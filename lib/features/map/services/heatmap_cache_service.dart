import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/heatmap_zone.dart';

/// Persists heatmap data locally using SharedPreferences.
class HeatmapCacheService {
  static const String _dataKey    = 'heatmap_json';
  static const String _versionKey = 'heatmap_version';
  static const String _timeKey    = 'heatmap_cached_at';

  /// Saves [data] to local storage.
  Future<void> save(HeatmapData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dataKey, jsonEncode(data.toJson()));
    await prefs.setString(_versionKey, data.version);
    await prefs.setInt(_timeKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Returns cached [HeatmapData], or null if nothing is stored.
  Future<HeatmapData?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_dataKey);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return HeatmapData.fromJson(json);
    } catch (_) {
      // Corrupt cache — treat as empty.
      return null;
    }
  }

  /// Returns the ISO timestamp of the last cache write, or null.
  Future<String?> lastUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_timeKey);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms).toIso8601String();
  }

  /// Wipes all cached heatmap data.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dataKey);
    await prefs.remove(_versionKey);
    await prefs.remove(_timeKey);
  }
}
