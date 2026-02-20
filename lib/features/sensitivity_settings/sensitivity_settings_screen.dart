import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';

class SensitivitySettingsScreen extends StatefulWidget {
  const SensitivitySettingsScreen({super.key});

  @override
  State<SensitivitySettingsScreen> createState() => _SensitivitySettingsScreenState();
}

class _SensitivitySettingsScreenState extends State<SensitivitySettingsScreen> {
  double _shakeSensitivity = 2.5;
  double _screamThreshold = 70.0;
  double _shakeCount = 3;
  double _shakeTimeout = 2.0;
  bool _hapticFeedback = true;
  bool _audioFeedback = true;
  bool _autoActivateSos = true;
  int _sosCountdown = 5;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _shakeSensitivity = prefs.getDouble('shake_sensitivity') ?? 2.5;
      _screamThreshold = prefs.getDouble('scream_threshold') ?? 70.0;
      _shakeCount = (prefs.getInt('shake_count') ?? 3).toDouble();
      _shakeTimeout = prefs.getDouble('shake_timeout') ?? 2.0;
      _hapticFeedback = prefs.getBool('haptic_feedback') ?? true;
      _audioFeedback = prefs.getBool('audio_feedback') ?? true;
      _autoActivateSos = prefs.getBool('auto_activate_sos') ?? true;
      _sosCountdown = prefs.getInt('sos_countdown') ?? 5;
      _isLoading = false;
    });
  }

  Future<void> _saveShakeSensitivity(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('shake_sensitivity', value);
    setState(() => _shakeSensitivity = value);
  }

  Future<void> _saveScreamThreshold(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('scream_threshold', value);
    setState(() => _screamThreshold = value);
  }

  Future<void> _saveShakeCount(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('shake_count', value.toInt());
    setState(() => _shakeCount = value);
  }

  Future<void> _saveShakeTimeout(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('shake_timeout', value);
    setState(() => _shakeTimeout = value);
  }

  Future<void> _toggleHapticFeedback(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptic_feedback', value);
    setState(() => _hapticFeedback = value);
  }

  Future<void> _toggleAudioFeedback(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('audio_feedback', value);
    setState(() => _audioFeedback = value);
  }

  Future<void> _toggleAutoActivateSos(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_activate_sos', value);
    setState(() => _autoActivateSos = value);
  }

  Future<void> _saveSosCountdown(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sos_countdown', value);
    setState(() => _sosCountdown = value);
  }

  String _getShakeSensitivityLabel() {
    if (_shakeSensitivity <= 1.5) return 'Very Low';
    if (_shakeSensitivity <= 2.0) return 'Low';
    if (_shakeSensitivity <= 2.5) return 'Medium';
    if (_shakeSensitivity <= 3.5) return 'High';
    return 'Very High';
  }

  String _getScreamThresholdLabel() {
    if (_screamThreshold <= 50) return 'Very Sensitive';
    if (_screamThreshold <= 65) return 'Sensitive';
    if (_screamThreshold <= 75) return 'Medium';
    if (_screamThreshold <= 85) return 'Less Sensitive';
    return 'Least Sensitive';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Sensitivity Settings'),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShakeSection(),
                  const SizedBox(height: 24),
                  _buildScreamSection(),
                  const SizedBox(height: 24),
                  _buildSosSection(),
                  const SizedBox(height: 24),
                  _buildFeedbackSection(),
                  const SizedBox(height: 24),
                  _buildTestButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildShakeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shake Detection',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Shake Sensitivity'),
                  Text(
                    _getShakeSensitivityLabel(),
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _shakeSensitivity,
                min: 0.5,
                max: 5.0,
                divisions: 9,
                label: _getShakeSensitivityLabel(),
                activeColor: AppColors.accent,
                onChanged: _saveShakeSensitivity,
              ),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Shakes Required'),
                  Text(
                    '${_shakeCount.toInt()} shakes',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _shakeCount,
                min: 1,
                max: 10,
                divisions: 9,
                label: '${_shakeCount.toInt()} shakes',
                activeColor: AppColors.accent,
                onChanged: _saveShakeCount,
              ),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Time Window'),
                  Text(
                    '${_shakeTimeout.toInt()} seconds',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _shakeTimeout,
                min: 1,
                max: 10,
                divisions: 9,
                label: '${_shakeTimeout.toInt()} seconds',
                activeColor: AppColors.accent,
                onChanged: _saveShakeTimeout,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScreamSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scream Detection',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Scream Threshold'),
                  Text(
                    _getScreamThresholdLabel(),
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _screamThreshold,
                min: 30,
                max: 100,
                divisions: 14,
                label: '${_screamThreshold.toInt()} dB',
                activeColor: AppColors.accent,
                onChanged: _saveScreamThreshold,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lower threshold = more sensitive to quiet sounds',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SOS Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('SOS Countdown'),
                  Text(
                    '$_sosCountdown seconds',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _sosCountdown.toDouble(),
                min: 3,
                max: 15,
                divisions: 12,
                label: '$_sosCountdown seconds',
                activeColor: AppColors.sosRed,
                onChanged: (value) => _saveSosCountdown(value.toInt()),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Auto-activate SOS'),
                subtitle: const Text('Send SOS after countdown (no manual trigger needed)'),
                value: _autoActivateSos,
                onChanged: _toggleAutoActivateSos,
                activeThumbColor: AppColors.accent,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Feedback',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Haptic Feedback'),
                subtitle: const Text('Vibrate when SOS triggers'),
                value: _hapticFeedback,
                onChanged: _toggleHapticFeedback,
                activeThumbColor: AppColors.accent,
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Audio Feedback'),
                subtitle: const Text('Play sound when SOS triggers'),
                value: _audioFeedback,
                onChanged: _toggleAudioFeedback,
                activeThumbColor: AppColors.accent,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Test feature - shake your phone to trigger SOS'),
              backgroundColor: AppColors.accent,
            ),
          );
        },
        icon: const Icon(Icons.vibration),
        label: const Text('Test Shake Detection'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
