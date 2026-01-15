import 'package:equatable/equatable.dart';
import 'package:gym_track/product/model/muscle_group.dart';

/// Base class for all exercises events
abstract class ExercisesEvent extends Equatable {
  const ExercisesEvent();

  @override
  List<Object?> get props => [];
}

/// Event to request loading exercises from the API
class ExercisesLoadRequested extends ExercisesEvent {
  const ExercisesLoadRequested();
}

/// Event to refresh exercises (pull-to-refresh)
class ExercisesRefreshRequested extends ExercisesEvent {
  const ExercisesRefreshRequested();
}

/// Event to filter exercises by muscle group
class ExercisesFilterChanged extends ExercisesEvent {
  final MuscleGroup? muscleGroup;

  const ExercisesFilterChanged(this.muscleGroup);

  @override
  List<Object?> get props => [muscleGroup];
}

/// Event when an exercise is selected
class ExerciseSelected extends ExercisesEvent {
  final String exerciseId;

  const ExerciseSelected(this.exerciseId);

  @override
  List<Object?> get props => [exerciseId];
}
