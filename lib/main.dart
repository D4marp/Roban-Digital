import 'package:flutter/material.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services and dependencies here
  // await setupServiceLocator();
  // await setupHive();
  
  runApp(
    const RobanDigitalApp(),
  );
}
