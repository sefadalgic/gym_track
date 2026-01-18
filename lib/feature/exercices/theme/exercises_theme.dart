import 'package:flutter/material.dart';

/// Theme constants for the Exercises feature
class ExercisesTheme {
  // Colors
  static const Color background = Color(0xFF0A0E14);
  static const Color surface = Color(0xFF151A21);
  static const Color surfaceHighlight = Color(0xFF1E252E);
  static const Color primary = Color(0xFF00D9FF); // Cyan accent
  static const Color secondary = Color(0xFF7C8591);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8F98);

  // Difficulty Colors
  static const Color beginner = Color(0xFF00FF88);
  static const Color intermediate = Color(0xFFFFB800);
  static const Color advanced = Color(0xFFFF4757);

  // Gradients
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF151A21),
      Color(0xFF12161C),
    ],
  );

  static const LinearGradient activeChipGradient = LinearGradient(
    colors: [
      Color(0xFF00D9FF),
      Color(0xFF00B8D4),
    ],
  );

  // Shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.25),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ];

  // Text Styles
  static const TextStyle title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  // Spacing & Border Radius
  static const double cardRadius = 16.0;
  static const double chipRadius = 24.0;
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(20, 0, 20, 0);
}
