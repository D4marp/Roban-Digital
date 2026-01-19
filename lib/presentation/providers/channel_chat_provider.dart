import 'package:flutter/foundation.dart';
import 'package:robandigital/data/datasources/local/auth_local_datasource.dart';
import 'package:robandigital/core/utils/service_locator.dart';

enum ChannelChatState { initial, loading, success, error }

class Message {
  final String sender;
  final String content;
  final bool isMe;
  final String time;
  final String? senderId;

  Message({
    required this.sender,
    required this.content,
    required this.isMe,
    required this.time,
    this.senderId,
  });
}

class ChannelChatProvider extends ChangeNotifier {
  final AuthLocalDataSource _authLocalDataSource;

  ChannelChatState _state = ChannelChatState.initial;
  List<Message> _messages = [];
  String? _errorMessage;
  String? _token;
  String? _userId;
  String? _userName;

  ChannelChatProvider({AuthLocalDataSource? authLocalDataSource})
      : _authLocalDataSource = authLocalDataSource ?? getIt<AuthLocalDataSource>() {
    _loadAuthData();
  }

  // Getters
  ChannelChatState get state => _state;
  List<Message> get messages => _messages;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  String? get userId => _userId;
  String? get userName => _userName;
  bool get isLoading => _state == ChannelChatState.loading;

  /// Load authentication data from local storage
  void _loadAuthData() {
    try {
      _token = _authLocalDataSource.getToken();
      _userId = _authLocalDataSource.getUserId()?.toString();
      _userName = _authLocalDataSource.getUsername();
      _state = ChannelChatState.success;
    } catch (e) {
      _errorMessage = 'Error loading auth data: $e';
      _state = ChannelChatState.error;
    }
  }

  /// Send message
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    if (_token == null || _userId == null) {
      _errorMessage = 'User not authenticated';
      _state = ChannelChatState.error;
      notifyListeners();
      return;
    }

    // Add message to local list
    final newMessage = Message(
      sender: _userName ?? 'User',
      content: message,
      isMe: true,
      time: DateTime.now().toString().substring(11, 16),
      senderId: _userId,
    );

    _messages.add(newMessage);
    notifyListeners();

    // TODO: Send to API when available
    // For now, just add to local list with token
  }

  /// Load messages from channel (mock data for now)
  void loadMockMessages(String channelName) {
    _state = ChannelChatState.loading;
    notifyListeners();

    // Mock messages for demonstration
    _messages = [
      Message(
        sender: 'Team Lead',
        content: 'Halo, ada update untuk proyek ini?',
        isMe: false,
        time: '10:30',
        senderId: '1',
      ),
      Message(
        sender: _userName ?? 'User',
        content: 'Ya, saya sudah menyelesaikan bagian frontend',
        isMe: true,
        time: '10:32',
        senderId: _userId,
      ),
      Message(
        sender: 'Team Lead',
        content: 'Bagus! Bisa di-review minggu depan?',
        isMe: false,
        time: '10:35',
        senderId: '1',
      ),
    ];

    _state = ChannelChatState.success;
    notifyListeners();
  }

  /// Clear messages
  void clearMessages() {
    _messages = [];
    notifyListeners();
  }
}
