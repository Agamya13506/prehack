import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/wrong_pin_capture_service.dart';

class WrongPinCaptureScreen extends StatefulWidget {
  const WrongPinCaptureScreen({super.key});

  @override
  State<WrongPinCaptureScreen> createState() => _WrongPinCaptureScreenState();
}

class _WrongPinCaptureScreenState extends State<WrongPinCaptureScreen> {
  final WrongPinCaptureService _captureService = WrongPinCaptureService();
  bool _isEnabled = false;
  List<String> _capturedPhotos = [];
  int _failedAttempts = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final isEnabled = await _captureService.isEnabled();
    final attempts = await _captureService.getFailedAttempts();
    final photos = await _captureService.getCapturedPhotos();
    
    setState(() {
      _isEnabled = isEnabled;
      _failedAttempts = attempts;
      _capturedPhotos = photos;
      _isLoading = false;
    });
  }

  Future<void> _toggleEnabled(bool value) async {
    await _captureService.setEnabled(value);
    setState(() => _isEnabled = value);
    
    if (value) {
      final photos = await _captureService.getCapturedPhotos();
      setState(() => _capturedPhotos = photos);
    }
  }

  Future<void> _testCapture() async {
    final path = await _captureService.capturePhoto();
    if (path != null) {
      final photos = await _captureService.getCapturedPhotos();
      setState(() => _capturedPhotos = photos);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test photo captured!')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not capture photo')),
        );
      }
    }
  }

  Future<void> _deletePhoto(String path) async {
    await _captureService.deletePhoto(path);
    final photos = await _captureService.getCapturedPhotos();
    setState(() => _capturedPhotos = photos);
  }

  Future<void> _resetAttempts() async {
    await _captureService.resetAttempts();
    setState(() => _failedAttempts = 0);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attempt counter reset')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Wrong PIN Capture'),
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
                            color: _isEnabled 
                                ? AppColors.warning.withValues(alpha: 0.1)
                                : AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isEnabled 
                                ? Icons.camera_alt 
                                : Icons.camera_alt_outlined,
                            size: 48,
                            color: _isEnabled 
                                ? AppColors.warning 
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isEnabled 
                              ? 'Protection Active'
                              : 'Protection Disabled',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isEnabled
                              ? 'Photos will be captured on wrong PIN attempts'
                              : 'Enable to capture photos on wrong PIN',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: const Text('Enable Wrong PIN Capture'),
                    subtitle: const Text(
                      'Capture photo when wrong PIN is entered',
                    ),
                    value: _isEnabled,
                    onChanged: _toggleEnabled,
                    activeThumbColor: AppColors.accent,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Failed Attempts',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Row(
                          children: [
                            Text(
                              '$_failedAttempts',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_failedAttempts > 0)
                              TextButton(
                                onPressed: _resetAttempts,
                                child: const Text('Reset'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _testCapture,
                    icon: const Icon(Icons.camera),
                    label: const Text('Test Capture'),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Captured Photos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_capturedPhotos.isNotEmpty)
                        TextButton(
                          onPressed: () async {
                            for (final path in _capturedPhotos) {
                              await _captureService.deletePhoto(path);
                            }
                            setState(() => _capturedPhotos = []);
                          },
                          child: const Text(
                            'Delete All',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_capturedPhotos.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'No photos captured yet',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ...List.generate(_capturedPhotos.length, (index) {
                      final path = _capturedPhotos[index];
                      final file = File(path);
                      final fileName = path.split('/').last;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.divider),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: file.existsSync()
                                  ? Image.file(
                                      file,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      height: 200,
                                      color: AppColors.secondary,
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 48,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    fileName,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: AppColors.error,
                                    ),
                                    onPressed: () => _deletePhoto(path),
                                  ),
                                ],
                              ),
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
    _captureService.dispose();
    super.dispose();
  }
}
