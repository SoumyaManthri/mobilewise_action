// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screen_config_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScreensConfigModelAdapter extends TypeAdapter<ScreensConfigModel> {
  @override
  final int typeId = 0;

  @override
  ScreensConfigModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScreensConfigModel(
      version: fields[0] as int,
      screensJsonString: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ScreensConfigModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.version)
      ..writeByte(1)
      ..write(obj.screensJsonString);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScreensConfigModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
