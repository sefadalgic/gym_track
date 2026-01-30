import 'package:equatable/equatable.dart';
import 'package:gym_track/core/constants/enums/days.dart';
import 'package:gym_track/product/model/workout_exercise_model.dart';

/// State for workout creation flow
class CreateWorkoutState extends Equatable {
  final String workoutName;
  final Set<Days> selectedDays;
  final Map<Days, List<WorkoutExerciseModel>> dayExercises;
  final int currentStep;
  final bool isLoading;
  final String? error;
  final bool isSaved;

  const CreateWorkoutState({
    this.workoutName = '',
    this.selectedDays = const {},
    this.dayExercises = const {},
    this.currentStep = 0,
    this.isLoading = false,
    this.error,
    this.isSaved = false,
  });

  CreateWorkoutState copyWith({
    String? workoutName,
    Set<Days>? selectedDays,
    Map<Days, List<WorkoutExerciseModel>>? dayExercises,
    int? currentStep,
    bool? isLoading,
    String? error,
    bool? isSaved,
  }) {
    return CreateWorkoutState(
      workoutName: workoutName ?? this.workoutName,
      selectedDays: selectedDays ?? this.selectedDays,
      dayExercises: dayExercises ?? this.dayExercises,
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  /// Clear error
  CreateWorkoutState clearError() {
    return copyWith(error: null);
  }

  /// Check if current step is valid
  bool get isCurrentStepValid {
    switch (currentStep) {
      case 0: // Name step
        return workoutName.trim().isNotEmpty;
      case 1: // Day selection step
        return selectedDays.isNotEmpty;
      case 2: // Exercise selection step
        // All selected days should have at least one exercise
        for (var day in selectedDays) {
          if (!dayExercises.containsKey(day) || dayExercises[day]!.isEmpty) {
            return false;
          }
        }
        return true;
      case 3: // Sets/reps configuration step
        // All exercises should have valid sets and reps
        for (var exercises in dayExercises.values) {
          for (var exercise in exercises) {
            if (!exercise.isValid) return false;
          }
        }
        return true;
      case 4: // Review step
        return isWorkoutValid;
      default:
        return false;
    }
  }

  /// Check if entire workout is valid
  bool get isWorkoutValid {
    if (workoutName.trim().isEmpty) return false;
    if (selectedDays.isEmpty) return false;
    if (dayExercises.isEmpty) return false;

    // Check all selected days have exercises
    for (var day in selectedDays) {
      if (!dayExercises.containsKey(day) || dayExercises[day]!.isEmpty) {
        return false;
      }
    }

    // Check all exercises are valid
    for (var exercises in dayExercises.values) {
      for (var exercise in exercises) {
        if (!exercise.isValid) return false;
      }
    }

    return true;
  }

  /// Get total number of exercises
  int get totalExercises {
    return dayExercises.values.fold(0, (sum, list) => sum + list.length);
  }

  /// Get exercises for a specific day
  List<WorkoutExerciseModel> getExercisesForDay(Days day) {
    return dayExercises[day] ?? [];
  }

  @override
  List<Object?> get props => [
        workoutName,
        selectedDays,
        dayExercises,
        currentStep,
        isLoading,
        error,
        isSaved,
      ];
}
