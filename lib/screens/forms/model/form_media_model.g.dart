// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_media_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FormMediaModelAdapter extends TypeAdapter<FormMediaModel> {
  @override
  final int typeId = 1;

  @override
  FormMediaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FormMediaModel(
      fields[0] as String,
      fields[1] as String,
      fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FormMediaModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.path)
      ..writeByte(2)
      ..write(obj.retries);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormMediaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
