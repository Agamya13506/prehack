import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/journey_service.dart';

class JourneyModeScreen extends StatefulWidget {
  const JourneyModeScreen({super.key});

  @override
  State<JourneyModeScreen> createState() => _JourneyModeScreenState();
}

class _JourneyModeScreenState extends State<JourneyModeScreen> {
  final JourneyModeService _journeyService = JourneyModeService();
  bool _isJourneyActive = false;

  @override
  void initState() {
    super.initState();
    _checkJourneyStatus();
  }

  Future<void> _checkJourneyStatus() async {
    final isActive = await _journeyService.isEnabled();
    setState(() => _isJourneyActive = isActive);
  }

  Future<void> _startJourney() async {
    await _journeyService.startJourney();
    setState(() => _isJourneyActive = true);
  }

  Future<void> _stopJourney() async {
    await _journeyService.stopJourney();
    setState(() => _isJourneyActive = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Journey Mode'),
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
                    _isJourneyActive ? Icons.directions_run : Icons.directions_walk,
                    size: 64,
                    color: _isJourneyActive ? AppColors.success : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isJourneyActive ? 'Journey in Progress' : 'Start Journey',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isJourneyActive 
                        ? 'Monitoring your route for safety'
                        : 'Track your journey and get safe arrival notification',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (_isJourneyActive)
              ElevatedButton(
                onPressed: _stopJourney,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('End Journey'),
              )
            else
              ElevatedButton(
                onPressed: _startJourney,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('Start Journey'),
              ),
          ],
        ),
      ),
    );
  }
}
