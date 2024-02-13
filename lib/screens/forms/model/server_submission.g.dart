// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_submission.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServerSubmissionAdapter extends TypeAdapter<ServerSubmission> {
  @override
  final int typeId = 3;

  @override
  ServerSubmission read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServerSubmission(
      timestamp: fields[0] as int,
      submissionId: fields[1] as String,
      entities: (fields[2] as List).cast<String>(),
      reportedTs: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ServerSubmission obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.submissionId)
      ..writeByte(2)
      ..write(obj.entities)
      ..writeByte(3)
      ..write(obj.reportedTs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerSubmissionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
