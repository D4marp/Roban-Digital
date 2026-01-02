import 'package:flutter/material.dart';
import '../../../config/routes/navigation_service.dart';
import '../../../config/constants/app_colors.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final List<Map<String, dynamic>> contacts = [
    {
      'name': 'Unit 1',
      'callSign': 'Bravo-01',
      'status': 'Available',
      'isOnline': true,
    },
    {
      'name': 'Unit 2',
      'callSign': 'Bravo-02',
      'status': 'Available',
      'isOnline': true,
    },
    {
      'name': 'Unit 3',
      'callSign': 'Bravo-03',
      'status': 'In Call',
      'isOnline': true,
    },
    {
      'name': 'Unit 4',
      'callSign': 'Bravo-04',
      'status': 'Offline',
      'isOnline': false,
    },
    {
      'name': 'Command Center',
      'callSign': 'Control',
      'status': 'Available',
      'isOnline': true,
    },
  ];

  late List<Map<String, dynamic>> filteredContacts;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredContacts = contacts;
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredContacts = contacts
          .where((contact) =>
              contact['name'].toLowerCase().contains(query) ||
              contact['callSign'].toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryDark,
        title: const Text(
          'Contacts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => NavigationService.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          // Contacts list
          Expanded(
            child: filteredContacts.isEmpty
                ? Center(
                    child: Text(
                      'No contacts found',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = filteredContacts[index];
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: AppColors.primary,
                                    child: Text(
                                      contact['name'][0],
                                      style: const TextStyle(
                                        color: AppColors.primaryDark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  if (contact['isOnline'])
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              // Contact info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      contact['name'],
                                      style: const TextStyle(
                                        color: AppColors.primaryDark,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          contact['callSign'],
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: contact['isOnline']
                                                ? Colors.green.shade100
                                                : Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            contact['status'],
                                            style: TextStyle(
                                              color: contact['isOnline']
                                                  ? Colors.green.shade700
                                                  : Colors.grey.shade600,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Action buttons
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.call_outlined,
                                      size: 20,
                                      color: AppColors.primaryDark,
                                    ),
                                    onPressed: () {
                                      // Initiate call
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.message_outlined,
                                      size: 20,
                                      color: AppColors.primaryDark,
                                    ),
                                    onPressed: () {
                                      // Open chat with dynamic route
                                      final chatId = contact['name']?.replaceAll(' ', '_').toLowerCase() ?? 'unknown';
                                      NavigationService.goToChatDetail(chatId, contact: contact);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
