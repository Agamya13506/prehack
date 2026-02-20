import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/audio_recording_service.dart';

class AudioRecordingScreen extends StatefulWidget {
  const AudioRecordingScreen({super.key});

  @override
  State<AudioRecordingScreen> createState() => _AudioRecordingScreenState();
}

class _AudioRecordingScreenState extends State<AudioRecordingScreen> {
  final AudioRecordingService _recordingService = AudioRecordingService();
  bool _isEnabled = false;
  bool _isAutoRecord = true;
  bool _isRecording = false;
  List<String> _recordings = [];
  bool _isLoading = true;
  Timer? _durationTimer;
  Duration _recordingDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final isEnabled = await _recordingService.isEnabled();
    final isAutoRecord = await _recordingService.isAutoRecord();
    final recordings = await _recordingService.getRecordings();
    
    setState(() {
      _isEnabled = isEnabled;
      _isAutoRecord = isAutoRecord;
      _recordings = recordings;
      _isLoading = false;
    });
  }

  Future<void> _toggleEnabled(bool value) async {
    await _recordingService.setEnabled(value);
    setState(() => _isEnabled = value);
  }

  Future<void> _toggleAutoRecord(bool value) async {
    await _recordingService.setAutoRecord(value);
    setState(() => _isAutoRecord = value);
  }

  Future<void> _startRecording() async {
    final success = await _recordingService.startRecording();
    if (success) {
      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _recordingDuration += const Duration(seconds: 1);
        });
      });
    }
  }

  Future<void> _stopRecording() async {
    _durationTimer?.cancel();
    final path = await _recordingService.stopRecording();
    setState(() {
      _isRecording = false;
      _recordingDuration = Duration.zero;
    });
    if (path != null) {
      final recordings = await _recordingService.getRecordings();
      setState(() => _recordings = recordings);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording saved')),
        );
      }
    }
  }

  Future<void> _deleteRecording(String path) async {
    await _recordingService.deleteRecording(path);
    final recordings = await _recordingService.getRecordings();
    setState(() => _recordings = recordings);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Audio Recording'),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _isRecording 
                                ? AppColors.error.withValues(alpha: 0.1)
                                : AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isRecording ? Icons.mic : Icons.mic_none,
                            size: 48,
                            color: _isRecording 
                                ? AppColors.error 
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isRecording 
                              ? 'Recording in Progress'
                              : 'Manual Recording',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_isRecording) ...[
                          const SizedBox(height: 8),
                          Text(
                            _formatDuration(_recordingDuration),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isRecording)
                    ElevatedButton(
                      onPressed: _stopRecording,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: const Text('Stop Recording'),
                    )
                  else
                    ElevatedButton(
                      onPressed: _startRecording,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: const Text('Start Recording'),
                    ),
                  const SizedBox(height: 32),
                  SwitchListTile(
                    title: const Text('Enable Audio Recording'),
                    subtitle: const Text(
                      'Record audio during SOS events',
                    ),
                    value: _isEnabled,
                    onChanged: _toggleEnabled,
                    activeThumbColor: AppColors.accent,
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: const Text('Auto-Record on SOS'),
                    subtitle: const Text(
                      'Automatically start recording when SOS is triggered',
                    ),
                    value: _isAutoRecord,
                    onChanged: _isEnabled ? _toggleAutoRecord : null,
                    activeThumbColor: AppColors.accent,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recordings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_recordings.isNotEmpty)
                        TextButton(
                          onPressed: () async {
                            await _recordingService.deleteAllRecordings();
                            setState(() => _recordings = []);
                          },
                          child: const Text(
                            'Delete All',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_recordings.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'No recordings yet',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ...List.generate(_recordings.length, (index) {
                      final path = _recordings[index];
                      final fileName = path.split('/').last;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.divider),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.audio_file, 
                                color: AppColors.textSecondary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                fileName,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.error),
                              onPressed: () => _deleteRecording(path),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _recordingService.dispose();
    super.dispose();
  }
}
