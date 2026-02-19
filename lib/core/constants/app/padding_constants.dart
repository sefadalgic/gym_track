import 'package:flutter/material.dart';

class PaddingConstants {
  static PaddingConstants? _instance;
  static PaddingConstants get instance {
    _instance ??= PaddingConstants._init();
    return _instance!;
  }

  PaddingConstants._init();

  // Standard design width used as a baseline for scaling
  static const double _designWidth = 375.0;

  /// Scales a value based on the current screen width relative to the design width.
  double _scale(BuildContext context, double value) {
    final double currentWidth = MediaQuery.sizeOf(context).width;
    return (value / _designWidth) * currentWidth;
  }

  // Base responsive values
  double extraSmall(BuildContext context) => _scale(context, 4.0);
  double small(BuildContext context) => _scale(context, 8.0);
  double regular(BuildContext context) => _scale(context, 12.0);
  double medium(BuildContext context) => _scale(context, 16.0);
  double large(BuildContext context) => _scale(context, 24.0);
  double extraLarge(BuildContext context) => _scale(context, 32.0);
  double xxLarge(BuildContext context) => _scale(context, 40.0);

  // Responsive EdgeInsets helpers

  /// Returns [EdgeInsets.all] with the scaled value.
  EdgeInsets all(BuildContext context, double value) {
    return EdgeInsets.all(_scale(context, value));
  }

  /// Returns [EdgeInsets.symmetric] with scaled horizontal and vertical values.
  EdgeInsets symmetric(
    BuildContext context, {
    double horizontal = 0.0,
    double vertical = 0.0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: _scale(context, horizontal),
      vertical: _scale(context, vertical),
    );
  }

  /// Returns [EdgeInsets.only] with scaled values for each side.
  EdgeInsets only(
    BuildContext context, {
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return EdgeInsets.only(
      left: _scale(context, left),
      top: _scale(context, top),
      right: _scale(context, right),
      bottom: _scale(context, bottom),
    );
  }
}
