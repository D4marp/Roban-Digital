import 'package:flutter/material.dart';

class ChannelDetailPage extends StatefulWidget {
  const ChannelDetailPage({super.key});

  @override
  State<ChannelDetailPage> createState() => _ChannelDetailPageState();
}

class _ChannelDetailPageState extends State<ChannelDetailPage> {
  bool isMuted = false;
  bool isSpeakerOn = true;
  bool showChannelList = true;

  final List<Map<String, dynamic>> channels = [
    {'name': 'Patroli Garuda', 'isOnline': true},
    {'name': 'Patroli Garuda', 'isOnline': false},
    {'name': 'Patroli Garuda', 'isOnline': true},
  ];

  String selectedChannel = 'Nama Channel....';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Talk',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top section with channel selector and dropdown
            Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Channel selector button
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A5F),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            showChannelList = !showChannelList;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  selectedChannel,
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Icon(
                                showChannelList
                                    ? Icons.keyboard_arrow_up
                                    : Icons.chevron_right,
                                color: Colors.white,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Channel list dropdown
                  if (showChannelList)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: channels.asMap().entries.map((entry) {
                          final index = entry.key;
                          final channel = entry.value;
                          return _buildChannelItem(
                            channel['name'],
                            channel['isOnline'],
                            isLast: index == channels.length - 1,
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),

            // Center microphone section
            Expanded(
              child: Center(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.mic,
                      size: 80,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom controls
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Mute button
                  _buildControlButton(
                    icon: isMuted ? Icons.mic_off : Icons.mic_none,
                    onTap: () {
                      setState(() {
                        isMuted = !isMuted;
                      });
                    },
                  ),
                  
                  // Speaker button
                  _buildControlButton(
                    icon: isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                    onTap: () {
                      setState(() {
                        isSpeakerOn = !isSpeakerOn;
                      });
                    },
                  ),
                  
                  // SOS button
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red,
                        width: 2,
                      ),
                      color: Colors.white,
                    ),
                    child: const Center(
                      child: Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelItem(String name, bool isOnline, {bool isLast = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            selectedChannel = name;
            showChannelList = false;
          });
          // Return the selected channel name to the previous page
          Navigator.pop(context, name);
        },
        borderRadius: BorderRadius.vertical(
          top: name == channels.first['name'] && isOnline == channels.first['isOnline']
              ? const Radius.circular(16)
              : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(
                      color: Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.language,
                color: Colors.grey[600],
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Color(0xFF1E3A5F),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isOnline ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(35),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 32,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
