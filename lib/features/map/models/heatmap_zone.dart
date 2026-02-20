import 'package:flutter/material.dart';

/// A single danger zone on the heatmap.
class HeatmapZone {
  final String id;
  final double latitude;
  final double longitude;
  final double intensity; // 0.0 – 1.0
  final String category;  // "harassment", "theft", "assault", etc.

  const HeatmapZone({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.intensity,
    required this.category,
  });

  factory HeatmapZone.fromJson(Map<String, dynamic> json) {
    return HeatmapZone(
      id:        json['id']        as String,
      latitude:  (json['lat']      as num).toDouble(),
      longitude: (json['lng']      as num).toDouble(),
      intensity: (json['intensity'] as num).toDouble().clamp(0.0, 1.0),
      category:  json['category']  as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':        id,
    'lat':       latitude,
    'lng':       longitude,
    'intensity': intensity,
    'category':  category,
  };

  /// Red for high risk (>0.6), orange for medium, amber for low.
  Color get riskColor {
    if (intensity > 0.6) return Colors.red;
    if (intensity > 0.35) return Colors.orange;
    return Colors.amber;
  }

  /// Circle radius in metres — scales with intensity (200–600 m).
  double get radiusMetres => 200 + (intensity * 400);
}

/// Top-level heatmap response from the API.
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
      version:   json['version']    as String? ?? '0.0',
      updatedOn: json['updated_on'] as String? ?? '',
      zones:     rawZones
          .map((z) => HeatmapZone.fromJson(z as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'version':    version,
    'updated_on': updatedOn,
    'zones':      zones.map((z) => z.toJson()).toList(),
  };
}
