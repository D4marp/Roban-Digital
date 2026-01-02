import 'package:flutter/material.dart';

class AppColors {
  // PPT App Colors
  static const Color skyBlue = Color(0xFF87CEEB);
  static const Color mediumBlue = Color(0xFF5DADE2);
  static const Color darkBlue = Color(0xFF1B3C53);
  static const Color lightBlue = Color(0xFFCEF2FF);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Gradient
  static const LinearGradient skyGradient = LinearGradient(
    colors: [skyBlue, mediumBlue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
