import 'package:hive/hive.dart';

part 'profile_model.g.dart';

@HiveType(typeId: 3)
class ProfileModel extends HiveObject { // ✅ ADD THIS
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String phone;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String company;

  @HiveField(4)
  final String role;

  ProfileModel({
    required this.name,
    required this.phone,
    required this.email,
    required this.company,
    this.role = "Agent", // ✅ DEFAULT FIX
  });
}