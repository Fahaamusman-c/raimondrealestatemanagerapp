// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClientModelAdapter extends TypeAdapter<ClientModel> {
  @override
  final int typeId = 2;

  @override
  ClientModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClientModel(
      name: fields[0] as String,
      phone: fields[1] as String,
      alternatePhone: fields[2] as String?,
      categories: (fields[3] as List).cast<String>(),
      bhkPreferences: (fields[4] as List).cast<String>(),
      preferredLocations: (fields[5] as List).cast<String>(),
      amenities: (fields[6] as List).cast<String>(),
      hometown: fields[7] as String?,
      clientType: fields[8] as String?,
      profession: fields[9] as String?,
      priceCategoryMaxes: (fields[10] as List).cast<int?>(),
    );
  }

  @override
  void write(BinaryWriter writer, ClientModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.phone)
      ..writeByte(2)
      ..write(obj.alternatePhone)
      ..writeByte(3)
      ..write(obj.categories)
      ..writeByte(4)
      ..write(obj.bhkPreferences)
      ..writeByte(5)
      ..write(obj.preferredLocations)
      ..writeByte(6)
      ..write(obj.amenities)
      ..writeByte(7)
      ..write(obj.hometown)
      ..writeByte(8)
      ..write(obj.clientType)
      ..writeByte(9)
      ..write(obj.profession)
      ..writeByte(10)
      ..write(obj.priceCategoryMaxes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
