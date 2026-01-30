class WorkoutExerciseModel {
  final String? exerciseId;
  final String? name;
  final int? sets;
  final int? reps;

  WorkoutExerciseModel({
    required this.exerciseId,
    required this.name,
    required this.sets,
    required this.reps,
  });

  factory WorkoutExerciseModel.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseModel(
      exerciseId: json['exerciseId'],
      name: json['name'],
      sets: json['sets'],
      reps: json['reps'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'exerciseId': exerciseId,
      'name': name,
      'sets': sets,
      'reps': reps,
    };
  }

  WorkoutExerciseModel copyWith({
    String? exerciseId,
    String? name,
    int? sets,
    int? reps,
  }) {
    return WorkoutExerciseModel(
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
    );
  }

  /// Validate exercise model
  bool get isValid {
    if (exerciseId == null || exerciseId!.trim().isEmpty) return false;
    if (name == null || name!.trim().isEmpty) return false;
    if (sets == null || sets! <= 0) return false;
    if (reps == null || reps! <= 0) return false;
    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutExerciseModel &&
        other.exerciseId == exerciseId &&
        other.name == name &&
        other.sets == sets &&
        other.reps == reps;
  }

  @override
  int get hashCode {
    return exerciseId.hashCode ^ name.hashCode ^ sets.hashCode ^ reps.hashCode;
  }

  @override
  String toString() {
    return 'WorkoutExerciseModel(exerciseId: $exerciseId, name: $name, sets: $sets, reps: $reps)';
  }
}
