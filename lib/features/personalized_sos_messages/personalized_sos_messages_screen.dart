import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/contact_service.dart';

class PersonalizedSosMessagesScreen extends StatefulWidget {
  const PersonalizedSosMessagesScreen({super.key});

  @override
  State<PersonalizedSosMessagesScreen> createState() => _PersonalizedSosMessagesScreenState();
}

class _PersonalizedSosMessagesScreenState extends State<PersonalizedSosMessagesScreen> {
  List<Contact> _contacts = [];
  bool _isLoading = true;
  final Map<String, TextEditingController> _controllers = {};

  static const String _defaultMessage = '🆘 I am in DANGER! Please help me. My location:';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    final contactService = ContactService();
    final contacts = await contactService.getContacts();
    final prefs = await SharedPreferences.getInstance();
    
    for (var contact in contacts) {
      final message = prefs.getString('sos_message_${contact.phone}') ?? _defaultMessage;
      _controllers[contact.phone] = TextEditingController(text: message);
    }

    setState(() {
      _contacts = contacts;
      _isLoading = false;
    });
  }

  Future<void> _saveMessage(Contact contact) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sos_message_${contact.phone}', _controllers[contact.phone]!.text);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Message saved for ${contact.name}'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _resetToDefault(Contact contact) async {
    _controllers[contact.phone]!.text = _defaultMessage;
    await _saveMessage(contact);
  }

  String _getMessagePreview(String message) {
    if (message.length > 50) {
      return '${message.substring(0, 50)}...';
    }
    return message;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Personalized SOS Messages'),
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
              Icons.message_outlined,
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
              'Add emergency contacts to set personalized SOS messages',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
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
                    'Set custom SOS messages for each contact. Each message will be sent with your location during an SOS alert.',
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
          ..._contacts.map((contact) => _buildContactMessageCard(contact)),
          const SizedBox(height: 24),
          _buildDefaultMessageSection(),
        ],
      ),
    );
  }

  Widget _buildContactMessageCard(Contact contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.accent,
                child: Text(
                  contact.name[0].toUpperCase(),
                  style: const TextStyle(color: AppColors.primary),
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
                        fontWeight: FontWeight.w600,
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
              TextButton(
                onPressed: () => _resetToDefault(contact),
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controllers[contact.phone],
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter custom SOS message...',
              filled: true,
              fillColor: AppColors.secondary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.accent, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.preview, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getMessagePreview(_controllers[contact.phone]!.text),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _saveMessage(contact),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
              child: const Text('Save Message'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultMessageSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sosRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.sosRed.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber, color: AppColors.sosRed),
              SizedBox(width: 8),
              Text(
                'Default Message',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.sosRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'When you don\'t set a custom message for a contact, this default message will be used:',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _defaultMessage,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
