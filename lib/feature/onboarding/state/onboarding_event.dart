import 'package:equatable/equatable.dart';

/// Base event class for onboarding feature
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when onboarding is started
class OnboardingStarted extends OnboardingEvent {
  const OnboardingStarted();
}

/// Event triggered when user navigates to a different page
class OnboardingPageChanged extends OnboardingEvent {
  final int pageIndex;

  const OnboardingPageChanged(this.pageIndex);

  @override
  List<Object?> get props => [pageIndex];
}

/// Event triggered when user completes onboarding
class OnboardingCompleted extends OnboardingEvent {
  const OnboardingCompleted();
}

/// Event triggered when user skips onboarding
class OnboardingSkipped extends OnboardingEvent {
  const OnboardingSkipped();
}
