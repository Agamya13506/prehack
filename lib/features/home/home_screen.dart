import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/contact_service.dart';
import '../sos/sos_screen.dart';
import '../fake_call/fake_call_screen.dart';
import '../contacts/contacts_screen.dart';
import '../more/all_features_screen.dart';

// ── Feature screen imports ───────────────────────────────────────────────────
import '../evidence_locker/evidence_locker_screen.dart';
import '../journey_mode/journey_mode_screen.dart';
import '../legal_info/legal_info_screen.dart';
import '../pdf_generator/pdf_generator_screen.dart';
import '../guardian_mode/guardian_mode_screen.dart';
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
import '../settings/settings_screen.dart';
import '../battery_aware/battery_aware_screen.dart';
import '../voice_read/voice_read_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Root shell — owns the 5-tab BottomNavigationBar
// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Tabs: 0=Home, 1=FakeCall, (2=SOS FAB), 3=Contacts, 4=More
  final List<Widget> _tabs = const [
    HomeContent(),
    FakeCallScreen(),
    SizedBox.shrink(),     // placeholder — SOS is always the FAB
    ContactsScreen(),
    AllFeaturesScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      // SOS center button
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SosScreen()));
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: IndexedStack(
        index: _selectedIndex == 2 ? 0 : _selectedIndex,
        children: _tabs,
      ),
      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom navigation bar — Saheli style with center SOS FAB
// ─────────────────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Container(
      height: 72 + mq.padding.bottom,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: mq.padding.bottom),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Home',
              index: 0,
              selected: selectedIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.phone_outlined,
              activeIcon: Icons.phone_rounded,
              label: 'Fake Call',
              index: 1,
              selected: selectedIndex == 1,
              onTap: () => onTap(1),
            ),

            // Center SOS FAB
            GestureDetector(
              onTap: () => onTap(2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x337C5FD6),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'SOS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),

            _NavItem(
              icon: Icons.people_outline_rounded,
              activeIcon: Icons.people_rounded,
              label: 'Contacts',
              index: 3,
              selected: selectedIndex == 3,
              onTap: () => onTap(3),
            ),
            _NavItem(
              icon: Icons.menu_rounded,
              activeIcon: Icons.menu_rounded,
              label: 'More',
              index: 4,
              selected: selectedIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? activeIcon : icon,
              size: 24,
              color: selected ? AppColors.accent : AppColors.textSecondary,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: selected ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Home tab content
// ─────────────────────────────────────────────────────────────────────────────
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final contacts = await ContactService().getContacts();
    if (mounted) setState(() => _contacts = contacts);
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_greeting()}, Anjali',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Medusa',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.warning,
                          ),
                        ),
                        TextSpan(
                          text: ' — Your Shield',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your phone. Your shield. Always.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Area Safety Score ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _AreaSafetyCard(),
            ),

            const SizedBox(height: 24),

            // ── Quick Actions ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _QuickActionsGrid(contacts: _contacts),
            ),

            const SizedBox(height: 24),

            // ── Protection Lifecycle ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ProtectionLifecycleCard(),
            ),

            const SizedBox(height: 16),

            // ── Community Alert ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _CommunityAlertCard(),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Area Safety Score card with circular arc gauge
// ─────────────────────────────────────────────────────────────────────────────
class _AreaSafetyCard extends StatelessWidget {
  _AreaSafetyCard();

  // Mock score — hook up to real data later
  final int score = 62;
  final String summary =
      'Moderate risk detected. Stay alert and keep location sharing on.';
  final int incidents = 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            height: 90,
            child: CustomPaint(
              painter: _ArcGaugePainter(score: score),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$score',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'SCORE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Area Safety',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  summary,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$incidents incidents nearby (24h)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcGaugePainter extends CustomPainter {
  final int score;
  _ArcGaugePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width / 2) - 6;
    const startAngle = pi * 0.75;
    const sweepFull = pi * 1.5;

    final bgPaint = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;

    final fgPaint = Paint()
      ..color = AppColors.warning
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle,
      sweepFull,
      false,
      bgPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle,
      sweepFull * (score / 100),
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcGaugePainter old) => old.score != score;
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Actions 3×2 grid
// ─────────────────────────────────────────────────────────────────────────────
class _QuickActionsGrid extends StatelessWidget {
  final List<Contact> contacts;
  const _QuickActionsGrid({required this.contacts});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QAItem(
        icon: Icons.shield_rounded,
        label: 'SOS Alert',
        subtitle: 'Multi-trigger',
        color: const Color(0xFF7C5FD6),
        bgColor: const Color(0xFFEDE8FB),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SosScreen())),
      ),
      _QAItem(
        icon: Icons.phone_rounded,
        label: 'Fake Call',
        subtitle: 'Escape danger',
        color: const Color(0xFF2ABD8B),
        bgColor: const Color(0xFFE0F7F0),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const FakeCallScreen())),
      ),
      _QAItem(
        icon: Icons.directions_walk_rounded,
        label: 'Journey Mode',
        subtitle: 'Auto-alert',
        color: const Color(0xFF5BA8F5),
        bgColor: const Color(0xFFE3F0FD),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const JourneyModeScreen())),
      ),
      _QAItem(
        icon: Icons.lock_rounded,
        label: 'Evidence Locker',
        subtitle: 'Secured',
        color: const Color(0xFFF5A623),
        bgColor: const Color(0xFFFFF3E0),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const EvidenceLockerScreen())),
      ),
      _QAItem(
        icon: Icons.balance_rounded,
        label: 'Legal Info',
        subtitle: 'Know rights',
        color: const Color(0xFF2ABD8B),
        bgColor: const Color(0xFFE0F7F0),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const LegalInfoScreen())),
      ),
      _QAItem(
        icon: Icons.apps_rounded,
        label: 'More',
        subtitle: 'All features',
        color: const Color(0xFF1A1A1A),
        bgColor: const Color(0xFFEEEEEE),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AllFeaturesScreen())),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.92,
      ),
      itemBuilder: (context, i) => _QuickActionCard(item: actions[i]),
    );
  }
}

class _QAItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;
  const _QAItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _QAItem item;
  const _QuickActionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const Spacer(),
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Protection Lifecycle card
// ─────────────────────────────────────────────────────────────────────────────
class _ProtectionLifecycleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COMPLETE PROTECTION LIFECYCLE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          IntrinsicHeight(
            child: Row(
              children: [
                _LifecyclePhase(
                  label: 'Before',
                  detail: 'Journey mode, alerts',
                  color: const Color(0xFF2ABD8B),
                ),
                const VerticalDivider(width: 1, color: AppColors.divider),
                _LifecyclePhase(
                  label: 'During',
                  detail: 'SOS, evidence, morse',
                  color: AppColors.accent,
                ),
                const VerticalDivider(width: 1, color: AppColors.divider),
                _LifecyclePhase(
                  label: 'After',
                  detail: 'Legal, FIR, PDF',
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LifecyclePhase extends StatelessWidget {
  final String label;
  final String detail;
  final Color color;
  const _LifecyclePhase(
      {required this.label, required this.detail, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              detail,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Community Alert card
// ─────────────────────────────────────────────────────────────────────────────
class _CommunityAlertCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.warningLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on_rounded,
                color: AppColors.warning, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Community Alert',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Poorly lit stretch near MG Road crossing reported 15 min ago. Be careful after 9pm.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
