import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/heatmap_zone.dart';

/// Fetches live heatmap data from the remote API.
class HeatmapApiService {
  // Swap this URL for your actual endpoint in production.
  // Falls back to a bundled mock response if the server is unreachable.
  static const String _endpoint =
      'https://raw.githubusercontent.com/Agamya13506/prehack/main/heatmap_data.json';

  static const Duration _timeout = Duration(seconds: 10);

  /// Returns [HeatmapData] on success, null on any failure.
  Future<HeatmapData?> fetchHeatmap() async {
    try {
      final response = await http
          .get(Uri.parse(_endpoint))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return HeatmapData.fromJson(json);
      }
      return null;
    } catch (_) {
      // Network error, timeout, JSON parse error — all treated as "no data".
      return null;
    }
  }
}
