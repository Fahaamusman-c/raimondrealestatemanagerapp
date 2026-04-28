import 'package:hive/hive.dart';

part 'client_model.g.dart';

@HiveType(typeId: 2)
class ClientModel {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String phone;

  @HiveField(2)
  final String? alternatePhone;

  @HiveField(3)
  final List<String> categories;

  @HiveField(4)
  final List<String> bhkPreferences;

  @HiveField(5)
  final List<String> preferredLocations;

  @HiveField(6)
  final List<String> amenities;

 @HiveField(7)
  final String? hometown;

  @HiveField(8)
  final String? clientType; // Family / Working bachelors / Student

  @HiveField(9)
  final String? profession;

  @HiveField(10)
  final List<int?> priceCategoryMaxes;


  ClientModel({
    required this.name,
    required this.phone,
    this.alternatePhone,
    required this.categories,
    required this.bhkPreferences,
    required this.preferredLocations,
    required this.amenities,
    this.hometown,
    this.clientType,
    this.profession,
    this.priceCategoryMaxes = const [],

  });
}
