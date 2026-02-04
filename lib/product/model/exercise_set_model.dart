import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for tracking individual exercise sets with weight and reps
class ExerciseSetModel {
  final int setNumber;
  final double? weight; // Weight in kg
  final int? reps; // Number of repetitions
  final bool isCompleted;
  final DateTime? timestamp;

  ExerciseSetModel({
    required this.setNumber,
    this.weight,
    this.reps,
    this.isCompleted = false,
    this.timestamp,
  });

  factory ExerciseSetModel.fromJson(Map<String, dynamic> json) {
    return ExerciseSetModel(
      setNumber: json['setNumber'] as int,
      weight:
          json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      reps: json['reps'] as int?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      timestamp: json['timestamp'] != null
          ? (json['timestamp'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
      'isCompleted': isCompleted,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
    };
  }

  ExerciseSetModel copyWith({
    int? setNumber,
    double? weight,
    int? reps,
    bool? isCompleted,
    DateTime? timestamp,
  }) {
    return ExerciseSetModel(
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      isCompleted: isCompleted ?? this.isCompleted,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  bool get isValid {
    return setNumber > 0 &&
        (weight == null || weight! >= 0) &&
        (reps == null || reps! > 0);
  }

  @override
  String toString() {
    return 'ExerciseSetModel(setNumber: $setNumber, weight: $weight, reps: $reps, isCompleted: $isCompleted)';
  }
}
