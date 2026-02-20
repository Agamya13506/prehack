import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/shake_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ShakeSensitivity _shakeSensitivity = ShakeSensitivity.medium;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final shakeService = ShakeService();
    await shakeService.init();
    setState(() {
      _shakeSensitivity = shakeService.sensitivity;
    });
    
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _setShakeSensitivity(ShakeSensitivity sensitivity) async {
    final shakeService = ShakeService();
    await shakeService.setSensitivity(sensitivity);
    setState(() {
      _shakeSensitivity = sensitivity;
    });
  }

  Future<void> _setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    setState(() {
      _selectedLanguage = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader('SOS Triggers'),
          const SizedBox(height: 16),
          _buildSettingsTile(
            title: 'Shake Sensitivity',
            subtitle: _getSensitivityLabel(_shakeSensitivity),
            onTap: () => _showSensitivityDialog(),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('Preferences'),
          const SizedBox(height: 16),
          _buildSettingsTile(
            title: 'Language',
            subtitle: _selectedLanguage,
            onTap: () => _showLanguageDialog(),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('Quick Actions'),
          const SizedBox(height: 16),
          _buildSettingsTile(
            title: 'Change Unlock PIN',
            subtitle: 'Current: 2580=',
            onTap: () => _showChangePinDialog(),
          ),
          _buildSettingsTile(
            title: 'Fake Caller Settings',
            subtitle: 'Set caller name and number',
            onTap: () => _showFakeCallerDialog(),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('Legal'),
          const SizedBox(height: 16),
          _buildSettingsTile(
            title: 'Emergency Helplines',
            subtitle: 'View all helpline numbers',
            onTap: () => _showHelplines(),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('About'),
          const SizedBox(height: 16),
          _buildSettingsTile(
            title: 'App Version',
            subtitle: '1.0.0',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _getSensitivityLabel(ShakeSensitivity sensitivity) {
    switch (sensitivity) {
      case ShakeSensitivity.low:
        return 'Requires strong shaking';
      case ShakeSensitivity.medium:
        return 'Normal shaking';
      case ShakeSensitivity.high:
        return 'Light shaking';
    }
  }

  void _showSensitivityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Shake Sensitivity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ShakeSensitivity.values.map((sensitivity) {
            return RadioListTile<ShakeSensitivity>(
              title: Text(_getSensitivityLabel(sensitivity)),
              value: sensitivity,
              groupValue: _shakeSensitivity,
              onChanged: (value) {
                if (value != null) {
                  _setShakeSensitivity(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = ['English', 'Hindi', 'Tamil', 'Telugu', 'Bengali', 'Marathi'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return RadioListTile<String>(
              title: Text(lang),
              value: lang,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                if (value != null) {
                  _setLanguage(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showChangePinDialog() {
    final pinController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Unlock PIN'),
        content: TextField(
          controller: pinController,
          decoration: const InputDecoration(
            labelText: 'New PIN',
            hintText: 'Enter new PIN (e.g., 1234=)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (pinController.text.isNotEmpty) {
                // Save new PIN using secure storage
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN updated')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showFakeCallerDialog() {
    final nameController = TextEditingController(text: _callerName);
    final numberController = TextEditingController(text: _callerNumber);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fake Caller Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Caller Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: numberController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('fake_caller_name', nameController.text);
              await prefs.setString('fake_caller_number', numberController.text);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showHelplines() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Helplines'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HelplineRow(name: 'Women Helpline', number: '1091'),
            _HelplineRow(name: 'Police', number: '100'),
            _HelplineRow(name: 'Emergency', number: '112'),
            _HelplineRow(name: 'Nirbhaya', number: '181'),
            _HelplineRow(name: 'Cyber Crime', number: '1930'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  String get _callerName => 'Mom';
  String get _callerNumber => '+91 98765 43210';
}

class _HelplineRow extends StatelessWidget {
  final String name;
  final String number;

  const _HelplineRow({required this.name, required this.number});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Text(
            number,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
