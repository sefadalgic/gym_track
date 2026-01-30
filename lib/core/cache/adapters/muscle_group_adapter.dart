import 'package:hive/hive.dart';
import 'package:gym_track/product/model/muscle_group.dart';

/// Hive type adapter for MuscleGroup enum
/// TypeId: 0
class MuscleGroupAdapter extends TypeAdapter<MuscleGroup> {
  @override
  final int typeId = 0;

  @override
  MuscleGroup read(BinaryReader reader) {
    final index = reader.readByte();
    return MuscleGroup.values[index];
  }

  @override
  void write(BinaryWriter writer, MuscleGroup obj) {
    writer.writeByte(obj.index);
  }
}
