import 'package:gym_track/product/model/muscle_group.dart';

class ExerciseModel {
  String? id;
  String? name;
  String? category;
  List<MuscleGroup>? primaryMuscles;
  List<MuscleGroup>? secondaryMuscles;
  String? equipment;
  String? level;
  String? force;
  String? mechanic;
  List<String>? aliases;
  List<String>? instructions;
  String? description;
  List<String>? tips;
  String? dateCreated;
  String? dateUpdated;

  ExerciseModel(
      {this.id,
      this.name,
      this.category,
      this.primaryMuscles,
      this.secondaryMuscles,
      this.equipment,
      this.level,
      this.force,
      this.mechanic,
      this.aliases,
      this.instructions,
      this.description,
      this.tips,
      this.dateCreated,
      this.dateUpdated});

  ExerciseModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    category = json['category'];

    // Parse primaryMuscles from string list to MuscleGroup list
    if (json['primaryMuscles'] != null) {
      primaryMuscles = (json['primaryMuscles'] as List)
          .map((muscle) => MuscleGroup.fromJson(muscle as String))
          .toList();
    }

    // Parse secondaryMuscles from string list to MuscleGroup list
    if (json['secondaryMuscles'] != null) {
      secondaryMuscles = (json['secondaryMuscles'] as List)
          .map((muscle) => MuscleGroup.fromJson(muscle as String))
          .toList();
    }

    equipment = json['equipment'];
    level = json['level'];
    force = json['force'];
    mechanic = json['mechanic'];

    // Parse aliases
    if (json['aliases'] != null) {
      aliases = (json['aliases'] as List).map((v) => v as String).toList();
    }

    // Parse instructions
    if (json['instructions'] != null) {
      instructions =
          (json['instructions'] as List).map((v) => v as String).toList();
    }

    description = json['description'];

    // Parse tips
    if (json['tips'] != null) {
      tips = (json['tips'] as List).map((v) => v as String).toList();
    }

    dateCreated = json['dateCreated'];
    dateUpdated = json['dateUpdated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['category'] = category;

    // Serialize primaryMuscles
    if (primaryMuscles != null) {
      data['primaryMuscles'] = primaryMuscles!.map((v) => v.toJson()).toList();
    }

    // Serialize secondaryMuscles
    if (secondaryMuscles != null) {
      data['secondaryMuscles'] =
          secondaryMuscles!.map((v) => v.toJson()).toList();
    }

    data['equipment'] = equipment;
    data['level'] = level;
    data['force'] = force;
    data['mechanic'] = mechanic;
    data['aliases'] = aliases;
    data['instructions'] = instructions;
    data['description'] = description;
    data['tips'] = tips;
    data['dateCreated'] = dateCreated;
    data['dateUpdated'] = dateUpdated;
    return data;
  }
}
