import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/safety_pulse_service.dart';

class SafetyPulseScreen extends StatefulWidget {
  const SafetyPulseScreen({super.key});

  @override
  State<SafetyPulseScreen> createState() => _SafetyPulseScreenState();
}

class _SafetyPulseScreenState extends State<SafetyPulseScreen> {
  final SafetyPulseService _pulseService = SafetyPulseService();
  bool _isEnabled = false;
  int _intervalMinutes = 30;
  DateTime? _lastPulse;
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _pulseService.init();
    final isEnabled = await _pulseService.isEnabled();
    final interval = await _pulseService.getIntervalMinutes();
    final lastPulse = await _pulseService.getLastPulseTime();
    
    setState(() {
      _isEnabled = isEnabled;
      _intervalMinutes = interval;
      _lastPulse = lastPulse;
      _isLoading = false;
    });
  }

  Future<void> _toggleEnabled(bool value) async {
    await _pulseService.setEnabled(value);
    setState(() => _isEnabled = value);
  }

  Future<void> _updateInterval(int value) async {
    await _pulseService.setInterval(value);
    setState(() => _intervalMinutes = value);
  }

  Future<void> _sendPulseNow() async {
    setState(() => _isSending = true);
    
    await _pulseService.sendPulseNow();
    final lastPulse = await _pulseService.getLastPulseTime();
    
    setState(() {
      _lastPulse = lastPulse;
      _isSending = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Safety pulse sent to contacts!')),
      );
    }
  }

  String _formatLastPulse() {
    if (_lastPulse == null) return 'Never';
    
    final diff = DateTime.now().difference(_lastPulse!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Safety Pulse'),
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
                                ? AppColors.accent.withValues(alpha: 0.1)
                                : AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isEnabled 
                                ? Icons.favorite 
                                : Icons.favorite_border,
                            size: 48,
                            color: _isEnabled 
                                ? AppColors.accent 
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isEnabled 
                              ? 'Pulse Active'
                              : 'Pulse Inactive',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isEnabled
                              ? 'Periodic check-ins will be sent to your contacts'
                              : 'Enable to send periodic safety check-ins',
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
                    title: const Text('Enable Safety Pulse'),
                    subtitle: const Text(
                      'Send periodic check-ins to emergency contacts',
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
                          'Last Pulse',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          _formatLastPulse(),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Pulse Interval',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Send pulse every $_intervalMinutes minutes',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _intervalMinutes.toDouble(),
                    min: 15,
                    max: 120,
                    divisions: 7,
                    label: '$_intervalMinutes min',
                    activeColor: AppColors.accent,
                    onChanged: _isEnabled 
                        ? (value) => _updateInterval(value.toInt())
                        : null,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('15 min', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text('120 min', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isSending ? null : _sendPulseNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: _isSending
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Send Pulse Now'),
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
                            'When enabled, you will receive a notification to confirm safety. If you don\'t respond, your emergency contacts will be notified.',
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
    _pulseService.dispose();
    super.dispose();
  }
}
