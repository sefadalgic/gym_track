import 'package:equatable/equatable.dart';
import 'package:gym_track/core/constants/enums/days.dart';
import 'package:gym_track/product/model/workout_exercise_model.dart';

/// Events for workout creation flow
abstract class CreateWorkoutEvent extends Equatable {
  const CreateWorkoutEvent();

  @override
  List<Object?> get props => [];
}

/// Update workout name
class WorkoutNameChanged extends CreateWorkoutEvent {
  final String name;

  const WorkoutNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

/// Toggle a training day (add/remove)
class DayToggled extends CreateWorkoutEvent {
  final Days day;

  const DayToggled(this.day);

  @override
  List<Object?> get props => [day];
}

/// Add exercise to a specific day
class ExerciseAddedToDay extends CreateWorkoutEvent {
  final Days day;
  final WorkoutExerciseModel exercise;

  const ExerciseAddedToDay({
    required this.day,
    required this.exercise,
  });

  @override
  List<Object?> get props => [day, exercise];
}

/// Remove exercise from a specific day
class ExerciseRemovedFromDay extends CreateWorkoutEvent {
  final Days day;
  final String exerciseId;

  const ExerciseRemovedFromDay({
    required this.day,
    required this.exerciseId,
  });

  @override
  List<Object?> get props => [day, exerciseId];
}

/// Update sets for an exercise
class ExerciseSetsChanged extends CreateWorkoutEvent {
  final Days day;
  final String exerciseId;
  final int sets;

  const ExerciseSetsChanged({
    required this.day,
    required this.exerciseId,
    required this.sets,
  });

  @override
  List<Object?> get props => [day, exerciseId, sets];
}

/// Update reps for an exercise
class ExerciseRepsChanged extends CreateWorkoutEvent {
  final Days day;
  final String exerciseId;
  final int reps;

  const ExerciseRepsChanged({
    required this.day,
    required this.exerciseId,
    required this.reps,
  });

  @override
  List<Object?> get props => [day, exerciseId, reps];
}

/// Move to next step
class NextStepRequested extends CreateWorkoutEvent {
  const NextStepRequested();
}

/// Move to previous step
class PreviousStepRequested extends CreateWorkoutEvent {
  const PreviousStepRequested();
}

/// Jump to specific step
class StepChanged extends CreateWorkoutEvent {
  final int step;

  const StepChanged(this.step);

  @override
  List<Object?> get props => [step];
}

/// Save workout to Firestore
class WorkoutSaveRequested extends CreateWorkoutEvent {
  const WorkoutSaveRequested();
}

/// Reset workout creation to initial state
class WorkoutCreationReset extends CreateWorkoutEvent {
  const WorkoutCreationReset();
}

/// Reorder exercises within a day
class ExercisesReordered extends CreateWorkoutEvent {
  final Days day;
  final int oldIndex;
  final int newIndex;

  const ExercisesReordered({
    required this.day,
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  List<Object?> get props => [day, oldIndex, newIndex];
}
