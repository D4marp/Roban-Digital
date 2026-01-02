import 'package:flutter/material.dart';
import 'app_routes.dart';

/// Navigation service for managing route navigation
/// Allows for easier and more maintainable navigation throughout the app
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Get current context
  static BuildContext? get context => navigatorKey.currentContext;

  // Get navigator state
  static NavigatorState? get navigatorState => navigatorKey.currentState;

  // Push named route
  static Future<dynamic> pushNamed(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorState?.pushNamed(routeName, arguments: arguments) ?? Future.value();
  }

  // Push replacement route
  static Future<dynamic> pushReplacementNamed(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorState?.pushReplacementNamed(routeName, arguments: arguments) ?? Future.value();
  }

  // Push and remove until route
  static Future<dynamic> pushNamedAndRemoveUntil(
    String routeName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    return navigatorState?.pushNamedAndRemoveUntil(
          routeName,
          predicate,
          arguments: arguments,
        ) ??
        Future.value();
  }

  // Pop current route
  static void pop<T extends Object>([T? result]) {
    if (navigatorState?.canPop() ?? false) {
      navigatorState?.pop(result);
    }
  }

  // Navigation methods for specific pages
  static Future<void> goToSplash() => pushReplacementNamed(AppRoutes.splash);

  static Future<void> goToLogin() => pushReplacementNamed(AppRoutes.login);

  static Future<void> goToForgotPassword() => pushNamed(AppRoutes.forgotPassword);

  static Future<void> goToHome() => pushReplacementNamed(AppRoutes.home);

  static Future<void> goToContacts() => pushNamed(AppRoutes.contacts);

  static Future<void> goToCallHistory() => pushNamed(AppRoutes.callHistory);

  static Future<void> goToSettings() => pushNamed(AppRoutes.settings);

  static Future<void> goToChatDetail(
    String chatId, {
    Map<String, dynamic>? contact,
  }) =>
      pushNamed(
        AppRoutes.chatDetail(chatId),
        arguments: contact,
      );

  static Future<void> goToUserProfile(
    String userId, {
    Map<String, dynamic>? userData,
  }) =>
      pushNamed(
        AppRoutes.userProfile(userId),
        arguments: userData,
      );

  static Future<void> goToChannelDetail(
    String channelId, {
    Map<String, dynamic>? channelData,
  }) =>
      pushNamed(
        AppRoutes.channelDetail(channelId),
        arguments: channelData,
      );

  static Future<void> goToIncidentReport(
    String reportId, {
    Map<String, dynamic>? reportData,
  }) =>
      pushNamed(
        AppRoutes.incidentReport(reportId),
        arguments: reportData,
      );

  static Future<void> goToVideoCall(
    String callId, {
    Map<String, dynamic>? callData,
  }) =>
      pushNamed(
        AppRoutes.videoCall(callId),
        arguments: callData,
      );

  // Logout and clear navigation stack
  static Future<void> logout() => pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
}
