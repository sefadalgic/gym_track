import 'package:flutter/material.dart';

/// Theme constants for the Login feature
class LoginTheme {
  // Colors
  static const Color background = Color(0xFF0A0E14);
  static const Color surface = Color(0xFF151A21);
  static const Color surfaceHighlight = Color(0xFF1E252E);
  static const Color primary = Color(0xFF00D9FF); // Cyan accent
  static const Color primaryDark = Color(0xFF00B8D4);
  static const Color secondary = Color(0xFF7C8591);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8F98);
  static const Color error = Color(0xFFFF4757);
  static const Color success = Color(0xFF00FF88);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A0E14),
      Color(0xFF151A21),
      Color(0xFF0A0E14),
    ],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [
      Color(0xFF00D9FF),
      Color(0xFF00B8D4),
    ],
  );

  static const LinearGradient inputGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E252E),
      Color(0xFF151A21),
    ],
  );

  // Shadows
  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get inputShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.4),
          blurRadius: 30,
          spreadRadius: 5,
        ),
      ];

  // Text Styles
  static const TextStyle title = TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -1.5,
    height: 1.2,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Color(0xFF0A0E14),
    letterSpacing: 1,
  );

  static const TextStyle inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle linkText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: primary,
    decoration: TextDecoration.none,
  );

  // Spacing & Border Radius
  static const double buttonRadius = 16.0;
  static const double inputRadius = 12.0;
  static const double buttonHeight = 56.0;
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 24.0);
}
