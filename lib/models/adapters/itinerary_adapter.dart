import 'package:hive/hive.dart';
import '../itinerary.dart';
import '../expense.dart';

class ItineraryAdapter extends TypeAdapter<Itinerary> {
  @override
  final int typeId = 0; // Unique ID for this adapter

  @override
  Itinerary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Itinerary(
      id: fields[0] as String,
      origin: fields[1] as String,
      destinations: (fields[2] as List).cast<String>(),
      startDate: fields[3] as DateTime,
      endDate: fields[4] as DateTime,
      preferences: (fields[5] as Map).cast<String, dynamic>(),
      days: (fields[6] as List)
          .map((dynamic e) => Day.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, Itinerary obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.origin)
      ..writeByte(2)
      ..write(obj.destinations)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.endDate)
      ..writeByte(5)
      ..write(obj.preferences)
      ..writeByte(6)
      ..write(obj.days.map((e) => e.toJson()).toList());
  }
}
