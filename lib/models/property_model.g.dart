// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PropertyAdapter extends TypeAdapter<Property> {
  @override
  final int typeId = 1;

  @override
  Property read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Property(
      id: fields[0] as String,
      category: fields[1] as String,
      title: fields[2] as String,
      location: fields[3] as String,
      price: fields[4] as String,
      images: (fields[5] as List).cast<String>(),
      bhk: fields[6] as String?,
      bathrooms: fields[7] as String?,
      carpetArea: fields[8] as String?,
      sbua: fields[9] as String?,
      parking: fields[10] as String?,
      ownerPhone: fields[11] as String?,
      alternatePhone: fields[12] as String?,
      mapUrl: fields[13] as String?,
      description: fields[14] as String?,
      propertyType: fields[15] as String?,
      lift: fields[16] as bool?,
      coupleFriendly: fields[17] as bool?,
      independent: fields[18] as bool?,
      muslimAllowed: fields[19] as bool?,
      floor: fields[20] as String?,
      bigha: fields[21] as String?,
      katha: fields[22] as String?,
      lessa: fields[23] as String?,
      pricePerBigha: fields[24] as String?,
      pricePerKatha: fields[25] as String?,
      pricePerLessa: fields[26] as String?,
      ownerName: fields[27] as String?,
      customLocation: fields[28] as String?,
      apartmentType: fields[29] as String?,
      propertyAge: fields[30] as String?,
      handoverDate: fields[31] as String?,
      pricePerSqft: fields[32] as String?,
      furnishing: fields[33] as String?,
      propertyId: fields[34] as String,
      priceCategoryMax: fields[35] as int?,
      isAvailable: fields[36] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Property obj) {
    writer
      ..writeByte(37)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.images)
      ..writeByte(6)
      ..write(obj.bhk)
      ..writeByte(7)
      ..write(obj.bathrooms)
      ..writeByte(8)
      ..write(obj.carpetArea)
      ..writeByte(9)
      ..write(obj.sbua)
      ..writeByte(10)
      ..write(obj.parking)
      ..writeByte(11)
      ..write(obj.ownerPhone)
      ..writeByte(12)
      ..write(obj.alternatePhone)
      ..writeByte(13)
      ..write(obj.mapUrl)
      ..writeByte(14)
      ..write(obj.description)
      ..writeByte(15)
      ..write(obj.propertyType)
      ..writeByte(16)
      ..write(obj.lift)
      ..writeByte(17)
      ..write(obj.coupleFriendly)
      ..writeByte(18)
      ..write(obj.independent)
      ..writeByte(19)
      ..write(obj.muslimAllowed)
      ..writeByte(20)
      ..write(obj.floor)
      ..writeByte(21)
      ..write(obj.bigha)
      ..writeByte(22)
      ..write(obj.katha)
      ..writeByte(23)
      ..write(obj.lessa)
      ..writeByte(24)
      ..write(obj.pricePerBigha)
      ..writeByte(25)
      ..write(obj.pricePerKatha)
      ..writeByte(26)
      ..write(obj.pricePerLessa)
      ..writeByte(27)
      ..write(obj.ownerName)
      ..writeByte(28)
      ..write(obj.customLocation)
      ..writeByte(29)
      ..write(obj.apartmentType)
      ..writeByte(30)
      ..write(obj.propertyAge)
      ..writeByte(31)
      ..write(obj.handoverDate)
      ..writeByte(32)
      ..write(obj.pricePerSqft)
      ..writeByte(33)
      ..write(obj.furnishing)
      ..writeByte(34)
      ..write(obj.propertyId)
      ..writeByte(35)
      ..write(obj.priceCategoryMax)
      ..writeByte(36)
      ..write(obj.isAvailable);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PropertyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
