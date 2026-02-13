import 'package:flutter/material.dart';

class ColorConstants {
  ColorConstants._();

  static final ColorConstants _instance = ColorConstants._();

  static ColorConstants get instance => _instance;

  final Color background = const Color(0xFF102216);
  final Color backgroundAlt = const Color(0xFF0A0E21);
  final Color backgroundSecondary = const Color(0xFF1A1F3A);
  final Color backgroundTertiary = const Color(0xFF12161C);

  final Color surface = const Color(0xFF151A21);
  final Color surfaceHighlight = const Color(0xFF1E252E);
  final Color surfaceAlt = const Color(0xFF1C2128);

  final Color primary = const Color(0xFF00D9FF);
  final Color primaryAlt = const Color(0xFF00D4FF);
  final Color primaryDark = const Color(0xFF00B8D4);
  final Color primaryDarker = const Color(0xFF0099FF);
  final Color accentGreen = const Color(0xFF4CAF50);
  final Color accentGreenLight = const Color(0xFF81C784);

  final Color textPrimary = const Color(0xFFFFFFFF);
  final Color textSecondary = const Color(0xFF8A8F98);
  final Color textTertiary = const Color(0xFF8E9CB8);
  final Color textDisabled = const Color(0xFF5A5F68);

  final Color success = const Color(0xFF4CAF50);
  final Color warning = const Color(0xFFFFA726);
  final Color error = const Color(0xFFEF5350);
  final Color info = const Color(0xFF29B6F6);

  final Color border = const Color(0xFF2A2F38);
  final Color divider = const Color(0xFF1E252E);

  final Color overlayDark = const Color(0xCC000000);
  final Color overlayLight = const Color(0x33FFFFFF);

  LinearGradient get primaryGradient => LinearGradient(
        colors: [primary, primaryDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get backgroundGradient => LinearGradient(
        colors: [backgroundAlt, backgroundSecondary, backgroundAlt],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  LinearGradient get surfaceGradient => LinearGradient(
        colors: [surface, backgroundTertiary],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  Color primaryWithOpacity(double opacity) {
    return primary.withOpacity(opacity);
  }

  Color surfaceWithOpacity(double opacity) {
    return surface.withOpacity(opacity);
  }

  Color textSecondaryWithOpacity(double opacity) {
    return textSecondary.withOpacity(opacity);
  }
}
