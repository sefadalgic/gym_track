import 'package:equatable/equatable.dart';
import 'package:gym_track/core/constants/image/image_constants.dart';

/// Base state class for all BLoC states in the application.
///
/// Provides common state properties:
/// - [isLoading]: Indicates if an operation is in progress
/// - [error]: Contains error message if an error occurred
///
/// All states should extend this class and use Equatable for value comparison.
///
/// Example:
/// ```dart
/// class LoginState extends BaseState {
///   final bool isAuthenticated;
///
///   const LoginState({
///     this.isAuthenticated = false,
///     super.isLoading = false,
///     super.error,
///   });
///
///   @override
///   List<Object?> get props => [isAuthenticated, isLoading, error];
///
///   LoginState copyWith({
///     bool? isAuthenticated,
///     bool? isLoading,
///     String? error,
///   }) {
///     return LoginState(
///       isAuthenticated: isAuthenticated ?? this.isAuthenticated,
///       isLoading: isLoading ?? this.isLoading,
///       error: error ?? this.error,
///     );
///   }
/// }
/// ```
abstract class BaseState extends Equatable {
  /// Indicates if an operation is currently in progress
  final bool isLoading;

  /// Contains error message if an error occurred, null otherwise
  final String? error;

  const BaseState({
    this.isLoading = false,
    this.error,
  });

  @override
  List<Object?> get props => [isLoading, error];
}
