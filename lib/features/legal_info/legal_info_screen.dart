import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';

class LegalInfoScreen extends StatelessWidget {
  const LegalInfoScreen({super.key});

  Future<void> _callNumber(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Legal Information'),
        backgroundColor: AppColors.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Emergency Helplines',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildHelplineTile('Women Helpline', '1091', Icons.phone),
          _buildHelplineTile('Police', '100', Icons.local_police),
          _buildHelplineTile('Emergency', '112', Icons.emergency),
          _buildHelplineTile('Nirbhaya Helpline', '181', Icons.woman),
          _buildHelplineTile('Cyber Crime', '1930', Icons.computer),
          const SizedBox(height: 32),
          const Text(
            'Your Rights',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            'Filing an FIR',
            'You can file an FIR at any police station. If refused, you can approach the Superintendent of Police or magistrate.',
          ),
          _buildInfoCard(
            'Women\'s Rights during Arrest',
            'A woman can only be arrested by a woman police officer. Medical examination must be conducted by a female doctor.',
          ),
          _buildInfoCard(
            'Domestic Violence Act',
            'You can file complaint under Domestic Violence Act. Protection officers must be notified within 3 days.',
          ),
          _buildInfoCard(
            'Cyber Crime Reporting',
            'Report cyber crimes at cybercrimepolice.gov.in or call 1930. Preserve all evidence.',
          ),
        ],
      ),
    );
  }

  Widget _buildHelplineTile(String name, String number, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.accent),
        ),
        title: Text(name),
        subtitle: Text(number),
        trailing: IconButton(
          icon: const Icon(Icons.call, color: AppColors.success),
          onPressed: () => _callNumber(number),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
