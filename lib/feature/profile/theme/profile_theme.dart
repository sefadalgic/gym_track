import 'package:flutter/material.dart';

/// Profile screen specific theme constants and colors
class ProfileTheme {
  // Colors - Dark Theme
  static const Color darkBackground = Color(0xFF0A0E14);
  static const Color cardBackground = Color(0xFF151A21);
  static const Color cardBorder = Color(0xFF1E252E);
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFF8A8F98);
  static const Color accentCyan = Color(0xFF00D9FF);
  static const Color successGreen = Color(0xFF00FF88);
  static const Color warningAmber = Color(0xFFFFB800);
  static const Color errorRed = Color(0xFFFF4757);

  // Badge gradient colors
  static const List<Color> bronzeGradient = [
    Color(0xFFCD7F32),
    Color(0xFFB87333),
  ];
  static const List<Color> silverGradient = [
    Color(0xFFC0C0C0),
    Color(0xFFA8A8A8),
  ];
  static const List<Color> goldGradient = [
    Color(0xFFFFD700),
    Color(0xFFFFB700),
  ];

  // Spacing
  static const double screenPadding = 20.0;
  static const double sectionSpacing = 32.0;
  static const double cardPadding = 16.0;
  static const double elementSpacing = 12.0;
  static const double tightSpacing = 8.0;

  // Border Radius
  static const double cardRadius = 12.0;
  static const double buttonRadius = 8.0;
  static const double badgeRadius = 16.0;

  // Elevation & Shadows
  static BoxShadow get cardShadow => BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
      );

  static BoxShadow get glowShadow => BoxShadow(
        color: accentCyan.withOpacity(0.3),
        blurRadius: 12,
        spreadRadius: 2,
      );

  // Typography
  static const TextStyle sectionHeader = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: primaryText,
  );

  static const TextStyle metricValue = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: primaryText,
  );

  static const TextStyle metricLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: secondaryText,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: primaryText,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: secondaryText,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: accentCyan,
  );

  // Icon sizes
  static const double metricIconSize = 24.0;
  static const double sectionIconSize = 20.0;
  static const double badgeIconSize = 32.0;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
}
