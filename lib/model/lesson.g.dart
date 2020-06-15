// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LessonAdapter extends TypeAdapter<Lesson> {
  @override
  final typeId = 1;

  @override
  Lesson read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Lesson(
      name: fields[0] as String,
      description: fields[1] as String,
      location: fields[2] as String,
      start: fields[3] as DateTime,
      end: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Lesson obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.start)
      ..writeByte(4)
      ..write(obj.end);
  }
}
