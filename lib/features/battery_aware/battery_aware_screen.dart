import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/battery_aware_service.dart';

class BatteryAwareScreen extends StatefulWidget {
  const BatteryAwareScreen({super.key});

  @override
  State<BatteryAwareScreen> createState() => _BatteryAwareScreenState();
}

class _BatteryAwareScreenState extends State<BatteryAwareScreen> {
  final BatteryAwareService _batteryService = BatteryAwareService();
  bool _isEnabled = false;
  int _threshold = 20;
  int _currentBattery = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final isEnabled = await _batteryService.isEnabled();
    final threshold = await _batteryService.getThreshold();
    final battery = await _batteryService.getBatteryLevel();
    
    setState(() {
      _isEnabled = isEnabled;
      _threshold = threshold;
      _currentBattery = battery;
      _isLoading = false;
    });
  }

  Future<void> _toggleEnabled(bool value) async {
    await _batteryService.setEnabled(value);
    setState(() => _isEnabled = value);
  }

  Future<void> _updateThreshold(int value) async {
    await _batteryService.setThreshold(value);
    setState(() => _threshold = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Battery-Aware SOS'),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _currentBattery > 20 
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.error.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _currentBattery > 20 
                                ? Icons.battery_std 
                                : Icons.battery_alert,
                            size: 40,
                            color: _currentBattery > 20 
                                ? AppColors.success 
                                : AppColors.error,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Battery',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '$_currentBattery%',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SwitchListTile(
                    title: const Text('Enable Battery-Aware SOS'),
                    subtitle: const Text(
                      'Automatically send SOS when battery is low',
                    ),
                    value: _isEnabled,
                    onChanged: _toggleEnabled,
                    activeThumbColor: AppColors.accent,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Low Battery Threshold',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Send SOS when battery drops below $_threshold%',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _threshold.toDouble(),
                    min: 5,
                    max: 50,
                    divisions: 9,
                    label: '$_threshold%',
                    activeColor: AppColors.accent,
                    onChanged: _isEnabled 
                        ? (value) => _updateThreshold(value.toInt())
                        : null,
                  ),
                  const SizedBox(height: 24),
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
                            'When battery drops below threshold, emergency contacts will be notified automatically',
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

  @override
  void dispose() {
    _batteryService.dispose();
    super.dispose();
  }
}
