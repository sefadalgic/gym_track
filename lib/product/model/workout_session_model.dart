import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_track/product/model/workout_session_exercise_model.dart';

/// Model for tracking workout sessions
class WorkoutSessionModel {
  final String? id;
  final String workoutId;
  final String workoutName;
  final DateTime date;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isCompleted;
  final List<WorkoutSessionExerciseModel> exercises;
  final String? notes;

  WorkoutSessionModel({
    this.id,
    required this.workoutId,
    required this.workoutName,
    required this.date,
    required this.startTime,
    this.endTime,
    this.isCompleted = false,
    required this.exercises,
    this.notes,
  });

  factory WorkoutSessionModel.fromJson(Map<String, dynamic> json) {
    List<WorkoutSessionExerciseModel> exercisesList = [];
    if (json['exercises'] != null) {
      exercisesList = (json['exercises'] as List)
          .map((e) =>
              WorkoutSessionExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return WorkoutSessionModel(
      id: json['id'] as String?,
      workoutId: json['workoutId'] as String,
      workoutName: json['workoutName'] as String,
      date: (json['date'] as Timestamp).toDate(),
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: json['endTime'] != null
          ? (json['endTime'] as Timestamp).toDate()
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      exercises: exercisesList,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) 'id': id,
      'workoutId': workoutId,
      'workoutName': workoutName,
      'date': Timestamp.fromDate(date),
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'isCompleted': isCompleted,
      'exercises': exercises.map((e) => e.toFirestore()).toList(),
      'notes': notes,
    };
  }

  WorkoutSessionModel copyWith({
    String? id,
    String? workoutId,
    String? workoutName,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
    List<WorkoutSessionExerciseModel>? exercises,
    String? notes,
  }) {
    return WorkoutSessionModel(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      workoutName: workoutName ?? this.workoutName,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      exercises: exercises ?? this.exercises,
      notes: notes ?? this.notes,
    );
  }

  /// Get total completion percentage for the session
  double get completionPercentage {
    if (exercises.isEmpty) return 0;
    final totalPercentage = exercises.fold<double>(
      0,
      (sum, exercise) => sum + exercise.completionPercentage,
    );
    return totalPercentage / exercises.length;
  }

  /// Get workout duration
  Duration? get duration {
    if (endTime == null) {
      return DateTime.now().difference(startTime);
    }
    return endTime!.difference(startTime);
  }

  /// Get total number of completed sets
  int get totalCompletedSets {
    return exercises.fold<int>(
      0,
      (sum, exercise) =>
          sum + exercise.completedSets.where((s) => s.isCompleted).length,
    );
  }

  /// Get total number of planned sets
  int get totalPlannedSets {
    return exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.plannedSets,
    );
  }

  @override
  String toString() {
    return 'WorkoutSessionModel(workoutName: $workoutName, date: $date, isCompleted: $isCompleted, exercises: ${exercises.length})';
  }
}
