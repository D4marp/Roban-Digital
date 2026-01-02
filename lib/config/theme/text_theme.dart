import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTextTheme {
  static TextTheme get lightTextTheme {
    return TextTheme(
      // Display styles
      displayLarge: GoogleFonts.poppins(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: AppColors.grey900,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: AppColors.grey900,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.grey900,
        height: 1.3,
      ),
      // Headline styles
      headlineLarge: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.grey900,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.grey900,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.grey900,
        height: 1.4,
      ),
      // Title styles
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.grey900,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.grey900,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.grey900,
        height: 1.4,
      ),
      // Body styles
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.grey800,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.grey700,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.grey600,
        height: 1.5,
      ),
      // Label styles
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.grey900,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.grey700,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.grey600,
        height: 1.4,
      ),
    );
  }

  static TextTheme get darkTextTheme {
    return TextTheme(
      // Display styles
      displayLarge: GoogleFonts.poppins(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        height: 1.3,
      ),
      // Headline styles
      headlineLarge: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        height: 1.4,
      ),
      // Title styles
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        height: 1.4,
      ),
      // Body styles
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.grey100,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.grey200,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.grey300,
        height: 1.5,
      ),
      // Label styles
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.grey200,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.grey300,
        height: 1.4,
      ),
    );
  }
}
