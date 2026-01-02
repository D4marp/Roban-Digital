import 'package:flutter/material.dart';
import 'config/constants/app_constants.dart';
import 'config/theme/app_theme.dart';
import 'config/routes/app_routes.dart';
import 'config/routes/route_generator.dart';
import 'config/routes/navigation_service.dart';

class RobanDigitalApp extends StatelessWidget {
  const RobanDigitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: RouteGenerator.generateRoute,
      navigatorKey: NavigationService.navigatorKey,
    );
  }
}

