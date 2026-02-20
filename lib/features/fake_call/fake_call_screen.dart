import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeCallScreen extends StatefulWidget {
  const FakeCallScreen({super.key});

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  bool _isRinging = false;
  String _callerName = 'Mom';
  String _callerNumber = '+91 98765 43210';
  Timer? _callTimer;
  int _callDuration = 0;
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _loadCallerInfo();
  }

  Future<void> _loadCallerInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _callerName = prefs.getString('fake_caller_name') ?? 'Mom';
      _callerNumber = prefs.getString('fake_caller_number') ?? '+91 98765 43210';
    });
  }

  void _startFakeCall() {
    setState(() {
      _isRinging = true;
      _callDuration = 0;
    });
    _audioService.playRingtone();
    
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration++;
      });
    });
  }

  void _endCall() {
    _callTimer?.cancel();
    _audioService.stopRingtone();
    Navigator.pop(context);
  }

  void _acceptCall() {
    _audioService.stopRingtone();
    setState(() {
      _isRinging = false;
    });
  }

  String get _formattedDuration {
    final minutes = _callDuration ~/ 60;
    final seconds = _callDuration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _audioService.stopRingtone();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondary,
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _callerName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _callerNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (!_isRinging) ...[
                      const SizedBox(height: 8),
                      Text(
                        _callDuration > 0 ? _formattedDuration : 'Incoming call...',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (!_isRinging && _callDuration > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCallButton(
                      icon: Icons.mic_off,
                      label: 'Mute',
                      onTap: () {},
                    ),
                    _buildCallButton(
                      icon: Icons.dialpad,
                      label: 'Keypad',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (_isRinging) ...[
                    _buildCallActionButton(
                      icon: Icons.call_end,
                      label: 'Decline',
                      color: AppColors.error,
                      onTap: _endCall,
                    ),
                    _buildCallActionButton(
                      icon: Icons.call,
                      label: 'Accept',
                      color: AppColors.success,
                      onTap: _acceptCall,
                    ),
                  ] else ...[
                    if (_callDuration == 0)
                      ElevatedButton(
                        onPressed: _startFakeCall,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                        ),
                        child: const Text('Start Fake Call'),
                      )
                    else
                      ElevatedButton(
                        onPressed: _endCall,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                        ),
                        child: const Text('End Call'),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary,
            ),
            child: Icon(icon, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: Icon(icon, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
