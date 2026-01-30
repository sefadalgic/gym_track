import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_track/core/constants/enums/days.dart';
import 'package:gym_track/feature/workouts/state/create_workout_event.dart';
import 'package:gym_track/feature/workouts/state/create_workout_state.dart';
import 'package:gym_track/product/model/workout_exercise_model.dart';
import 'package:gym_track/product/model/workout_model.dart';
import 'package:gym_track/product/service/firestore_service.dart';

/// BLoC for managing workout creation flow
class CreateWorkoutBloc extends Bloc<CreateWorkoutEvent, CreateWorkoutState> {
  final FirestoreService _firestoreService;

  CreateWorkoutBloc({
    FirestoreService? firestoreService,
  })  : _firestoreService = firestoreService ?? FirestoreService.instance,
        super(const CreateWorkoutState()) {
    on<WorkoutNameChanged>(_onWorkoutNameChanged);
    on<DayToggled>(_onDayToggled);
    on<ExerciseAddedToDay>(_onExerciseAddedToDay);
    on<ExerciseRemovedFromDay>(_onExerciseRemovedFromDay);
    on<ExerciseSetsChanged>(_onExerciseSetsChanged);
    on<ExerciseRepsChanged>(_onExerciseRepsChanged);
    on<NextStepRequested>(_onNextStepRequested);
    on<PreviousStepRequested>(_onPreviousStepRequested);
    on<StepChanged>(_onStepChanged);
    on<WorkoutSaveRequested>(_onWorkoutSaveRequested);
    on<WorkoutCreationReset>(_onWorkoutCreationReset);
    on<ExercisesReordered>(_onExercisesReordered);
  }

  void _onWorkoutNameChanged(
    WorkoutNameChanged event,
    Emitter<CreateWorkoutState> emit,
  ) {
    emit(state.copyWith(workoutName: event.name));
  }

  void _onDayToggled(
    DayToggled event,
    Emitter<CreateWorkoutState> emit,
  ) {
    final newSelectedDays = Set<Days>.from(state.selectedDays);
    final newDayExercises =
        Map<Days, List<WorkoutExerciseModel>>.from(state.dayExercises);

    if (newSelectedDays.contains(event.day)) {
      // Remove day
      newSelectedDays.remove(event.day);
      newDayExercises.remove(event.day);
    } else {
      // Add day
      newSelectedDays.add(event.day);
      if (!newDayExercises.containsKey(event.day)) {
        newDayExercises[event.day] = [];
      }
    }

    emit(state.copyWith(
      selectedDays: newSelectedDays,
      dayExercises: newDayExercises,
    ));
  }

  void _onExerciseAddedToDay(
    ExerciseAddedToDay event,
    Emitter<CreateWorkoutState> emit,
  ) {
    final newDayExercises =
        Map<Days, List<WorkoutExerciseModel>>.from(state.dayExercises);

    if (!newDayExercises.containsKey(event.day)) {
      newDayExercises[event.day] = [];
    }

    // Check if exercise already exists
    final existingIndex = newDayExercises[event.day]!
        .indexWhere((e) => e.exerciseId == event.exercise.exerciseId);

    if (existingIndex == -1) {
      // Add new exercise
      newDayExercises[event.day] = [
        ...newDayExercises[event.day]!,
        event.exercise,
      ];
    }

    emit(state.copyWith(dayExercises: newDayExercises));
  }

  void _onExerciseRemovedFromDay(
    ExerciseRemovedFromDay event,
    Emitter<CreateWorkoutState> emit,
  ) {
    final newDayExercises =
        Map<Days, List<WorkoutExerciseModel>>.from(state.dayExercises);

    if (newDayExercises.containsKey(event.day)) {
      newDayExercises[event.day] = newDayExercises[event.day]!
          .where((e) => e.exerciseId != event.exerciseId)
          .toList();
    }

    emit(state.copyWith(dayExercises: newDayExercises));
  }

  void _onExerciseSetsChanged(
    ExerciseSetsChanged event,
    Emitter<CreateWorkoutState> emit,
  ) {
    final newDayExercises =
        Map<Days, List<WorkoutExerciseModel>>.from(state.dayExercises);

    if (newDayExercises.containsKey(event.day)) {
      newDayExercises[event.day] = newDayExercises[event.day]!.map((exercise) {
        if (exercise.exerciseId == event.exerciseId) {
          return exercise.copyWith(sets: event.sets);
        }
        return exercise;
      }).toList();
    }

    emit(state.copyWith(dayExercises: newDayExercises));
  }

  void _onExerciseRepsChanged(
    ExerciseRepsChanged event,
    Emitter<CreateWorkoutState> emit,
  ) {
    final newDayExercises =
        Map<Days, List<WorkoutExerciseModel>>.from(state.dayExercises);

    if (newDayExercises.containsKey(event.day)) {
      newDayExercises[event.day] = newDayExercises[event.day]!.map((exercise) {
        if (exercise.exerciseId == event.exerciseId) {
          return exercise.copyWith(reps: event.reps);
        }
        return exercise;
      }).toList();
    }

    emit(state.copyWith(dayExercises: newDayExercises));
  }

  void _onNextStepRequested(
    NextStepRequested event,
    Emitter<CreateWorkoutState> emit,
  ) {
    if (!state.isCurrentStepValid) {
      emit(state.copyWith(
          error: 'Please complete the current step before proceeding'));
      return;
    }

    if (state.currentStep < 4) {
      emit(state.copyWith(
        currentStep: state.currentStep + 1,
        error: null,
      ));
    }
  }

  void _onPreviousStepRequested(
    PreviousStepRequested event,
    Emitter<CreateWorkoutState> emit,
  ) {
    if (state.currentStep > 0) {
      emit(state.copyWith(
        currentStep: state.currentStep - 1,
        error: null,
      ));
    }
  }

  void _onStepChanged(
    StepChanged event,
    Emitter<CreateWorkoutState> emit,
  ) {
    if (event.step >= 0 && event.step <= 4) {
      emit(state.copyWith(
        currentStep: event.step,
        error: null,
      ));
    }
  }

  Future<void> _onWorkoutSaveRequested(
    WorkoutSaveRequested event,
    Emitter<CreateWorkoutState> emit,
  ) async {
    if (!state.isWorkoutValid) {
      emit(state.copyWith(error: 'Please complete all required fields'));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    try {
      final workout = WorkoutModel(
        name: state.workoutName,
        createdAt: DateTime.now().toIso8601String(),
        isActive: true,
        exercises: state.dayExercises,
      );

      await _firestoreService.createWorkout(workout);

      emit(state.copyWith(
        isLoading: false,
        isSaved: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to save workout: ${e.toString()}',
      ));
    }
  }

  void _onWorkoutCreationReset(
    WorkoutCreationReset event,
    Emitter<CreateWorkoutState> emit,
  ) {
    emit(const CreateWorkoutState());
  }

  void _onExercisesReordered(
    ExercisesReordered event,
    Emitter<CreateWorkoutState> emit,
  ) {
    final newDayExercises =
        Map<Days, List<WorkoutExerciseModel>>.from(state.dayExercises);

    if (newDayExercises.containsKey(event.day)) {
      final exercises =
          List<WorkoutExerciseModel>.from(newDayExercises[event.day]!);
      final exercise = exercises.removeAt(event.oldIndex);
      exercises.insert(event.newIndex, exercise);
      newDayExercises[event.day] = exercises;
    }

    emit(state.copyWith(dayExercises: newDayExercises));
  }
}
