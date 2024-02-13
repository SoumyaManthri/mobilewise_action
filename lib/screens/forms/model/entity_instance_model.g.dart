// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_instance_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EntityInstanceAdapter extends TypeAdapter<EntityInstance> {
  @override
  final int typeId = 5;

  @override
  EntityInstance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EntityInstance(
      id: fields[0] as String,
      key: fields[1] as String,
      parentId: fields[2] as String?,
      childIds: (fields[3] as List).cast<String>(),
      submissionField: (fields[4] as List).cast<SubmissionField>(),
    );
  }

  @override
  void write(BinaryWriter writer, EntityInstance obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.key)
      ..writeByte(2)
      ..write(obj.parentId)
      ..writeByte(3)
      ..write(obj.childIds)
      ..writeByte(4)
      ..write(obj.submissionField);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntityInstanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
