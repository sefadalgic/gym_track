import 'package:gym_track/product/model/exercise_set_model.dart';

/// Model for exercises within a workout session
class WorkoutSessionExerciseModel {
  final String exerciseId;
  final String exerciseName;
  final int plannedSets;
  final int plannedReps;
  final List<ExerciseSetModel> completedSets;
  final String? notes;

  WorkoutSessionExerciseModel({
    required this.exerciseId,
    required this.exerciseName,
    required this.plannedSets,
    required this.plannedReps,
    List<ExerciseSetModel>? completedSets,
    this.notes,
  }) : completedSets = completedSets ?? [];

  factory WorkoutSessionExerciseModel.fromJson(Map<String, dynamic> json) {
    List<ExerciseSetModel> sets = [];
    if (json['completedSets'] != null) {
      sets = (json['completedSets'] as List)
          .map((e) => ExerciseSetModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return WorkoutSessionExerciseModel(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      plannedSets: json['plannedSets'] as int,
      plannedReps: json['plannedReps'] as int,
      completedSets: sets,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'plannedSets': plannedSets,
      'plannedReps': plannedReps,
      'completedSets': completedSets.map((e) => e.toFirestore()).toList(),
      'notes': notes,
    };
  }

  WorkoutSessionExerciseModel copyWith({
    String? exerciseId,
    String? exerciseName,
    int? plannedSets,
    int? plannedReps,
    List<ExerciseSetModel>? completedSets,
    String? notes,
  }) {
    return WorkoutSessionExerciseModel(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      plannedSets: plannedSets ?? this.plannedSets,
      plannedReps: plannedReps ?? this.plannedReps,
      completedSets: completedSets ?? this.completedSets,
      notes: notes ?? this.notes,
    );
  }

  /// Get completion percentage for this exercise
  double get completionPercentage {
    if (plannedSets == 0) return 0;
    final completedCount = completedSets.where((s) => s.isCompleted).length;
    return (completedCount / plannedSets) * 100;
  }

  /// Check if all planned sets are completed
  bool get isFullyCompleted {
    return completedSets.where((s) => s.isCompleted).length >= plannedSets;
  }

  /// Get the last completed set for reference
  ExerciseSetModel? get lastCompletedSet {
    final completed = completedSets.where((s) => s.isCompleted).toList();
    if (completed.isEmpty) return null;
    return completed.last;
  }

  @override
  String toString() {
    return 'WorkoutSessionExerciseModel(exerciseName: $exerciseName, planned: $plannedSets×$plannedReps, completed: ${completedSets.length})';
  }
}
