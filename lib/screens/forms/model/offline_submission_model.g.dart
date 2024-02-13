// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_submission_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfflineSubmissionModelAdapter
    extends TypeAdapter<OfflineSubmissionModel> {
  @override
  final int typeId = 4;

  @override
  OfflineSubmissionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineSubmissionModel(
      fields[0] as String,
      fields[1] as int,
      (fields[2] as List).cast<EntityInstance>(),
      fields[3] as int,
      fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineSubmissionModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.submissionId)
      ..writeByte(1)
      ..write(obj.serverSyncTs)
      ..writeByte(2)
      ..write(obj.entities)
      ..writeByte(3)
      ..write(obj.retries)
      ..writeByte(4)
      ..write(obj.buttonKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineSubmissionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
