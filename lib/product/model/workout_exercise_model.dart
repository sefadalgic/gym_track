class WorkoutExerciseModel {
  final String? exerciseId;
  final String? name;
  final int? sets;
  final int? reps;

  WorkoutExerciseModel(
      {required this.exerciseId,
      required this.name,
      required this.sets,
      required this.reps});

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
}
