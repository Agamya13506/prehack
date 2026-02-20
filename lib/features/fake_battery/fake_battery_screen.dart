import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

class FakeBatteryScreen extends StatefulWidget {
  const FakeBatteryScreen({super.key});

  @override
  State<FakeBatteryScreen> createState() => _FakeBatteryScreenState();
}

class _FakeBatteryScreenState extends State<FakeBatteryScreen> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Fake Battery Screen'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    _isActive ? Icons.power_off : Icons.battery_alert,
                    size: 64,
                    color: _isActive ? AppColors.textSecondary : AppColors.warning,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isActive ? 'Phone Appears Off' : 'Fake Shutdown',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Show a fake shutdown screen while recording audio and tracking location underneath',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
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
                      'Triple press power button to cancel the fake screen',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (_isActive)
              ElevatedButton(
                onPressed: _deactivateFakeBattery,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('Exit Fake Screen'),
              )
            else
              ElevatedButton(
                onPressed: _activateFakeBattery,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('Activate Fake Screen'),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _activateFakeBattery() {
    setState(() => _isActive = true);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void _deactivateFakeBattery() {
    setState(() => _isActive = false);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    if (_isActive) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }
}
