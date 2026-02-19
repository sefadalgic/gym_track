import 'package:flutter/material.dart';
import 'package:gym_track/core/constants/app/padding_constants.dart';
import 'package:gym_track/core/constants/image/image_constants.dart';

/// Mixin that provides common functionality for all StatefulWidget states.
///
/// This mixin can be mixed into any `State<T>` class to provide access to:
/// - [padding]: Responsive padding constants
/// - [images]: Image path constants
///
/// Example usage:
/// ```dart
/// class _MyWidgetState xtends State<MyWidget> with BaseWidgetMixin {
///   @override
///   Widget build(BuildContext context) {
///     return Padding(
///       padding: padding.all,
///       child: Image.asset(images.logo),
///     );
///   }
/// }
/// ```
mixin BaseWidgetMixin<T extends StatefulWidget> on State<T> {
  /// Access to responsive padding constants
  PaddingConstants get padding => PaddingConstants.instance;

  /// Access to image path constants
  ImageConstants get images => ImageConstants.instance;
}
