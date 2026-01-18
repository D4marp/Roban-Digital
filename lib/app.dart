import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/utils/service_locator.dart';
import 'config/constants/app_constants.dart';
import 'config/theme/app_theme.dart';
import 'config/routes/app_routes.dart';
import 'config/routes/route_generator.dart';
import 'config/routes/navigation_service.dart';
import 'presentation/providers/login_provider.dart';
import 'presentation/providers/channel_provider.dart';
import 'presentation/providers/home_provider.dart';
import 'domain/repositories/auth_repository.dart';
import 'data/datasources/local/auth_local_datasource.dart';

class RobanDigitalApp extends StatelessWidget {
  const RobanDigitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => ChannelProvider()),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(
            authRepository: getIt<AuthRepository>(),
            authLocalDataSource: getIt<AuthLocalDataSource>(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: RouteGenerator.generateRoute,
        navigatorKey: NavigationService.navigatorKey,
      ),
    );
  }
}

