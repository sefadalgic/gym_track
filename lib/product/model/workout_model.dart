import 'package:gym_track/core/constants/enums/days.dart';
import 'package:gym_track/product/model/workout_exercise_model.dart';

class WorkoutModel {
  final String? name;
  final String? createdAt;
  final bool? isActive;
  final Map<Days, WorkoutExerciseModel?>? exercises;

  WorkoutModel(
      {required this.name,
      required this.createdAt,
      required this.isActive,
      required this.exercises});

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      name: json['name'],
      createdAt: json['createdAt'],
      isActive: json['isActive'],
      exercises: json['exercises'].map((k, v) => MapEntry(
          Days.values.firstWhere((e) => e.name == k),
          WorkoutExerciseModel.fromJson(v))),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'createdAt': createdAt,
      'isActive': isActive,
      'exercises': exercises?.map((k, v) => MapEntry(k.name, v?.toFirestore())),
    };
  }
}
