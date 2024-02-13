// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submission_field_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubmissionFieldAdapter extends TypeAdapter<SubmissionField> {
  @override
  final int typeId = 6;

  @override
  SubmissionField read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubmissionField(
      key: fields[0] as String,
      value: fields[1] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, SubmissionField obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubmissionFieldAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
