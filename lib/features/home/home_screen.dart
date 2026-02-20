import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/contact_service.dart';
import '../sos/sos_screen.dart';
import '../fake_call/fake_call_screen.dart';
import '../settings/settings_screen.dart';
import '../evidence_locker/evidence_locker_screen.dart';
import '../journey_mode/journey_mode_screen.dart';
import '../legal_info/legal_info_screen.dart';
import '../pdf_generator/pdf_generator_screen.dart';
import '../guardian_mode/guardian_mode_screen.dart';
import '../voice_read/voice_read_screen.dart';
import '../battery_aware/battery_aware_screen.dart';
import '../audio_recording/audio_recording_screen.dart';
import '../safe_arrival/safe_arrival_screen.dart';
import '../wrong_pin_capture/wrong_pin_capture_screen.dart';
import '../safety_pulse/safety_pulse_screen.dart';
import '../dead_man_switch/dead_man_switch_screen.dart';
import '../scream_detection/scream_detection_screen.dart';
import '../fake_battery/fake_battery_screen.dart';
import '../flashlight_sos/flashlight_sos_screen.dart';
import '../smart_contact_priority/smart_contact_priority_screen.dart';
import '../personalized_sos_messages/personalized_sos_messages_screen.dart';
import '../app_lock_data_wipe/app_lock_data_wipe_screen.dart';
import '../sensitivity_settings/sensitivity_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const HomeContent(),
    const EvidenceLockerScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.primary,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textSecondary,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.shield_outlined),
              activeIcon: Icon(Icons.shield),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              activeIcon: Icon(Icons.folder),
              label: 'Evidence',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              AppStrings.appName,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.tagline,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            _buildSosButton(context),
            const SizedBox(height: 32),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildQuickActions(context),
            const SizedBox(height: 32),
            Text(
              'Emergency Contacts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildContactsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSosButton(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SosScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.sosRed,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sos,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            const Text(
              'HOLD FOR SOS',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Long press to activate',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _QuickActionCard(
          icon: Icons.phone_outlined,
          label: AppStrings.fakeCall,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FakeCallScreen()),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.location_on_outlined,
          label: 'Share Location',
          onTap: () async {
            final contactService = ContactService();
            final contacts = await contactService.getContacts();
            if (contacts.isEmpty) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add emergency contacts first'),
                  ),
                );
              }
            } else {
              final smsService = SmsService();
              await smsService.sendLocationSms(contacts, 'Your contact');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Location sent to contacts'),
                  ),
                );
              }
            }
          },
        ),
        _QuickActionCard(
          icon: Icons.directions_run,
          label: 'Journey Mode',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JourneyModeScreen()),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.gavel,
          label: 'Legal Info',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LegalInfoScreen()),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.description,
          label: 'PDF Report',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PdfGeneratorScreen()),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.bluetooth,
          label: 'Guardian',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GuardianModeScreen()),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.record_voice_over,
          label: 'Voice Read',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VoiceReadScreen()),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.battery_alert,
          label: 'Battery SOS',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BatteryAwareScreen()),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.mic,
          label: 'Audio Record',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AudioRecordingScreen()),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.location_on,
          label: 'Safe Arrival',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SafeArrivalScreen()),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.camera_alt,
          label: 'PIN Capture',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WrongPinCaptureScreen()),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.favorite,
          label: 'Safety Pulse',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SafetyPulseScreen()),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.timer,
          label: 'Dead Man Switch',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DeadManSwitchScreen()),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.volume_up,
          label: 'Scream Detect',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScreamDetectionScreen()),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.battery_full,
          label: 'Fake Battery',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FakeBatteryScreen()),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.flashlight_on,
          label: 'Flashlight SOS',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FlashlightSosScreen()),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.sort,
          label: 'Contact Priority',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SmartContactPriorityScreen()),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.message,
          label: 'Custom Messages',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PersonalizedSosMessagesScreen()),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.security,
          label: 'App Lock',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AppLockDataWipeScreen()),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.tune,
          label: 'Sensitivity',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SensitivitySettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContactsSection(BuildContext context) {
    return FutureBuilder<List<Contact>>(
      future: ContactService().getContacts(),
      builder: (context, snapshot) {
        final contacts = snapshot.data ?? [];
        
        if (contacts.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.contact_phone_outlined,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 12),
                const Text(
                  'No emergency contacts',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    _showAddContactDialog(context);
                  },
                  child: const Text('Add Contact'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            ...contacts.map((contact) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.secondary,
                      child: Text(
                        contact.name[0].toUpperCase(),
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            contact.phone,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
            if (contacts.length < 5)
              TextButton.icon(
                onPressed: () => _showAddContactDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Contact'),
              ),
          ],
        );
      },
    );
  }

  void _showAddContactDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Emergency Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter contact name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter phone number',
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
              if (nameController.text.isNotEmpty && 
                  phoneController.text.isNotEmpty) {
                await ContactService().addContact(
                  Contact(
                    name: nameController.text,
                    phone: phoneController.text,
                  ),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  setState(() {});
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: AppColors.iconColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
