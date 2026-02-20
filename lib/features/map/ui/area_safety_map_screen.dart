import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/constants/app_colors.dart';
import 'models/heatmap_zone.dart';
import 'repositories/heatmap_repository.dart';

/// Full-screen OSM map with heatmap overlay.
/// Wired to Area Safety card on the home screen.
class AreaSafetyMapScreen extends StatefulWidget {
  const AreaSafetyMapScreen({super.key});

  @override
  State<AreaSafetyMapScreen> createState() => _AreaSafetyMapScreenState();
}

class _AreaSafetyMapScreenState extends State<AreaSafetyMapScreen> {
  // ── Dependencies ──────────────────────────────────────────────────────────
  final HeatmapRepository _repo = HeatmapRepository();
  final MapController _mapController = MapController();

  // ── State ─────────────────────────────────────────────────────────────────
  HeatmapData? _heatmapData;
  LatLng _userLocation = const LatLng(28.6139, 77.2090); // Delhi default
  bool _loading = true;
  bool _hasNoData = false;
  bool _forceOffline = false;
  bool _locationReady = false;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  @override
  void initState() {
    super.initState();
    _init();
    // Auto-refresh heatmap when connectivity returns.
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online && !_forceOffline) _loadHeatmap();
    });
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

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      if (mounted) {
        setState(() {
          _userLocation = LatLng(pos.latitude, pos.longitude);
          _locationReady = true;
        });
        _mapController.move(_userLocation, 13);
      }
    } catch (_) {
      // Use default Delhi coords if GPS fails.
    }
  }

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

    // Show appropriate snackbar without blocking UI.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (result.hasNoData) return; // banner handles this
      _showSnackbar(
        result.isLive
            ? '✅  Live safety data updated'
            : '📦  Using last known safety data',
        result.isLive ? AppColors.safeGreen : AppColors.warning,
      );
    });
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500)),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Stack(
        children: [
          // ── Map layer ────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation,
              initialZoom: 13,
              minZoom: 5,
              maxZoom: 18,
            ),
            children: [
              // OSM tile layer — no API key required
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.medusa.safetyapp',
                // Fallback: render blank tiles when offline
                errorImage: const AssetImage('assets/blank_tile.png'),
              ),

              // Heatmap circles layer
              if (_heatmapData != null)
                CircleLayer(circles: _buildHeatCircles()),

              // User location marker
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
                    zoneCount: _heatmapData?.zones.length ?? 0,
                    onRefresh: _loadHeatmap,
                    onBack: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 8),
                  // "No data" warning banner
                  if (_hasNoData) const _NoDataBanner(),
                ],
              ),
            ),
          ),

          // ── Loading overlay ───────────────────────────────────────────────
          if (_loading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 16),
                        Text('Loading safety data…'),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ── Bottom panel ─────────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomPanel(
              forceOffline: _forceOffline,
              updatedOn: _heatmapData?.updatedOn ?? '—',
              zoneCount: _heatmapData?.zones.length ?? 0,
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

  List<CircleMarker> _buildHeatCircles() {
    if (_heatmapData == null) return [];
    return _heatmapData!.zones.map((zone) {
      return CircleMarker(
        point: LatLng(zone.latitude, zone.longitude),
        radius: zone.radiusMetres,    // metres
        useRadiusInMeter: true,
        color: zone.riskColor.withAlpha((zone.intensity * 130).round()),
        borderColor: zone.riskColor.withAlpha(200),
        borderStrokeWidth: 1.5,
      );
    }).toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final int zoneCount;
  final VoidCallback onRefresh;
  final VoidCallback onBack;

  const _TopBar({
    required this.zoneCount,
    required this.onRefresh,
    required this.onBack,
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
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.shield_rounded, color: AppColors.accent, size: 20),
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
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$zoneCount risk zones identified',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRefresh,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.refresh_rounded,
                  color: AppColors.accent, size: 18),
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
          Icon(Icons.wifi_off_rounded, color: AppColors.warning, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No safety data available. Connect to internet to load risk zones.',
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
  final int zoneCount;
  final ValueChanged<bool> onOfflineToggle;
  final VoidCallback onCenterUser;

  const _BottomPanel({
    required this.forceOffline,
    required this.updatedOn,
    required this.zoneCount,
    required this.onOfflineToggle,
    required this.onCenterUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _LegendDot(color: Colors.red, label: 'High Risk'),
              _LegendDot(color: Colors.orange, label: 'Medium Risk'),
              _LegendDot(color: Colors.amber, label: 'Low Risk'),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              _StatChip(
                icon: Icons.warning_amber_rounded,
                label: '$zoneCount zones',
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              _StatChip(
                icon: Icons.update_rounded,
                label: updatedOn.isEmpty ? '—' : 'Updated $updatedOn',
                color: AppColors.textSecondary,
              ),
              const Spacer(),
              // Center on user button
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

          const SizedBox(height: 16),

          // Simulate Offline toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: forceOffline
                    ? AppColors.warning.withAlpha(120)
                    : AppColors.divider,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  size: 20,
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
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Use cached data only',
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
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
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

/// Pulsing location marker — purple dot with white border.
class _UserMarker extends StatelessWidget {
  final bool ready;
  const _UserMarker({required this.ready});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer pulse ring
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accent.withAlpha(40),
          ),
        ),
        // Inner dot
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ready ? AppColors.accent : AppColors.warning,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: (ready ? AppColors.accent : AppColors.warning)
                    .withAlpha(80),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
