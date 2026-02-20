import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EvidenceLockerScreen extends StatelessWidget {
  const EvidenceLockerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Evidence Locker'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline),
            onPressed: () {
              // Show biometric lock
              _showBiometricPrompt(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary,
                  border: Border.all(color: AppColors.divider),
                ),
                child: const Icon(
                  Icons.folder_outlined,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Evidence Yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Evidence from SOS events will be stored here',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () => _showInfoDialog(context),
                icon: const Icon(Icons.info_outline),
                label: const Text('What is Evidence Locker?'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBiometricPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Biometric Lock'),
        content: const Text(
          'Use fingerprint or face ID to unlock the Evidence Locker.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Biometric authentication required')),
              );
            },
            child: const Text('Authenticate'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Evidence Locker'),
        content: const Text(
          'Evidence Locker automatically captures:\n\n'
          '• Audio recordings\n'
          '• Location data\n'
          '• Timestamps\n'
          '• Camera photos\n\n'
          'All evidence is securely stored and can be used for legal purposes.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
