import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_track/core/network/network_manager.dart';
import 'package:gym_track/feature/exercices/state/exercises_event.dart';
import 'package:gym_track/feature/exercices/state/exercises_state.dart';
import 'package:gym_track/product/model/exercise_model.dart';

/// BLoC for managing exercises state
class ExercisesBloc extends Bloc<ExercisesEvent, ExercisesState> {
  final NetworkManager _networkManager;

  ExercisesBloc({NetworkManager? networkManager})
      : _networkManager = networkManager ?? NetworkManager.instance,
        super(const ExercisesState()) {
    on<ExercisesLoadRequested>(_onLoadRequested);
    on<ExercisesRefreshRequested>(_onRefreshRequested);
    on<ExercisesFilterChanged>(_onFilterChanged);
    on<ExerciseSelected>(_onExerciseSelected);
  }

  /// Handle loading exercises from API
  Future<void> _onLoadRequested(
    ExercisesLoadRequested event,
    Emitter<ExercisesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final response = await _networkManager.networkService.get(
        path: '/api/exercises',
      );

      if (response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        final List<dynamic> exercisesJson = responseData['data'];
        final exercises = exercisesJson
            .map((json) => ExerciseModel.fromJson(json as Map<String, dynamic>))
            .toList();

        emit(state.copyWith(
          exercises: exercises,
          isLoading: false,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: 'No data received from server',
        ));
      }
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
