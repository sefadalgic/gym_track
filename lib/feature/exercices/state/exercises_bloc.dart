import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_track/core/cache/services/exercise_cache_service.dart';
import 'package:gym_track/feature/exercices/state/exercises_event.dart';
import 'package:gym_track/feature/exercices/state/exercises_state.dart';
import 'package:gym_track/product/model/exercise_model.dart';
import 'package:gym_track/product/service/firestore_service.dart';

/// BLoC for managing exercises state with aggressive caching
/// Exercises are static data that rarely change, so we cache aggressively
/// to minimize Firebase costs and improve performance
class ExercisesBloc extends Bloc<ExercisesEvent, ExercisesState> {
  final FirestoreService _firestoreService;
  final ExerciseCacheService _cacheService;

  ExercisesBloc({
    FirestoreService? firestoreService,
    ExerciseCacheService? cacheService,
  })  : _firestoreService = firestoreService ?? FirestoreService.instance,
        _cacheService = cacheService ?? ExerciseCacheService.instance,
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
      // ALWAYS try cache first
      final cachedExercises = _cacheService.getCachedExercises();

      if (cachedExercises != null && cachedExercises.isNotEmpty) {
        // Cache hit! Show immediately and return
        // No Firebase call = No cost 💰
        print('Get exercises from cache');
        emit(state.copyWith(
          exercises: cachedExercises,
          isLoading: false,
          clearError: true,
        ));
        return;
      }

      // Cache miss - this only happens on first app install
      // Fetch from Firebase and cache for future use
      final exercises = await _firestoreService.getExercises();

      // Cache without expiration - exercises are static data
      // They will stay cached until manual refresh
      await _cacheService.cacheExercises(
        exercises: exercises,
        expiration: null, // No expiration!
      );

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

  /// Handle manual refresh request (pull-to-refresh or refresh button)
  /// This is the ONLY way to update exercises from Firebase
  /// Use this when new exercises are added to the database
  Future<void> _onRefreshRequested(
    ExercisesRefreshRequested event,
    Emitter<ExercisesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // Force fetch from Firebase
      final exercises = await _firestoreService.getExercises();

      // Update cache with fresh data
      await _cacheService.cacheExercises(
        exercises: exercises,
        expiration: null, // No expiration
      );

      emit(state.copyWith(
        exercises: exercises,
        isLoading: false,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to refresh exercises: ${e.toString()}',
      ));
    }
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
