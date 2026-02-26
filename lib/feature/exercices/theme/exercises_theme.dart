import 'package:flutter/material.dart';
import 'package:gym_track/core/thene/app_theme.dart';

/// Theme constants for the Exercises feature, aligned with global AppTheme
class ExercisesTheme {
  // Colors - Referencing AppTheme
  static const Color background = AppTheme.background;
  static const Color surface = AppTheme.cardBackground;
  static const Color surfaceHighlight = Color(0xFF262626);
  static const Color primary = AppTheme.primary;
  static const Color secondary = AppTheme.secondary;
  static const Color textPrimary = AppTheme.textPrimary;
  static const Color textSecondary = AppTheme.textSecondary;
  static const Color accentGreen =
      AppTheme.primary; // Reverting to primary orange

  // Difficulty Colors
  static const Color beginner = Color(0xFF10B981); // Keep functional colors
  static const Color intermediate = Color(0xFFF59E0B);
  static const Color advanced = Color(0xFFEF4444);

  // Gradients
  static const LinearGradient cardGradient = AppTheme.darkGradient;

  static const LinearGradient activeChipGradient = LinearGradient(
    colors: [
      AppTheme.primary,
      Color(0xFFFF8E64),
    ],
  );

  // Shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.2),
          blurRadius: 15,
          spreadRadius: 2,
        ),
      ];

  // Text Styles - Standardizing with TextTheme
  static const TextStyle title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static const TextStyle chipLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static const TextStyle stepNumber = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: primary,
  );

  static const TextStyle statValue = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: textPrimary,
  );

  static const TextStyle statLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: textSecondary,
  );

  // Spacing & Border Radius
  static const double cardRadius = 16.0; // Align with AppTheme card radius
  static const double imageRadius = 12.0;
  static const double chipRadius = 20.0;
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(20, 0, 20, 0);
}
