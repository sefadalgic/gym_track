import 'package:hive_flutter/hive_flutter.dart';
import 'package:gym_track/core/cache/adapters/muscle_group_adapter.dart';
import 'package:gym_track/core/cache/adapters/exercise_model_adapter.dart';

/// A comprehensive cache manager using Hive for local data persistence.
/// Supports multiple cache boxes, expiration, and type-safe operations.
class CacheManager {
  CacheManager._();

  static final CacheManager _instance = CacheManager._();
  static CacheManager get instance => _instance;

  // Cache box names
  static const String _defaultBoxName = 'app_cache';
  static const String _userBoxName = 'user_cache';
  static const String _exerciseBoxName = 'exercise_cache';
  static const String _workoutBoxName = 'workout_cache';

  Box? _defaultBox;
  Box? _userBox;
  Box? _exerciseBox;
  Box? _workoutBox;

  /// Register all Hive type adapters
  /// Call this before init()
  void registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MuscleGroupAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ExerciseModelAdapter());
    }
  }

  /// Initialize Hive and open all cache boxes
  Future<void> init() async {
    await Hive.initFlutter();

    _defaultBox = await Hive.openBox(_defaultBoxName);
    _userBox = await Hive.openBox(_userBoxName);
    _exerciseBox = await Hive.openBox(_exerciseBoxName);
    _workoutBox = await Hive.openBox(_workoutBoxName);
  }

  /// Get a specific box by type
  Box _getBox(CacheBox boxType) {
    switch (boxType) {
      case CacheBox.user:
        return _userBox!;
      case CacheBox.exercise:
        return _exerciseBox!;
      case CacheBox.workout:
        return _workoutBox!;
      case CacheBox.defaultBox:
        return _defaultBox!;
    }
  }

  /// Save data to cache with optional expiration
  Future<void> put<T>({
    required String key,
    required T value,
    CacheBox box = CacheBox.defaultBox,
    Duration? expiration,
  }) async {
    final targetBox = _getBox(box);

    if (expiration != null) {
      final expiryTime = DateTime.now().add(expiration).millisecondsSinceEpoch;
      final cacheItem = CacheItem<T>(
        value: value,
        expiryTime: expiryTime,
      );
      await targetBox.put(key, cacheItem.toMap());
    } else {
      await targetBox.put(key, value);
    }
  }

  /// Get data  from cache
  T? get<T>({
    required String key,
    CacheBox box = CacheBox.defaultBox,
  }) {
    final targetBox = _getBox(box);
    final data = targetBox.get(key);

    if (data == null) return null;

    // Check if it's a CacheItem with expiration
    if (data is Map) {
      try {
        final cacheItem = CacheItem<T>.fromMap(data);

        // Check if expired
        if (cacheItem.isExpired) {
          delete(key: key, box: box);
          return null;
        }

        return cacheItem.value;
      } catch (e) {
        // If parsing fails, return the raw data
        return data as T?;
      }
    }

    return data as T?;
  }

  /// Delete a specific key from cache
  Future<void> delete({
    required String key,
    CacheBox box = CacheBox.defaultBox,
  }) async {
    final targetBox = _getBox(box);
    await targetBox.delete(key);
  }

  /// Clear all data from a specific box
  Future<void> clearBox(CacheBox box) async {
    final targetBox = _getBox(box);
    await targetBox.clear();
  }

  /// Clear all cache boxes
  Future<void> clearAll() async {
    await _defaultBox?.clear();
    await _userBox?.clear();
    await _exerciseBox?.clear();
    await _workoutBox?.clear();
  }

  /// Check if a key exists in cache
  bool containsKey({
    required String key,
    CacheBox box = CacheBox.defaultBox,
  }) {
    final targetBox = _getBox(box);
    return targetBox.containsKey(key);
  }

  /// Get all keys from a specific box
  Iterable<dynamic> getKeys(CacheBox box) {
    final targetBox = _getBox(box);
    return targetBox.keys;
  }

  /// Get all values from a specific box
  Iterable<dynamic> getValues(CacheBox box) {
    final targetBox = _getBox(box);
    return targetBox.values;
  }

  /// Remove expired items from all boxes
  Future<void> cleanExpiredItems() async {
    await _cleanBoxExpiredItems(_defaultBox!);
    await _cleanBoxExpiredItems(_userBox!);
    await _cleanBoxExpiredItems(_exerciseBox!);
    await _cleanBoxExpiredItems(_workoutBox!);
  }

  Future<void> _cleanBoxExpiredItems(Box box) async {
    final keysToDelete = <dynamic>[];

    for (var key in box.keys) {
      final data = box.get(key);
      if (data is Map) {
        try {
          final cacheItem = CacheItem.fromMap(data);
          if (cacheItem.isExpired) {
            keysToDelete.add(key);
          }
        } catch (_) {
          // Skip non-CacheItem entries
        }
      }
    }

    for (var key in keysToDelete) {
      await box.delete(key);
    }
  }

  /// Close all boxes (call this when app is closing)
  Future<void> close() async {
    await _defaultBox?.close();
    await _userBox?.close();
    await _exerciseBox?.close();
    await _workoutBox?.close();
  }

  /// Dispose and delete all boxes (use with caution)
  Future<void> dispose() async {
    await Hive.deleteBoxFromDisk(_defaultBoxName);
    await Hive.deleteBoxFromDisk(_userBoxName);
    await Hive.deleteBoxFromDisk(_exerciseBoxName);
    await Hive.deleteBoxFromDisk(_workoutBoxName);
  }
}

/// Enum for different cache box types
enum CacheBox {
  defaultBox,
  user,
  exercise,
  workout,
}

/// Cache item wrapper with expiration support
class CacheItem<T> {
  final T value;
  final int expiryTime; // milliseconds since epoch

  CacheItem({
    required this.value,
    required this.expiryTime,
  });

  bool get isExpired => DateTime.now().millisecondsSinceEpoch > expiryTime;

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'expiryTime': expiryTime,
    };
  }

  factory CacheItem.fromMap(Map<dynamic, dynamic> map) {
    return CacheItem<T>(
      value: map['value'] as T,
      expiryTime: map['expiryTime'] as int,
    );
  }
}
