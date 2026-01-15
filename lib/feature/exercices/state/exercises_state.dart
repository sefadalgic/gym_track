import 'package:gym_track/core/base/base_state.dart';
import 'package:gym_track/product/model/exercise_model.dart';
import 'package:gym_track/product/model/muscle_group.dart';

/// State for the exercises feature
class ExercisesState extends BaseState {
  /// List of all exercises
  final List<ExerciseModel> exercises;

  /// Currently selected muscle group filter (null = show all)
  final MuscleGroup? selectedMuscleGroup;

  /// Filtered exercises based on selected muscle group
  List<ExerciseModel> get filteredExercises {
    if (selectedMuscleGroup == null) {
      return exercises;
    }
    return exercises
        .where((exercise) =>
            exercise.primaryMuscles?.contains(selectedMuscleGroup) ?? false)
        .toList();
  }

  /// Whether exercises list is empty
  bool get isEmpty => exercises.isEmpty;

  /// Whether filtered list is empty
  bool get isFilteredEmpty => filteredExercises.isEmpty;

  const ExercisesState({
    this.exercises = const [],
    this.selectedMuscleGroup,
    super.isLoading = false,
    super.error,
  });

  @override
  List<Object?> get props => [
        exercises,
        selectedMuscleGroup,
        isLoading,
        error,
      ];

  /// Create a copy of the state with updated fields
  ExercisesState copyWith({
    List<ExerciseModel>? exercises,
    MuscleGroup? selectedMuscleGroup,
    bool? isLoading,
    String? error,
    bool clearFilter = false,
    bool clearError = false,
  }) {
    return ExercisesState(
      exercises: exercises ?? this.exercises,
      selectedMuscleGroup: clearFilter
          ? null
          : (selectedMuscleGroup ?? this.selectedMuscleGroup),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
