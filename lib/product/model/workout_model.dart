import 'package:gym_track/core/constants/enums/days.dart';
import 'package:gym_track/product/model/workout_exercise_model.dart';

class WorkoutModel {
  final String? id;
  final String? name;
  final String? createdAt;
  final bool? isActive;
  final Map<Days, List<WorkoutExerciseModel>>? exercises;

  WorkoutModel({
    this.id,
    required this.name,
    required this.createdAt,
    required this.isActive,
    required this.exercises,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    Map<Days, List<WorkoutExerciseModel>>? exercisesMap;

    if (json['exercises'] != null) {
      exercisesMap = {};
      final exercisesData = json['exercises'] as Map<String, dynamic>;

      for (var entry in exercisesData.entries) {
        final day = Days.values.firstWhere((e) => e.name == entry.key);
        final exercisesList = (entry.value as List)
            .map(
                (e) => WorkoutExerciseModel.fromJson(e as Map<String, dynamic>))
            .toList();
        exercisesMap[day] = exercisesList;
      }
    }

    return WorkoutModel(
      id: json['id'],
      name: json['name'],
      createdAt: json['createdAt'],
      isActive: json['isActive'],
      exercises: exercisesMap,
    );
  }

  Map<String, dynamic> toFirestore() {
    Map<String, dynamic>? exercisesMap;

    if (exercises != null) {
      exercisesMap = {};
      for (var entry in exercises!.entries) {
        exercisesMap[entry.key.name] =
            entry.value.map((e) => e.toFirestore()).toList();
      }
    }

    return {
      if (id != null) 'id': id,
      'name': name,
      'createdAt': createdAt,
      'isActive': isActive,
      'exercises': exercisesMap,
    };
  }

  WorkoutModel copyWith({
    String? id,
    String? name,
    String? createdAt,
    bool? isActive,
    Map<Days, List<WorkoutExerciseModel>>? exercises,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      exercises: exercises ?? this.exercises,
    );
  }

  /// Validate workout model
  bool get isValid {
    if (name == null || name!.trim().isEmpty) return false;
    if (exercises == null || exercises!.isEmpty) return false;

    // Check that all days have at least one exercise
    for (var dayExercises in exercises!.values) {
      if (dayExercises.isEmpty) return false;

      // Validate each exercise
      for (var exercise in dayExercises) {
        if (!exercise.isValid) return false;
      }
    }

    return true;
  }

  /// Get total number of exercises across all days
  int get totalExercises {
    if (exercises == null) return 0;
    return exercises!.values.fold(0, (sum, list) => sum + list.length);
  }

  /// Get number of training days
  int get trainingDays {
    if (exercises == null) return 0;
    return exercises!.keys.length;
  }

  /// Get list of selected days
  List<Days> get selectedDays {
    if (exercises == null) return [];
    return exercises!.keys.toList()..sort((a, b) => a.index.compareTo(b.index));
  }
}
