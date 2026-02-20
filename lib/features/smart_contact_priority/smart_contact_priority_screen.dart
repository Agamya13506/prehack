import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/contact_service.dart';

class SmartContactPriorityScreen extends StatefulWidget {
  const SmartContactPriorityScreen({super.key});

  @override
  State<SmartContactPriorityScreen> createState() => _SmartContactPriorityScreenState();
}

class _SmartContactPriorityScreenState extends State<SmartContactPriorityScreen> {
  List<Contact> _contacts = [];
  Map<String, int> _priorityScores = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final contactService = ContactService();
    final contacts = await contactService.getContacts();
    final prefs = await SharedPreferences.getInstance();
    
    Map<String, int> scores = {};
    for (var contact in contacts) {
      scores[contact.phone] = prefs.getInt('priority_${contact.phone}') ?? 0;
    }

    setState(() {
      _contacts = contacts;
      _priorityScores = scores;
      _isLoading = false;
    });
  }

  Future<void> _updatePriority(Contact contact, int delta) async {
    final prefs = await SharedPreferences.getInstance();
    final currentScore = _priorityScores[contact.phone] ?? 0;
    final newScore = (currentScore + delta).clamp(0, 100);
    
    await prefs.setInt('priority_${contact.phone}', newScore);
    
    setState(() {
      _priorityScores[contact.phone] = newScore;
    });
  }

  List<Contact> _getSortedContacts() {
    List<Contact> sorted = List.from(_contacts);
    sorted.sort((a, b) {
      final scoreA = _priorityScores[a.phone] ?? 0;
      final scoreB = _priorityScores[b.phone] ?? 0;
      return scoreB.compareTo(scoreA);
    });
    return sorted;
  }

  String _getPriorityLabel(int score) {
    if (score >= 80) return 'Highest';
    if (score >= 60) return 'High';
    if (score >= 40) return 'Medium';
    if (score >= 20) return 'Low';
    return 'Lowest';
  }

  Color _getPriorityColor(int score) {
    if (score >= 80) return AppColors.sosRed;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return AppColors.warning;
    if (score >= 20) return AppColors.success;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Smart Contact Priority'),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
              ? _buildEmptyState()
              : _buildContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Contacts Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add emergency contacts to set priority levels',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final sortedContacts = _getSortedContacts();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    'Higher priority contacts will be notified first during SOS. Priority learns from your usage patterns.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Contact Priority',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedContacts.asMap().entries.map((entry) {
            final index = entry.key;
            final contact = entry.value;
            final score = _priorityScores[contact.phone] ?? 0;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getPriorityColor(score).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '#${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getPriorityColor(score),
                        ),
                      ),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _getPriorityLabel(score),
                        style: TextStyle(
                          color: _getPriorityColor(score),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => _updatePriority(contact, -10),
                            iconSize: 20,
                            color: AppColors.textSecondary,
                          ),
                          Text(
                            '$score%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => _updatePriority(contact, 10),
                            iconSize: 20,
                            color: AppColors.accent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.sosRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.sosRed.withValues(alpha: 0.3)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber, color: AppColors.sosRed),
                    SizedBox(width: 8),
                    Text(
                      'SOS Order',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.sosRed,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'During SOS, contacts will be notified in this order. Top priority contacts receive your location first.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
