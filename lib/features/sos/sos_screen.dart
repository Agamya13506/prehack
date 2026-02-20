import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/contact_service.dart';
import '../../core/services/location_service.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> with SingleTickerProviderStateMixin {
  bool _isActivating = false;
  int _countdown = 5;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _isActivating = true);
    HapticFeedback.heavyImpact();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
        HapticFeedback.lightImpact();
      });
      
      if (_countdown <= 0) {
        timer.cancel();
        _triggerSos();
      }
    });
  }

  void _cancelCountdown() {
    _timer?.cancel();
    setState(() {
      _isActivating = false;
      _countdown = 5;
    });
  }

  Future<void> _triggerSos() async {
    final contactService = ContactService();
    final contacts = await contactService.getContacts();
    
    if (contacts.isNotEmpty) {
      final locationService = LocationService();
      final position = await locationService.getCurrentPosition();
      String message = '🆘 I am in DANGER! My last location: ';
      
      if (position != null) {
        message += locationService.getGoogleMapsLink(
          position.latitude,
          position.longitude,
        );
      }
      
      final smsService = SmsService();
      await smsService.sendSosSms(contacts, message);
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success),
              SizedBox(width: 8),
              Text('SOS Sent'),
            ],
          ),
          content: const Text(
            'Emergency alert has been sent to your contacts with your location.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sosRed,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = 1.0 + (_pulseController.value * 0.1);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.2),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _isActivating ? '$_countdown' : 'SOS',
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(
                _isActivating 
                    ? 'SOS will be sent in $_countdown seconds'
                    : 'Hold to activate SOS',
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isActivating
                    ? 'Tap to cancel'
                    : 'Shake phone or press power 3x to trigger',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),
              if (_isActivating)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _cancelCountdown,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.sosRed,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('CANCEL'),
                  ),
                )
              else
                GestureDetector(
                  onLongPress: _startCountdown,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'HOLD (5 SECONDS)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.sosRed,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
