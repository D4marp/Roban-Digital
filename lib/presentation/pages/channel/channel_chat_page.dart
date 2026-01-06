import 'package:flutter/material.dart';

class ChannelChatPage extends StatefulWidget {
  final String channelName;
  final bool isOnline;

  const ChannelChatPage({
    super.key,
    required this.channelName,
    required this.isOnline,
  });

  @override
  State<ChannelChatPage> createState() => _ChannelChatPageState();
}

class _ChannelChatPageState extends State<ChannelChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> messages = [
    {
      'sender': 'Jendral Sudirman',
      'message':
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
      'isMe': false,
      'time': '10:30',
    },
    {
      'sender': 'Ir Soekarno',
      'message':
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
      'isMe': true,
      'time': '10:32',
    },
    {
      'sender': 'Jendral Sudirman',
      'message':
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
      'isMe': false,
      'time': '10:35',
    },
    {
      'sender': 'Jendral Sudirman',
      'message':
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
      'isMe': false,
      'time': '10:37',
    },
    {
      'sender': 'Ir Soekarno',
      'message':
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
      'isMe': true,
      'time': '10:38',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add({
        'sender': 'Ir Soekarno',
        'message': _messageController.text,
        'isMe': true,
        'time': TimeOfDay.now().format(context),
      });
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F5F7F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F5F7F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chat',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final showSender = index == 0 ||
                    messages[index - 1]['sender'] != message['sender'];
                return _buildMessageBubble(
                  message['sender'],
                  message['message'],
                  message['isMe'],
                  showSender,
                );
              },
            ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD6E8F5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Ketik Pesan',
                        hintStyle: TextStyle(
                          color: Color(0xFF2F5F7F),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(
                        color: Color(0xFF2F5F7F),
                        fontSize: 14,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Color(0xFF2F5F7F),
                    ),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    String sender,
    String message,
    bool isMe,
    bool showSender,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showSender)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                sender,
                style: TextStyle(
                  fontSize: 12,
                  color: isMe ? Colors.red : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isMe
                  ? const Color(0xFF4A6B88)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: isMe ? Colors.white : Colors.black,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
