import 'package:flutter/material.dart';
import '../../../config/routes/navigation_service.dart';
import '../../../config/constants/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Sample data for contacts/users
  final List<Map<String, dynamic>> contacts = [
    {
      'name': 'Unit 1',
      'lastMessage': 'Copy',
      'timestamp': '10:30',
      'isOnline': true,
      'unread': 2,
    },
    {
      'name': 'Unit 2',
      'lastMessage': 'Standby',
      'timestamp': '10:15',
      'isOnline': true,
      'unread': 0,
    },
    {
      'name': 'Unit 3',
      'lastMessage': 'En Route',
      'timestamp': '09:45',
      'isOnline': false,
      'unread': 1,
    },
    {
      'name': 'Command Center',
      'lastMessage': 'All units check in',
      'timestamp': '09:30',
      'isOnline': true,
      'unread': 0,
    },
  ];

  int _selectedIndex = 0;
  bool _isPTTActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryDark,
        title: const Text(
          'PPT - Push To Talk',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              NavigationService.goToSettings();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            color: AppColors.primaryLight,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Online',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    NavigationService.goToCallHistory();
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.history, size: 18, color: AppColors.primaryDark),
                      const SizedBox(width: 4),
                      const Text(
                        'History',
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Contacts list
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return GestureDetector(
                  onTap: () {
                    // Open chat detail with dynamic route
                    final chatId = contact['name']?.replaceAll(' ', '_').toLowerCase() ?? 'unknown';
                    NavigationService.goToChatDetail(chatId, contact: contact);
                  },
                  child: Container(
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
                                Text(
                                  contact['lastMessage'],
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Timestamp and unread badge
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                contact['timestamp'],
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                              if (contact['unread'] > 0)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    contact['unread'].toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // PTT Button (Push To Talk)
      floatingActionButton: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPTTActive = true);
        },
        onTapUp: (_) {
          setState(() => _isPTTActive = false);
        },
        onTapCancel: () {
          setState(() => _isPTTActive = false);
        },
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: _isPTTActive ? Colors.red : AppColors.primaryDark,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _isPTTActive
                    ? Colors.red.withValues(alpha: 0.4)
                    : AppColors.primaryDark.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            _isPTTActive ? Icons.mic : Icons.mic_none,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
      // Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 1) {
            NavigationService.goToContacts();
          }
        },
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outlined),
            activeIcon: Icon(Icons.people),
            label: 'Contacts',
          ),
        ],
      ),
    );
  }
}
