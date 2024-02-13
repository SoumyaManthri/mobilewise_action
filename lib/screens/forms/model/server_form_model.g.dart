// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_form_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServerFormModelAdapter extends TypeAdapter<ServerFormModel> {
  @override
  final int typeId = 2;

  @override
  ServerFormModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServerFormModel(
      fields[0] as int,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ServerFormModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.version)
      ..writeByte(1)
      ..write(obj.formJson)
      ..writeByte(2)
      ..write(obj.formKey)
      ..writeByte(3)
      ..write(obj.formType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerFormModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
