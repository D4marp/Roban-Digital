class AppRoutes {
  // Auth routes - no parameters
  static const String splash = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String register = '/register';
  
  // Main app routes - no parameters
  static const String home = '/home';
  static const String contacts = '/contacts';
  static const String callHistory = '/call-history';
  static const String settings = '/settings';
  
  // Chat routes with parameters
  static String chatDetail(String chatId) => '/chat/$chatId';
  static String userProfile(String userId) => '/user/$userId';
  static String channelDetail(String channelId) => '/channel/$channelId';
  static String incidentReport(String reportId) => '/incident-report/$reportId';
  static String videoCall(String callId) => '/video-call/$callId';
  
  // Extract parameter helpers
  static String? extractChatId(String path) {
    final match = RegExp(r'^/chat/(.+)$').firstMatch(path);
    return match?.group(1);
  }
  
  static String? extractUserId(String path) {
    final match = RegExp(r'^/user/(.+)$').firstMatch(path);
    return match?.group(1);
  }
  
  static String? extractChannelId(String path) {
    final match = RegExp(r'^/channel/(.+)$').firstMatch(path);
    return match?.group(1);
  }
  
  static String? extractReportId(String path) {
    final match = RegExp(r'^/incident-report/(.+)$').firstMatch(path);
    return match?.group(1);
  }
  
  static String? extractCallId(String path) {
    final match = RegExp(r'^/video-call/(.+)$').firstMatch(path);
    return match?.group(1);
  }
}
