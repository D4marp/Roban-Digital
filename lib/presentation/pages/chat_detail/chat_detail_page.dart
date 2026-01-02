import 'package:flutter/material.dart';
import '../../../config/constants/app_colors.dart';

class ChatDetailPage extends StatefulWidget {
  final Map<String, dynamic> contact;

  const ChatDetailPage({
    super.key,
    required this.contact,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> messages = [
    {
      'sender': 'Unit 1',
      'message': 'Copy, ready to proceed',
      'timestamp': '10:30',
      'isOwn': false,
      'type': 'text',
    },
    {
      'sender': 'You',
      'message': 'Unit 1, standby',
      'timestamp': '10:25',
      'isOwn': true,
      'type': 'text',
    },
    {
      'sender': 'Unit 1',
      'message': 'Copy that',
      'timestamp': '10:20',
      'isOwn': false,
      'type': 'text',
    },
  ];

  bool _isPTTActive = false;
  String _selectedChannel = 'Channel 1';
  String _whosSpeaking = 'Unit 1';

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        messages.add({
          'sender': 'You',
          'message': _messageController.text,
          'timestamp': _getCurrentTime(),
          'isOwn': true,
        });
      });
      _messageController.clear();
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _addMessage(String message, String sender, bool isOwn) {
    setState(() {
      messages.add({
        'sender': sender,
        'message': message,
        'timestamp': _getCurrentTime(),
        'isOwn': isOwn,
        'type': 'text',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryDark,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.contact['name'] ?? 'Chat',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Now speaking: $_whosSpeaking',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined, color: Colors.white),
            onPressed: () {
              // Initiate video call
              _showVideoCallDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.emergency_outlined, color: Colors.white),
            onPressed: () {
              // SOS Button
              _showSOSDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Channel Selection Bar
          Container(
            color: AppColors.primaryLight,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _showChannelSelector,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedChannel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                return Align(
                  alignment: message['isOwn']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: message['isOwn']
                          ? AppColors.primaryDark
                          : AppColors.primaryLight.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: message['isOwn']
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!message['isOwn'])
                          Text(
                            message['sender'],
                            style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (!message['isOwn'])
                          const SizedBox(height: 4),
                        Text(
                          message['message'],
                          style: TextStyle(
                            color: message['isOwn']
                                ? Colors.white
                                : AppColors.primaryDark,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message['timestamp'],
                          style: TextStyle(
                            color: message['isOwn']
                                ? Colors.white70
                                : Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Message input with multimedia options
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade200,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Multimedia action buttons
                if (_messageController.text.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildActionButton(
                            icon: Icons.attach_file,
                            label: 'Report',
                            onTap: () {
                              // Laporan Kejadian - Incident Reporting
                              _showIncidentReport();
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.image_outlined,
                            label: 'Photo',
                            onTap: () {
                              // Send photo
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.location_on_outlined,
                            label: 'Location',
                            onTap: () {
                              // Share location
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.videocam_outlined,
                            label: 'Video',
                            onTap: () {
                              // Start video conference
                              _showVideoCallDialog();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                // Text input row
                Row(
                  children: [
                    // PTT Button
                    GestureDetector(
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
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _isPTTActive
                              ? Colors.red
                              : AppColors.primaryDark,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _isPTTActive
                                  ? Colors.red.withValues(alpha: 0.3)
                                  : AppColors.primaryDark.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isPTTActive ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Text input
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        onChanged: (value) {
                          setState(() {});
                        },
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type message...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Send button
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primaryDark),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChannelSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Select Channel',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primaryDark,
                    ),
              ),
            ),
            ...[
              'Channel 1 (Tactical)',
              'Channel 2 (General)',
              'Channel 3 (Admin)',
              'Channel 4 (Emergency)',
            ]
                .map((channel) => ListTile(
                      title: Text(channel),
                      onTap: () {
                        setState(() => _selectedChannel = channel);
                        Navigator.pop(context);
                      },
                      selected: _selectedChannel == channel,
                      selectedTileColor:
                          AppColors.primaryLight.withValues(alpha: 0.2),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  void _showVideoCallDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Conference'),
        content: const Text('Start video call with this contact?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video call initiated...')),
              );
            },
            child: const Text('Start Call'),
          ),
        ],
      ),
    );
  }

  void _showSOSDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SOS Alert'),
        content: const Text(
          'Send emergency alert to all team members?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('SOS Alert sent to all members!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              'Send SOS',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showIncidentReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Incident Report'),
        content: const Text('Create an incident report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Create incident report
              _addMessage(
                'Incident Report Created',
                'system',
                true,
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
