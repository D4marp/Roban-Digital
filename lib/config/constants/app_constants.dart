/// App Constants
class AppConstants {
  // App Info
  static const String appName = 'Roban Digital PPT';
  static const String appVersion = '1.0.0';
  static const String appPackage = 'com.robandigital.ppt';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration navigationDuration = Duration(milliseconds: 300);

  // Splash Screen
  static const Duration splashDuration = Duration(seconds: 3);

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String presentationsKey = 'presentations';

  // API Endpoints
  static const String apiBaseUrl = 'https://api.robandigital.com/v1';
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String presentationsEndpoint = '/presentations';

  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int maxTitleLength = 100;
  static const int maxSlideCount = 100;

  // Slide Limits
  static const int minSlideWidth = 960;
  static const int minSlideHeight = 540;
  static const double defaultSlideAspectRatio = 16 / 9;
}
