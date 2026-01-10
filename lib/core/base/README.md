# BLoC Base Classes

This directory contains base classes for implementing the BLoC (Business Logic Component) pattern in the gym_track application.

## Files

- **`base_view.dart`** - Base widget for all screens using BLoC
- **`base_bloc.dart`** - Base BLoC with common functionality
- **`base_state.dart`** - Base state with loading and error properties
- **`base_model.dart`** - Base model for data serialization
- **`base.dart`** - Barrel export file for easy imports
- **`example_usage.dart`** - Complete example demonstrating the pattern

## Quick Start

### 1. Import the base classes

```dart
import 'package:gym_track/core/base/base.dart';
```

### 2. Define your events

```dart
abstract class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;
  
  const LoginSubmitted(this.email, this.password);
  
  @override
  List<Object?> get props => [email, password];
}
```

### 3. Define your state

```dart
class LoginState extends BaseState {
  final bool isAuthenticated;
  final User? user;

  const LoginState({
    this.isAuthenticated = false,
    this.user,
    super.isLoading = false,
    super.error,
  });

  LoginState copyWith({
    bool? isAuthenticated,
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return LoginState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isAuthenticated, user, isLoading, error];
}
```

### 4. Create your BLoC

```dart
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc(this._authRepository) : super(const LoginState()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(state.copyWith(
        isAuthenticated: true,
        user: user,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}
```

### 5. Create your view

```dart
class LoginView extends BaseView<LoginBloc, LoginState> {
  const LoginView({super.key});

  @override
  LoginBloc createBloc(BuildContext context) {
    return LoginBloc(context.read<AuthRepository>());
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, LoginState state) {
    return AppBar(title: const Text('Login'));
  }

  @override
  bool isLoading(LoginState state) => state.isLoading;

  @override
  String? getErrorMessage(LoginState state) => state.error;

  @override
  void onStateChanged(BuildContext context, LoginState state) {
    if (state.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget buildView(BuildContext context, LoginState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Email'),
            onChanged: (value) => _email = value,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            onChanged: (value) => _password = value,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<LoginBloc>().add(
                LoginSubmitted(_email, _password),
              );
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
```

## Features

### BaseView

- **Automatic BLoC lifecycle management** - BLoC is created and disposed automatically
- **Built-in loading state** - Override `isLoading()` to show loading indicator
- **Built-in error handling** - Override `getErrorMessage()` to show errors
- **Customizable UI components** - Override methods for app bar, FAB, etc.
- **State change listener** - Use `onStateChanged()` for side effects like navigation

### BaseState

- **Common properties** - `isLoading` and `error` available in all states
- **Equatable integration** - Efficient state comparison out of the box
- **Type-safe** - Strongly typed with generics

### BaseBloc

- **Async operation handling** - `handleAsync()` method for common async patterns
- **Debug logging** - Automatic lifecycle and error logging in debug mode
- **Error handling** - Centralized error handling

## Best Practices

1. **Always implement `copyWith`** - Your state classes should have a `copyWith` method
2. **Use Equatable** - Extend `Equatable` for events and states
3. **Keep BLoCs focused** - One BLoC per feature/screen
4. **Avoid UI logic in BLoC** - Keep BLoCs pure, handle UI in views
5. **Use repositories** - Inject repositories into BLoCs for data access

## Example

See `example_usage.dart` for a complete working example with a counter feature.

## Dependencies

```yaml
dependencies:
  bloc: ^9.1.0
  flutter_bloc: ^9.1.1
  equatable: ^2.0.7
```
