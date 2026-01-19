import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robandigital/presentation/providers/channel_chat_provider.dart';

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

  @override
  void initState() {
    super.initState();
    // Load mock messages when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ChannelChatProvider>().loadMockMessages(widget.channelName);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    context.read<ChannelChatProvider>().sendMessage(_messageController.text);
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.channelName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Consumer<ChannelChatProvider>(
              builder: (context, provider, _) {
                return Text(
                  'Token: ${provider.token?.substring(0, 20) ?? "Not loaded"}...',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                );
              },
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Consumer<ChannelChatProvider>(
        builder: (context, chatProvider, _) {
          if (chatProvider.state == ChannelChatState.loading && chatProvider.messages.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (chatProvider.state == ChannelChatState.error) {
            return Center(
              child: Text(
                'Error: ${chatProvider.errorMessage}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          return Column(
            children: [
              // Chat messages
              Expanded(
                child: chatProvider.messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.message_outlined,
                              color: Colors.white54,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum ada pesan',
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Consumer<ChannelChatProvider>(
                              builder: (context, provider, _) {
                                return Text(
                                  'User ID: ${provider.userId ?? "Unknown"}',
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: chatProvider.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatProvider.messages[index];
                          final showSender = index == 0 ||
                              chatProvider.messages[index - 1].sender != message.sender;
                          return _buildMessageBubble(
                            message.sender,
                            message.content,
                            message.isMe,
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
          );
        },
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
