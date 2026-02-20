import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/flashlight_service.dart';

class FlashlightSosScreen extends StatefulWidget {
  const FlashlightSosScreen({super.key});

  @override
  State<FlashlightSosScreen> createState() => _FlashlightSosScreenState();
}

class _FlashlightSosScreenState extends State<FlashlightSosScreen> {
  final FlashlightService _flashlightService = FlashlightService();
  bool _isEnabled = false;
  bool _isFlashing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final isEnabled = await _flashlightService.isEnabled();
    setState(() {
      _isEnabled = isEnabled;
      _isLoading = false;
    });
  }

  Future<void> _toggleEnabled(bool value) async {
    await _flashlightService.setEnabled(value);
    setState(() => _isEnabled = value);
  }

  void _toggleFlashing() {
    if (_isFlashing) {
      _flashlightService.stopSos();
      setState(() => _isFlashing = false);
    } else {
      _flashlightService.startSos();
      setState(() => _isFlashing = true);
    }
  }

  @override
  void dispose() {
    if (_isFlashing) {
      _flashlightService.stopSos();
    }
    _flashlightService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Flashlight SOS'),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: _isFlashing 
                          ? AppColors.sosRed.withValues(alpha: 0.2)
                          : AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isFlashing ? Icons.flashlight_on : Icons.flashlight_off,
                      size: 80,
                      color: _isFlashing ? AppColors.sosRed : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isFlashing ? 'SOS Signal Active' : 'Flashlight SOS',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isFlashing
                        ? 'Flashlight is flashing SOS signal'
                        : 'Tap to start SOS signal',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: _toggleFlashing,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: _isFlashing ? AppColors.sosRed : AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isFlashing ? Icons.stop : Icons.play_arrow,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SwitchListTile(
                    title: const Text('Enable Flashlight SOS'),
                    subtitle: const Text('Quick access from notification'),
                    value: _isEnabled,
                    onChanged: _toggleEnabled,
                    activeThumbColor: AppColors.accent,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.textSecondary),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'The flashlight will flash SOS signal (... --- ...) to attract attention in emergencies.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
