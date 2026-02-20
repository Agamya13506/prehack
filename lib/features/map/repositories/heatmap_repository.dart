import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/heatmap_zone.dart';
import '../services/heatmap_api_service.dart';
import '../services/heatmap_cache_service.dart';

/// Result wrapper so callers know the data source.
class HeatmapResult {
  final HeatmapData? data;
  final bool isLive;        // true = fresh from network
  final bool hasNoData;     // true = neither network nor cache worked

  const HeatmapResult({
    required this.data,
    required this.isLive,
    required this.hasNoData,
  });
}

/// Decides whether to fetch from API or fall back to cache.
/// Also exposes a [forceOffline] flag for demo/testing purposes.
class HeatmapRepository {
  final HeatmapApiService   _api;
  final HeatmapCacheService _cache;

  bool forceOffline = false; // toggled by the "Simulate Offline" switch

  HeatmapRepository({
    HeatmapApiService?   api,
    HeatmapCacheService? cache,
  })  : _api   = api   ?? HeatmapApiService(),
        _cache = cache ?? HeatmapCacheService();

  /// Returns the best available heatmap data.
  Future<HeatmapResult> getHeatmap() async {
    if (!forceOffline && await _isConnected()) {
      final live = await _api.fetchHeatmap();
      if (live != null) {
        await _cache.save(live); // persist for offline use
        return HeatmapResult(data: live, isLive: true, hasNoData: false);
      }
    }

    // Fall back to cache (offline or network call failed).
    final cached = await _cache.load();
    if (cached != null) {
      return HeatmapResult(data: cached, isLive: false, hasNoData: false);
    }

    // No data at all.
    return const HeatmapResult(data: null, isLive: false, hasNoData: true);
  }

  Future<bool> _isConnected() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}
