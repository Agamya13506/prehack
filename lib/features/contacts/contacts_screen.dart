import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/contact_service.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> _contacts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final contacts = await ContactService().getContacts();
    setState(() {
      _contacts = contacts;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Trusted Contacts',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_contacts.length}/5 contacts added',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          if (_contacts.length < 5)
                            GestureDetector(
                              onTap: () => _showAddContactDialog(),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.accentLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_add_rounded,
                                  color: AppColors.accent,
                                  size: 22,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  if (_contacts.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: _EmptyContactsCard(
                          onAdd: _showAddContactDialog,
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final contact = _contacts[index];
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: _ContactCard(
                              contact: contact,
                              onDelete: () => _deleteContact(index),
                            ),
                          );
                        },
                        childCount: _contacts.length,
                      ),
                    ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'How it works',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'When SOS is triggered, your trusted contacts receive an SMS with your live location link. They can track you on a browser map — no app install needed.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _deleteContact(int index) async {
    await ContactService().removeContact(index);
    await _load();
  }

  void _showAddContactDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String selectedRelationship = 'Family';
    final relationships = ['Family', 'Friend', 'Roommate', 'Colleague', 'Other'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.primary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModalState) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Add Trusted Contact',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Contact Name',
                  hintText: 'e.g. Mom, Priya',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+91 98765 43210',
                ),
              ),
              const SizedBox(height: 16),
              Text('Relationship',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: relationships.map((r) {
                  final selected = r == selectedRelationship;
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedRelationship = r),
                    child: Chip(
                      label: Text(r),
                      backgroundColor: selected ? AppColors.accentLight : AppColors.secondary,
                      labelStyle: TextStyle(
                        color: selected ? AppColors.accent : AppColors.textSecondary,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      side: BorderSide(
                        color: selected ? AppColors.accent : Colors.transparent,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.isNotEmpty && phoneCtrl.text.isNotEmpty) {
                      await ContactService().addContact(
                        Contact(name: nameCtrl.text, phone: phoneCtrl.text),
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      await _load();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add Contact',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onDelete;

  const _ContactCard({required this.contact, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final initial = contact.name[0].toUpperCase();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.accentLight,
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.name,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(contact.phone,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _Tag(label: 'Family', accent: false),
                    const SizedBox(width: 6),
                    _Tag(label: 'Call + SMS', accent: true),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.chevron_right,
                  color: AppColors.textSecondary, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final bool accent;
  const _Tag({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent ? AppColors.accentLight : AppColors.secondary,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: accent ? AppColors.accent : AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _EmptyContactsCard extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyContactsCard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.accentLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_outline,
                size: 32, color: AppColors.accent),
          ),
          const SizedBox(height: 16),
          Text('No contacts yet',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Add trusted contacts so they receive your SOS alert.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add First Contact'),
          ),
        ],
      ),
    );
  }
}
