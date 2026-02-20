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

class _FakeCallScreenState extends State<FakeCallScreen>
    with SingleTickerProviderStateMixin {
  // Setup state
  String _callerName = 'Mom';
  int _delaySeconds = 0; // 0 = Now, 5, 15, 30
  bool _isCallActive = false;
  bool _isRinging = false;
  int _callDuration = 0;
  Timer? _callTimer;
  Timer? _delayTimer;
  final AudioService _audioService = AudioService();
  late final TextEditingController _nameCtrl;

  final _delays = [0, 5, 15, 30];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _callerName);
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('fake_caller_name') ?? 'Mom';
    setState(() {
      _callerName = name;
      _nameCtrl.text = name;
    });
  }

  Future<void> _saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fake_caller_name', name);
    setState(() => _callerName = name);
  }

  void _startFakeCall() {
    if (_delaySeconds == 0) {
      _triggerRinging();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fake call starting in $_delaySeconds seconds…'),
          duration: const Duration(seconds: 2),
        ),
      );
      _delayTimer = Timer(Duration(seconds: _delaySeconds), _triggerRinging);
    }
  }

  void _triggerRinging() {
    setState(() {
      _isCallActive = true;
      _isRinging = true;
      _callDuration = 0;
    });
    _audioService.playRingtone();
  }

  void _acceptCall() {
    _audioService.stopRingtone();
    setState(() => _isRinging = false);
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _callDuration++);
    });
  }

  void _endCall() {
    _callTimer?.cancel();
    _delayTimer?.cancel();
    _audioService.stopRingtone();
    setState(() {
      _isCallActive = false;
      _isRinging = false;
      _callDuration = 0;
    });
    Navigator.of(context).pop();
  }

  String get _formatted {
    final m = _callDuration ~/ 60;
    final s = _callDuration % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _delayTimer?.cancel();
    _audioService.stopRingtone();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCallActive) return _buildCallScreen();
    return _buildSetupScreen();
  }

  // ── Setup screen (matches mockup) ─────────────────────────────────────────
  Widget _buildSetupScreen() {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fake Call',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text('Pretend to receive a call to escape danger',
                  style: Theme.of(context).textTheme.bodyMedium),

              const SizedBox(height: 24),

              // Caller Name
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CALLER NAME',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameCtrl,
                      onChanged: _saveName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Enter caller name',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Call Delay
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CALL DELAY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: _delays.map((d) {
                        final selected = d == _delaySeconds;
                        final label = d == 0 ? 'Now' : '$d sec';
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                right: d != _delays.last ? 8 : 0),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _delaySeconds = d),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.textPrimary
                                      : AppColors.secondary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Start CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startFakeCall,
                  icon: const Icon(Icons.phone_rounded, size: 20),
                  label: const Text(
                    'Start Fake Call',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF34C759),
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tip
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                    children: [
                      TextSpan(
                          text: 'Tip: ',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      TextSpan(
                          text:
                              'Use this when you feel unsafe in a public space. The realistic call screen gives you an excuse to leave.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Active call screen ────────────────────────────────────────────────────
  Widget _buildCallScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 56,
              backgroundColor: const Color(0xFF333333),
              child: Text(
                _callerName.isNotEmpty ? _callerName[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _callerName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isRinging
                  ? 'Incoming call…'
                  : _callDuration > 0
                      ? _formatted
                      : 'Connecting…',
              style: const TextStyle(fontSize: 16, color: Colors.white54),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
              child: _isRinging
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _CallBtn(
                          icon: Icons.call_end_rounded,
                          label: 'Decline',
                          color: AppColors.sosRed,
                          onTap: _endCall,
                        ),
                        _CallBtn(
                          icon: Icons.call_rounded,
                          label: 'Accept',
                          color: AppColors.safeGreen,
                          onTap: _acceptCall,
                        ),
                      ],
                    )
                  : Center(
                      child: _CallBtn(
                        icon: Icons.call_end_rounded,
                        label: 'End Call',
                        color: AppColors.sosRed,
                        onTap: _endCall,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CallBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}
