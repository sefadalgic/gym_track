import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_track/feature/exercices/state/exercises_event.dart';
import 'package:gym_track/feature/exercices/state/exercises_state.dart';
import 'package:gym_track/product/model/exercise_model.dart';
import 'package:gym_track/product/service/firestore_service.dart';

/// BLoC for managing exercises state
class ExercisesBloc extends Bloc<ExercisesEvent, ExercisesState> {
  final FirestoreService _firestoreService;

  ExercisesBloc({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService.instance,
        super(const ExercisesState()) {
    on<ExercisesLoadRequested>(_onLoadRequested);
    on<ExercisesRefreshRequested>(_onRefreshRequested);
    on<ExercisesFilterChanged>(_onFilterChanged);
    on<ExerciseSelected>(_onExerciseSelected);
  }

  /// Handle loading exercises from Firestore
  Future<void> _onLoadRequested(
    ExercisesLoadRequested event,
  Emitter<ExercisesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final exercises = await _firestoreService.getExercises();

      emit(state.copyWith(
        exercises: exercises,
        isLoading: false,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load exercises: ${e.toString()}',
      ));
    }
  }

  /// Handle refresh request
  Future<void> _onRefreshRequested(
    ExercisesRefreshRequested event,
    Emitter<ExercisesState> emit,
  ) async {
    // Reuse the load logic
    add(const ExercisesLoadRequested());
  }

  /// Handle filter change
  void _onFilterChanged(
    ExercisesFilterChanged event,
    Emitter<ExercisesState> emit,
  ) {
    if (event.muscleGroup == null) {
      emit(state.copyWith(clearFilter: true));
    } else {
      emit(state.copyWith(selectedMuscleGroup: event.muscleGroup));
    }
  }

  /// Handle exercise selection
  void _onExerciseSelected(
    ExerciseSelected event,
    Emitter<ExercisesState> emit,
  ) {
    // TODO: Navigate to exercise detail page
    // This can be handled in the view's listener
  }
}
