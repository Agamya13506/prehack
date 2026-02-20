import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'location_service.dart';

class EvidenceItem {
  final String id;
  final DateTime timestamp;
  final String? audioPath;
  final String? photoPath;
  final String? gpsLog;

  EvidenceItem({
    required this.id,
    required this.timestamp,
    this.audioPath,
    this.photoPath,
    this.gpsLog,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'audioPath': audioPath,
    'photoPath': photoPath,
    'gpsLog': gpsLog,
  };

  factory EvidenceItem.fromJson(Map<String, dynamic> json) => EvidenceItem(
    id: json['id'],
    timestamp: DateTime.parse(json['timestamp']),
    audioPath: json['audioPath'],
    photoPath: json['photoPath'],
    gpsLog: json['gpsLog'],
  );
}

class EvidenceLockerService {
  static const String _evidenceKey = 'evidence_items';
  final LocationService _locationService = LocationService();

  Future<String> get _evidenceDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final evidenceDir = Directory('${appDir.path}/saheli_evidence');
    if (!await evidenceDir.exists()) {
      await evidenceDir.create(recursive: true);
    }
    return evidenceDir.path;
  }

  Future<List<EvidenceItem>> getEvidenceList() async {
    final prefs = await SharedPreferences.getInstance();
    final evidenceJson = prefs.getStringList(_evidenceKey) ?? [];
    return evidenceJson.map((e) => 
      EvidenceItem.fromJson(Map<String, dynamic>.from(
        Uri.splitQueryString(e).map((k, v) => MapEntry(k, v))
      ))
    ).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<EvidenceItem> captureEvidence() async {
    await _evidenceDirectory;
    final timestamp = DateTime.now();
    final id = timestamp.millisecondsSinceEpoch.toString();
    
    final position = await _locationService.getCurrentPosition();
    String? gpsLog;
    if (position != null) {
      gpsLog = '${position.latitude},${position.longitude}';
    }

    final evidence = EvidenceItem(
      id: id,
      timestamp: timestamp,
      gpsLog: gpsLog,
    );

    await _saveEvidence(evidence);
    return evidence;
  }

  Future<void> _saveEvidence(EvidenceItem evidence) async {
    final prefs = await SharedPreferences.getInstance();
    final evidenceList = await getEvidenceList();
    evidenceList.insert(0, evidence);
    
    final evidenceJson = evidenceList.map((e) => 
      Uri(queryParameters: e.toJson()).query
    ).toList();
    
    await prefs.setStringList(_evidenceKey, evidenceJson);
  }

  Future<void> deleteEvidence(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final evidenceList = await getEvidenceList();
    evidenceList.removeWhere((e) => e.id == id);
    
    final evidenceJson = evidenceList.map((e) => 
      Uri(queryParameters: e.toJson()).query
    ).toList();
    
    await prefs.setStringList(_evidenceKey, evidenceJson);
  }

  Future<void> clearAllEvidence() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_evidenceKey);
    
    final dir = await _evidenceDirectory;
    final evidenceDir = Directory(dir);
    if (await evidenceDir.exists()) {
      await evidenceDir.delete(recursive: true);
    }
  }
}
