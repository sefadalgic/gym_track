// This file demonstrates how to use the BaseView, BaseBloc, and BaseState classes
// Delete this file once you understand the pattern

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'base_bloc.dart';
import 'base_state.dart';
import 'base_view.dart';

// ============================================================================
// STEP 1: Define Events
// ============================================================================

/// Base event class for the counter feature
abstract class CounterEvent extends Equatable {
  const CounterEvent();

  @override
  List<Object?> get props => [];
}

/// Event to increment the counter
class CounterIncremented extends CounterEvent {
  const CounterIncremented();
}

/// Event to decrement the counter
class CounterDecremented extends CounterEvent {
  const CounterDecremented();
}

/// Event to reset the counter
class CounterReset extends CounterEvent {
  const CounterReset();
}

// ============================================================================
// STEP 2: Define State
// ============================================================================

/// State for the counter feature
/// Extends BaseState to inherit loading and error properties
class CounterState extends BaseState {
  final int count;

  const CounterState({
    this.count = 0,
    super.isLoading = false,
    super.error,
  });

  /// Creates a copy of this state with updated values
  CounterState copyWith({
    int? count,
    bool? isLoading,
    String? error,
  }) {
    return CounterState(
      count: count ?? this.count,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [count, isLoading, error];
}

// ============================================================================
// STEP 3: Define BLoC
// ============================================================================

/// BLoC for managing counter state
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState()) {
    on<CounterIncremented>(_onIncremented);
    on<CounterDecremented>(_onDecremented);
    on<CounterReset>(_onReset);
  }

  Future<void> _onIncremented(
    CounterIncremented event,
    Emitter<CounterState> emit,
  ) async {
    // Simulate async operation
    emit(state.copyWith(isLoading: true));
    await Future.delayed(const Duration(milliseconds: 300));
    emit(state.copyWith(count: state.count + 1, isLoading: false));
  }

  Future<void> _onDecremented(
    CounterDecremented event,
    Emitter<CounterState> emit,
  ) async {
    if (state.count > 0) {
      emit(state.copyWith(isLoading: true));
      await Future.delayed(const Duration(milliseconds: 300));
      emit(state.copyWith(count: state.count - 1, isLoading: false));
    } else {
      emit(state.copyWith(error: 'Cannot go below zero!'));
      // Clear error after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      emit(state.copyWith(error: null));
    }
  }

  Future<void> _onReset(
    CounterReset event,
    Emitter<CounterState> emit,
  ) async {
    emit(state.copyWith(count: 0, error: null));
  }
}

// ============================================================================
// STEP 4: Define View
// ============================================================================

/// Example view using BaseView
class CounterView extends BaseView<CounterBloc, CounterState> {
  const CounterView({super.key});

  @override
  CounterBloc createBloc(BuildContext context) => CounterBloc();

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, CounterState state) {
    return AppBar(
      title: const Text('Counter Example'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            context.read<CounterBloc>().add(const CounterReset());
          },
        ),
      ],
    );
  }

  @override
  bool isLoading(CounterState state) => state.isLoading;

  @override
  String? getErrorMessage(CounterState state) => state.error;

  @override
  void onStateChanged(BuildContext context, CounterState state) {
    // Show snackbar when error occurs
    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget buildView(BuildContext context, CounterState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'You have pushed the button this many times:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Text(
            '${state.count}',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                heroTag: 'decrement',
                onPressed: () {
                  context.read<CounterBloc>().add(const CounterDecremented());
                },
                child: const Icon(Icons.remove),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                heroTag: 'increment',
                onPressed: () {
                  context.read<CounterBloc>().add(const CounterIncremented());
                },
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
