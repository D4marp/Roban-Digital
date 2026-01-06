import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _talkNotifications = true;
  bool _channelNotifications = true;
  bool _chatNotifications = true;
  bool _attendanceReminder = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F5F7F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          
          // General Notifications Section
          _buildSectionHeader('Notifikasi Umum'),
          
          _buildSwitchTile(
            title: 'Push Notifications',
            subtitle: 'Terima notifikasi push di perangkat',
            value: _pushNotifications,
            onChanged: (value) {
              setState(() {
                _pushNotifications = value;
              });
            },
          ),
          
          _buildSwitchTile(
            title: 'Email Notifications',
            subtitle: 'Terima notifikasi melalui email',
            value: _emailNotifications,
            onChanged: (value) {
              setState(() {
                _emailNotifications = value;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // App Features Section
          _buildSectionHeader('Fitur Aplikasi'),
          
          _buildSwitchTile(
            title: 'Talk Notifications',
            subtitle: 'Notifikasi untuk panggilan Talk',
            value: _talkNotifications,
            onChanged: (value) {
              setState(() {
                _talkNotifications = value;
              });
            },
          ),
          
          _buildSwitchTile(
            title: 'Channel Notifications',
            subtitle: 'Notifikasi aktivitas channel',
            value: _channelNotifications,
            onChanged: (value) {
              setState(() {
                _channelNotifications = value;
              });
            },
          ),
          
          _buildSwitchTile(
            title: 'Chat Notifications',
            subtitle: 'Notifikasi pesan chat baru',
            value: _chatNotifications,
            onChanged: (value) {
              setState(() {
                _chatNotifications = value;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Reminders Section
          _buildSectionHeader('Pengingat'),
          
          _buildSwitchTile(
            title: 'Pengingat Absensi',
            subtitle: 'Pengingat untuk melakukan absensi',
            value: _attendanceReminder,
            onChanged: (value) {
              setState(() {
                _attendanceReminder = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2F5F7F),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2F5F7F),
          ),
        ],
      ),
    );
  }
}
