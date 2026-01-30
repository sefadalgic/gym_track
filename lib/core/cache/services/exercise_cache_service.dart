import 'package:gym_track/core/cache/cache_manager.dart';
import 'package:gym_track/product/model/exercise_model.dart';

/// Service for caching exercise data
class ExerciseCacheService {
  ExerciseCacheService._();

  static final ExerciseCacheService _instance = ExerciseCacheService._();
  static ExerciseCacheService get instance => _instance;

  static const String _exerciseListKey = 'exercise_list';
  static const String _exercisePrefix = 'exercise_';

  // Default cache duration: 24 hours
  static const Duration _defaultCacheDuration = Duration(hours: 24);

  /// Cache a list of exercises
  Future<void> cacheExercises({
    required List<ExerciseModel> exercises,
    Duration? expiration,
  }) async {
    await CacheManager.instance.put(
      key: _exerciseListKey,
      value: exercises,
      box: CacheBox.exercise,
      expiration: expiration ?? _defaultCacheDuration,
    );
  }

  /// Get cached exercise list
  List<ExerciseModel>? getCachedExercises() {
    final cached = CacheManager.instance.get<List>(
      key: _exerciseListKey,
      box: CacheBox.exercise,
    );

    if (cached == null) return null;

    return cached.cast<ExerciseModel>();
  }

  /// Cache a single exercise by ID
  Future<void> cacheExercise({
    required ExerciseModel exercise,
    Duration? expiration,
  }) async {
    if (exercise.id == null) return;

    await CacheManager.instance.put(
      key: '$_exercisePrefix${exercise.id}',
      value: exercise,
      box: CacheBox.exercise,
      expiration: expiration ?? _defaultCacheDuration,
    );
  }

  /// Get a single cached exercise by ID
  ExerciseModel? getCachedExercise(String exerciseId) {
    return CacheManager.instance.get<ExerciseModel>(
      key: '$_exercisePrefix$exerciseId',
      box: CacheBox.exercise,
    );
  }

  /// Delete a specific exercise from cache
  Future<void> deleteExercise(String exerciseId) async {
    await CacheManager.instance.delete(
      key: '$_exercisePrefix$exerciseId',
      box: CacheBox.exercise,
    );
  }

  /// Clear all exercise cache
  Future<void> clearExerciseCache() async {
    await CacheManager.instance.clearBox(CacheBox.exercise);
  }

  /// Check if exercises are cached
  bool hasExerciseCache() {
    return CacheManager.instance.containsKey(
      key: _exerciseListKey,
      box: CacheBox.exercise,
    );
  }

  /// Get cache timestamp (if available)
  DateTime? getCacheTimestamp() {
    // This would require storing metadata with the cache
    // For now, we rely on the expiration mechanism
    return null;
  }
}
