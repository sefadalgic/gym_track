import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

/// BLoC for managing onboarding state
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingState()) {
    on<OnboardingStarted>(_onStarted);
    on<OnboardingPageChanged>(_onPageChanged);
    on<OnboardingCompleted>(_onCompleted);
    on<OnboardingSkipped>(_onSkipped);
  }

  /// Handle onboarding started event
  void _onStarted(
    OnboardingStarted event,
    Emitter<OnboardingState> emit,
  ) {
    emit(const OnboardingState());
  }

  /// Handle page change event
  void _onPageChanged(
    OnboardingPageChanged event,
    Emitter<OnboardingState> emit,
  ) {
    // Validate page index
    if (event.pageIndex < 0 || event.pageIndex >= state.totalPages) {
      emit(state.copyWith(
        error: 'Invalid page index: ${event.pageIndex}',
      ));
      return;
    }

    emit(state.copyWith(
      currentPage: event.pageIndex,
      error: null,
    ));
  }

  /// Handle onboarding completed event
  void _onCompleted(
    OnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(
      isCompleted: true,
      error: null,
    ));
  }

  /// Handle onboarding skipped event
  void _onSkipped(
    OnboardingSkipped event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(
      isCompleted: true,
      error: null,
    ));
  }
}
