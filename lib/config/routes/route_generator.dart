import 'package:flutter/material.dart';
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/forgot_password_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/contacts/contacts_page.dart';
import '../../presentation/pages/call_history/call_history_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/chat_detail/chat_detail_page.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? '/';
    
    // Static routes
    if (routeName == AppRoutes.splash) {
      return MaterialPageRoute(builder: (_) => const SplashPage());
    }
    if (routeName == AppRoutes.login) {
      return MaterialPageRoute(builder: (_) => const LoginPage());
    }
    if (routeName == AppRoutes.forgotPassword) {
      return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
    }
    if (routeName == AppRoutes.register) {
      return MaterialPageRoute(builder: (_) => const LoginPage()); // TODO: Create register page
    }
    if (routeName == AppRoutes.home) {
      return MaterialPageRoute(builder: (_) => const HomePage());
    }
    if (routeName == AppRoutes.contacts) {
      return MaterialPageRoute(builder: (_) => const ContactsPage());
    }
    if (routeName == AppRoutes.callHistory) {
      return MaterialPageRoute(builder: (_) => const CallHistoryPage());
    }
    if (routeName == AppRoutes.settings) {
      return MaterialPageRoute(builder: (_) => const SettingsPage());
    }
    
    // Dynamic routes with parameters
    if (routeName.startsWith('/chat/')) {
      final chatId = AppRoutes.extractChatId(routeName);
      final contact = settings.arguments as Map<String, dynamic>? ?? {'id': chatId};
      return MaterialPageRoute(
        builder: (_) => ChatDetailPage(contact: contact),
      );
    }
    
    if (routeName.startsWith('/user/')) {
      final userId = AppRoutes.extractUserId(routeName);
      // TODO: Create UserProfilePage
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text('User Profile - $userId')),
          body: Center(child: Text('User: $userId')),
        ),
      );
    }
    
    if (routeName.startsWith('/channel/')) {
      final channelId = AppRoutes.extractChannelId(routeName);
      // TODO: Create ChannelDetailPage
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text('Channel - $channelId')),
          body: Center(child: Text('Channel: $channelId')),
        ),
      );
    }
    
    if (routeName.startsWith('/incident-report/')) {
      final reportId = AppRoutes.extractReportId(routeName);
      // TODO: Create IncidentReportPage
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text('Incident Report - $reportId')),
          body: Center(child: Text('Report: $reportId')),
        ),
      );
    }
    
    if (routeName.startsWith('/video-call/')) {
      final callId = AppRoutes.extractCallId(routeName);
      // TODO: Create VideoCallPage
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text('Video Call - $callId')),
          body: Center(child: Text('Call: $callId')),
        ),
      );
    }
    
    // 404 - Page Not Found
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Page not found'),
              const SizedBox(height: 16),
              Text('Route: $routeName'),
            ],
          ),
        ),
      ),
    );
  }
}
