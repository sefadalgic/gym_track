import 'package:gym_track/core/base/base_state.dart';

/// State for onboarding feature
/// Extends BaseState to inherit isLoading and error properties
class OnboardingState extends BaseState {
  /// Current page index (0-based)
  final int currentPage;

  /// Total number of onboarding pages
  final int totalPages;

  /// Whether onboarding has been completed
  final bool isCompleted;

  const OnboardingState({
    this.currentPage = 0,
    this.totalPages = 3,
    this.isCompleted = false,
    super.isLoading = false,
    super.error,
  });

  /// Creates a copy of this state with updated values
  OnboardingState copyWith({
    int? currentPage,
    int? totalPages,
    bool? isCompleted,
    bool? isLoading,
    String? error,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Whether user is on the last page
  bool get isLastPage => currentPage >= totalPages - 1;

  /// Whether user can go to next page
  bool get canGoNext => currentPage < totalPages - 1;

  /// Whether user can go to previous page
  bool get canGoPrevious => currentPage > 0;

  @override
  List<Object?> get props => [
        currentPage,
        totalPages,
        isCompleted,
        isLoading,
        error,
      ];
}
