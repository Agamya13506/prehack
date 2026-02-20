import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/constants/app_colors.dart';
import '../models/heatmap_zone.dart';
import '../repositories/heatmap_repository.dart';

/// Full-screen OSM map with informational heatmap overlay.
///
/// — Awareness-only. No SOS, alerts, or triggers.
/// — Renders only zones within [_radiusMetres] of the user.
/// — Never crashes from missing or corrupt data.
class AreaSafetyMapScreen extends StatefulWidget {
  const AreaSafetyMapScreen({super.key});

  @override
  State<AreaSafetyMapScreen> createState() => _AreaSafetyMapScreenState();
}

class _AreaSafetyMapScreenState extends State<AreaSafetyMapScreen> {
  // ── Constants ─────────────────────────────────────────────────────────────
  static const double _radiusMetres     = 3000;   // only show zones within 3 km
  static const double _defaultLat       = 28.6139; // New Delhi fallback
  static const double _defaultLng       = 77.2090;

  // ── Dependencies ──────────────────────────────────────────────────────────
  final HeatmapRepository _repo          = HeatmapRepository();
  final MapController     _mapController = MapController();

  // ── State ─────────────────────────────────────────────────────────────────
  HeatmapData? _heatmapData;
  LatLng       _userLocation = const LatLng(_defaultLat, _defaultLng);
  bool         _loading      = true;
  bool         _hasNoData    = false;
  bool         _forceOffline = false;
  bool         _locationReady = false;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  @override
  void initState() {
    super.initState();
    // Run location + heatmap fetch in parallel.
    _init();
    // Auto-refresh heatmap when device goes online.
    _connectivitySub = Connectivity().onConnectivityChanged.listen(_onConnectivityChange);
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  // ── Bootstrap ─────────────────────────────────────────────────────────────

  Future<void> _init() async {
    await Future.wait([_getLocation(), _loadHeatmap()]);
  }

  void _onConnectivityChange(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    if (online && !_forceOffline && mounted) _loadHeatmap();
  }

  /// Gets GPS fix; silently falls back to [_defaultLat/Lng] on any error.
  Future<void> _getLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      if (!mounted) return;
      setState(() {
        _userLocation  = LatLng(pos.latitude, pos.longitude);
        _locationReady = true;
      });
      // Pan map to user once location is known.
      _mapController.move(_userLocation, 14);
    } catch (_) {
      // GPS unavailable — default coords are already set.
    }
  }

  /// Fetches heatmap data; never throws.
  Future<void> _loadHeatmap() async {
    if (!mounted) return;
    setState(() => _loading = true);

    _repo.forceOffline = _forceOffline;
    final result = await _repo.getHeatmap();

    if (!mounted) return;
    setState(() {
      _heatmapData = result.data;
      _hasNoData   = result.hasNoData;
      _loading     = false;
    });

    // Non-blocking status message.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || result.hasNoData) return;
      _showSnackbar(
        result.isLive
            ? '✅  Live safety data updated'
            : '📦  Using last known safety data',
        result.isLive ? AppColors.safeGreen : AppColors.warning,
      );
    });
  }

  void _showSnackbar(String msg, Color bg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(msg,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500)),
        backgroundColor: bg,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final nearZones = _zonesInRadius();

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Stack(
        children: [
          // ── OSM Map (no API key) ─────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation,
              initialZoom: 14,
              minZoom: 5,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.medusa.safetyapp',
                // No errorImage — silently shows blank when offline.
              ),

              // 3 km radius boundary ring (informational)
              CircleLayer(circles: [
                CircleMarker(
                  point: _userLocation,
                  radius: _radiusMetres,
                  useRadiusInMeter: true,
                  color: AppColors.accent.withAlpha(15),
                  borderColor: AppColors.accent.withAlpha(80),
                  borderStrokeWidth: 1.0,
                ),
              ]),

              // Heatmap circles — only zones within 3 km
              if (nearZones.isNotEmpty)
                CircleLayer(circles: _buildHeatCircles(nearZones)),

              // User location marker — always shown
              MarkerLayer(
                markers: [
                  Marker(
                    point: _userLocation,
                    width: 60,
                    height: 60,
                    child: _UserMarker(ready: _locationReady),
                  ),
                ],
              ),
            ],
          ),

          // ── Top bar ──────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopBar(
                    nearZoneCount: nearZones.length,
                    onRefresh: _loadHeatmap,
                    onBack: () => Navigator.pop(context),
                    isLoading: _loading,
                  ),
                  const SizedBox(height: 8),
                  if (_hasNoData) const _NoDataBanner(),
                ],
              ),
            ),
          ),

          // ── Thin loading bar (non-blocking) ──────────────────────────────
          if (_loading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 3,
                color: AppColors.accent,
                backgroundColor: Colors.transparent,
              ),
            ),

          // ── Bottom info panel ─────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomPanel(
              forceOffline: _forceOffline,
              updatedOn: _heatmapData?.updatedOn ?? '',
              nearCount: nearZones.length,
              totalCount: _heatmapData?.zones.length ?? 0,
              onOfflineToggle: (val) {
                setState(() => _forceOffline = val);
                _loadHeatmap();
              },
              onCenterUser: () => _mapController.move(_userLocation, 14),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Zones within [_radiusMetres] of user. Returns [] if no data.
  List<HeatmapZone> _zonesInRadius() {
    return _heatmapData?.zonesNear(_userLocation, _radiusMetres) ?? [];
  }

  List<CircleMarker> _buildHeatCircles(List<HeatmapZone> zones) {
    return zones.map((zone) => CircleMarker(
      point: LatLng(zone.latitude, zone.longitude),
      radius: zone.radiusMetres,
      useRadiusInMeter: true,
      color: zone.riskColor.withAlpha((zone.intensity * 130).round()),
      borderColor: zone.riskColor.withAlpha(200),
      borderStrokeWidth: 1.5,
    )).toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final int nearZoneCount;
  final VoidCallback onRefresh;
  final VoidCallback onBack;
  final bool isLoading;

  const _TopBar({
    required this.nearZoneCount,
    required this.onRefresh,
    required this.onBack,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.map_outlined, color: AppColors.accent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Area Safety Map',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                Text(
                  '$nearZoneCount risk zones within 3 km',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          // Manual refresh button
          GestureDetector(
            onTap: isLoading ? null : onRefresh,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isLoading
                    ? AppColors.divider
                    : AppColors.accentLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: isLoading ? AppColors.textSecondary : AppColors.accent,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoDataBanner extends StatelessWidget {
  const _NoDataBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withAlpha(80)),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_off_rounded, color: AppColors.warning, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No safety data available · Map still works offline',
              style: TextStyle(fontSize: 12, color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  final bool forceOffline;
  final String updatedOn;
  final int nearCount;
  final int totalCount;
  final ValueChanged<bool> onOfflineToggle;
  final VoidCallback onCenterUser;

  const _BottomPanel({
    required this.forceOffline,
    required this.updatedOn,
    required this.nearCount,
    required this.totalCount,
    required this.onOfflineToggle,
    required this.onCenterUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Legend row
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _LegendDot(color: Colors.red,    label: 'High risk'),
              _LegendDot(color: Colors.orange, label: 'Medium risk'),
              _LegendDot(color: Colors.amber,  label: 'Low risk'),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Stats + centre-user
          Row(
            children: [
              _StatChip(
                icon: Icons.location_on_rounded,
                label: '$nearCount within 3 km',
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              if (updatedOn.isNotEmpty)
                _StatChip(
                  icon: Icons.update_rounded,
                  label: updatedOn,
                  color: AppColors.textSecondary,
                ),
              const Spacer(),
              GestureDetector(
                onTap: onCenterUser,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.my_location_rounded,
                      color: AppColors.accent, size: 20),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Simulate offline toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: forceOffline
                    ? AppColors.warning.withAlpha(100)
                    : AppColors.divider,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  size: 18,
                  color: forceOffline
                      ? AppColors.warning
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Simulate Offline Mode',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary),
                      ),
                      Text(
                        'Force cached data only',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: forceOffline,
                  onChanged: onOfflineToggle,
                  activeColor: AppColors.warning,
                ),
              ],
            ),
          ),

          // Disclaimer
          const SizedBox(height: 10),
          const Text(
            'ℹ️  This map is for awareness only and does not trigger any alerts.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

/// Animated user location dot — purple when GPS ready, orange while waiting.
class _UserMarker extends StatelessWidget {
  final bool ready;
  const _UserMarker({required this.ready});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accent.withAlpha(35),
          ),
        ),
        Container(
          width: 18, height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ready ? AppColors.accent : AppColors.warning,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: (ready ? AppColors.accent : AppColors.warning)
                    .withAlpha(70),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
