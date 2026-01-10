import 'package:flutter_bloc/flutter_bloc.dart';
import 'base_state.dart';

/// Base BLoC class for all BLoCs in the application.
///
/// Provides common functionality:
/// - Error handling utilities
/// - Loading state management
/// - Lifecycle logging (in debug mode)
///
/// Type parameters:
/// - [E]: Event type
/// - [S]: State type (must extend BaseState)
///
/// Example:
/// ```dart
/// class LoginBloc extends BaseBloc<LoginEvent, LoginState> {
///   final AuthRepository _authRepository;
///
///   LoginBloc(this._authRepository) : super(const LoginState()) {
///     on<LoginSubmitted>(_onLoginSubmitted);
///   }
///
///   Future<void> _onLoginSubmitted(
///     LoginSubmitted event,
///     Emitter<LoginState> emit,
///   ) async {
///     await handleAsync(
///       emit: emit,
///       action: () async {
///         final user = await _authRepository.login(
///           email: event.email,
///           password: event.password,
///         );
///         emit(state.copyWith(isAuthenticated: true, user: user));
///       },
///     );
///   }
/// }
/// ```
abstract class BaseBloc<E, S extends BaseState> extends Bloc<E, S> {
  BaseBloc(super.initialState) {
    _logLifecycle('Created');
  }

  /// Handles async operations with automatic loading and error state management.
  ///
  /// This method:
  /// 1. Sets loading state to true
  /// 2. Executes the provided action
  /// 3. Sets loading state to false on completion
  /// 4. Catches errors and updates error state
  ///
  /// Parameters:
  /// - [emit]: The state emitter
  /// - [action]: The async operation to execute
  /// - [loadingState]: Optional custom loading state (defaults to current state with isLoading=true)
  Future<void> handleAsync({
    required Emitter<S> emit,
    required Future<void> Function() action,
    S? loadingState,
  }) async {
    try {
      // Emit loading state
      if (loadingState != null) {
        emit(loadingState);
      } else {
        emit(_copyWithLoading(state, true) as S);
      }

      // Execute action
      await action();
    } catch (e) {
      // Emit error state
      emit(_copyWithError(state, e.toString()) as S);
      _logError(e);
    }
  }

  /// Creates a copy of the state with updated loading status.
  ///
  /// Override this if your state has a custom copyWith method.
  BaseState _copyWithLoading(S state, bool isLoading) {
    // This is a fallback implementation
    // Child classes should override this or ensure their state has a proper copyWith
    throw UnimplementedError(
      'State must implement copyWith method or override _copyWithLoading',
    );
  }

  /// Creates a copy of the state with updated error message.
  ///
  /// Override this if your state has a custom copyWith method.
  BaseState _copyWithError(S state, String error) {
    // This is a fallback implementation
    // Child classes should override this or ensure their state has a proper copyWith
    throw UnimplementedError(
      'State must implement copyWith method or override _copyWithError',
    );
  }

  void _logLifecycle(String message) {
    assert(() {
      // ignore: avoid_print
      print('[$runtimeType] $message');
      return true;
    }());
  }

  void _logError(Object error) {
    assert(() {
      // ignore: avoid_print
      print('[$runtimeType] Error: $error');
      return true;
    }());
  }

  @override
  Future<void> close() {
    _logLifecycle('Closed');
    return super.close();
  }
}
