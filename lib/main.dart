import 'package:flutter/material.dart';
import 'app.dart';
import 'core/utils/service_locator.dart';
import 'data/datasources/api/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services and dependencies
  await setupServiceLocator();
  
  // Initialize authentication token from storage if exists
  final apiClient = getIt<ApiClient>();
  await apiClient.initializeAuthToken();
  
  // await setupHive();
  
  runApp(
    const RobanDigitalApp(),
  );
}
