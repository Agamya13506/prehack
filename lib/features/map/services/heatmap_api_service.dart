import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/heatmap_zone.dart';

/// Fetches live heatmap zone data from a public HTTP source.
///
/// No API key or authentication required.
/// Source: project-hosted JSON on GitHub (public raw URL).
class HeatmapApiService {
  /// Primary public source — the heatmap_data.json committed to this repo.
  /// Replace with your own hosted endpoint if needed.
  static const String _primaryUrl =
      'https://raw.githubusercontent.com/Agamya13506/prehack/main/heatmap_data.json';

  /// Fallback: any other public mirror (same format).
  /// If both fail, the repository falls back to cached data.
  static const String _fallbackUrl =
      'https://raw.githubusercontent.com/WynautBhav/hj/main/heatmap_data.json';

  static const Duration _timeout = Duration(seconds: 10);

  /// Fetches heatmap data. Returns null on any failure (callers use cache).
  Future<HeatmapData?> fetchHeatmap() async {
    return await _tryFetch(_primaryUrl) ?? await _tryFetch(_fallbackUrl);
  }

  Future<HeatmapData?> _tryFetch(String url) async {
    try {
      final res = await http.get(Uri.parse(url)).timeout(_timeout);
      if (res.statusCode != 200) return null;

      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) return null;

      return HeatmapData.fromJson(decoded);
    } catch (_) {
      // Timeout, no network, bad JSON — all silently return null.
      return null;
    }
  }
}
