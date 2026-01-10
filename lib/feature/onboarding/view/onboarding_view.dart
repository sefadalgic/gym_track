import 'package:flutter/material.dart';
import 'package:gym_track/core/base/base_view.dart';
import '../state/onboarding_bloc.dart';
import '../state/onboarding_event.dart';
import '../state/onboarding_state.dart';

/// Onboarding view - Optimized with const and BlocBuilder
class OnboardingView extends BaseView<OnboardingBloc, OnboardingState> {
  const OnboardingView({super.key});

  @override
  OnboardingBloc createBloc(BuildContext context) {
    return OnboardingBloc()..add(const OnboardingStarted());
  }

  @override
  Widget buildView(BuildContext context, OnboardingState state) {
    return Column(
      children: [],
    );
  }
}
