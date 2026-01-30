import 'package:hive/hive.dart';
import 'package:gym_track/product/model/exercise_model.dart';
import 'package:gym_track/product/model/muscle_group.dart';

/// Hive type adapter for ExerciseModel
/// TypeId: 1
class ExerciseModelAdapter extends TypeAdapter<ExerciseModel> {
  @override
  final int typeId = 1;

  @override
  ExerciseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return ExerciseModel(
      id: fields[0] as String?,
      name: fields[1] as String?,
      category: fields[2] as String?,
      primaryMuscles: (fields[3] as List?)?.cast<MuscleGroup>(),
      secondaryMuscles: (fields[4] as List?)?.cast<MuscleGroup>(),
      equipment: fields[5] as String?,
      level: fields[6] as String?,
      force: fields[7] as String?,
      mechanic: fields[8] as String?,
      aliases: (fields[9] as List?)?.cast<String>(),
      instructions: (fields[10] as List?)?.cast<String>(),
      description: fields[11] as String?,
      tips: (fields[12] as List?)?.cast<String>(),
      dateCreated: fields[13] as String?,
      dateUpdated: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseModel obj) {
    writer
      ..writeByte(15) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.primaryMuscles)
      ..writeByte(4)
      ..write(obj.secondaryMuscles)
      ..writeByte(5)
      ..write(obj.equipment)
      ..writeByte(6)
      ..write(obj.level)
      ..writeByte(7)
      ..write(obj.force)
      ..writeByte(8)
      ..write(obj.mechanic)
      ..writeByte(9)
      ..write(obj.aliases)
      ..writeByte(10)
      ..write(obj.instructions)
      ..writeByte(11)
      ..write(obj.description)
      ..writeByte(12)
      ..write(obj.tips)
      ..writeByte(13)
      ..write(obj.dateCreated)
      ..writeByte(14)
      ..write(obj.dateUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
