import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// A single danger zone shown on the heatmap.
/// Strictly informational — no SOS or alert linkage.
class HeatmapZone {
  final String id;
  final double latitude;
  final double longitude;
  final double intensity; // 0.0 – 1.0
  final String category;  // e.g. "harassment", "theft", "assault"

  const HeatmapZone({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.intensity,
    required this.category,
  });

  factory HeatmapZone.fromJson(Map<String, dynamic> json) {
    return HeatmapZone(
      id:        (json['id']        as Object?)?.toString() ?? 'unknown',
      latitude:  (json['lat']       as num?)?.toDouble()    ?? 0.0,
      longitude: (json['lng']       as num?)?.toDouble()    ?? 0.0,
      intensity: ((json['intensity'] as num?)?.toDouble()   ?? 0.0).clamp(0.0, 1.0),
      category:  (json['category']  as Object?)?.toString() ?? 'general',
    );
  }

  Map<String, dynamic> toJson() => {
    'id':        id,
    'lat':       latitude,
    'lng':       longitude,
    'intensity': intensity,
    'category':  category,
  };

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Returns distance in metres from [point] to this zone.
  double distanceFromMetres(LatLng point) {
    const calc = Distance();
    return calc.as(
      LengthUnit.Meter,
      point,
      LatLng(latitude, longitude),
    );
  }

  /// Red for high risk (>0.6), orange for medium, amber for low.
  Color get riskColor {
    if (intensity > 0.6) return Colors.red;
    if (intensity > 0.35) return Colors.orange;
    return Colors.amber;
  }

  /// Circle radius in metres — scales with intensity (200–600 m).
  double get radiusMetres => 200 + (intensity * 400);
}

/// Wrapper for the full heatmap API response.
class HeatmapData {
  final String version;
  final String updatedOn;
  final List<HeatmapZone> zones;

  const HeatmapData({
    required this.version,
    required this.updatedOn,
    required this.zones,
  });

  factory HeatmapData.fromJson(Map<String, dynamic> json) {
    final rawZones = (json['zones'] as List<dynamic>?) ?? [];
    return HeatmapData(
      version:   (json['version']    as Object?)?.toString() ?? '1.0',
      updatedOn: (json['updated_on'] as Object?)?.toString() ?? '',
      zones:     rawZones
          .whereType<Map<String, dynamic>>()            // skip malformed entries
          .map(HeatmapZone.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'version':    version,
    'updated_on': updatedOn,
    'zones':      zones.map((z) => z.toJson()).toList(),
  };

  /// Returns only zones within [radiusMetres] of [centre].
  List<HeatmapZone> zonesNear(LatLng centre, double radiusMetres) {
    return zones
        .where((z) => z.distanceFromMetres(centre) <= radiusMetres)
        .toList();
  }
}
