// Core Dart
import 'dart:io';
import 'dart:convert';

// Flutter + UI
import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/services.dart';

// Local storage
import 'package:hive_flutter/hive_flutter.dart';
import 'models/property_model.dart';

// Media & file handling
// ignore: unnecessary_import
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive_io.dart';

// Sharing + platform
import 'package:share_plus/share_plus.dart';

// Map + URL
// ignore: unused_import
import 'package:url_launcher/url_launcher.dart';

import 'package:my_real_estate_manager/models/client_model.dart';
// Photo Viewer
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'models/profile_model.dart';

import 'screens/app_settings_screen.dart';
import 'screens/list_property_screen.dart';
// ignore: unused_import
import 'screens/property_details_screen.dart';
import 'screens/property_category_screen.dart';
import 'screens/client_management_screen.dart';

// Platform check
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PropertyAdapter());
  Hive.registerAdapter(ClientModelAdapter()); // <-- IMPORTANT
  Hive.registerAdapter(ProfileModelAdapter()); // 👈 ADD THIS

  await Hive.openBox<Property>('properties');
  await Hive.openBox<ClientModel>('clients'); // <-- IMPORTANT
  await Hive.openBox<ProfileModel>('profile'); // 👈 ADD THIS

  runApp(const RealEstateApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class RealEstateApp extends StatelessWidget {
  const RealEstateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // ← ADD THIS
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF002b36), Color(0xFF065f73)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              const Text(
                "Real Estate Manager",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 40),

              // Buttons start here
              buildButton("List Your Property", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ListPropertyScreen()),
                );
              }),
              buildButton("View Your Properties", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PropertyCategoryScreen(),
                  ),
                );
              }),
              buildButton("Client Management", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ClientManagementScreen(),
                  ),
                );
              }),

              const SizedBox(height: 20),

              buildButton("Settings", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              }),

              // Push footer down
              const Spacer(),

              const Text(
                "© Raimond Real Estate 2025",
                style: TextStyle(
                  color: Color.fromARGB(246, 156, 146, 146),
                  fontSize: 10,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Full width button function
  // Full width button function
  Widget buildButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.15),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          minimumSize: const Size(double.infinity, 55),
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  // Small button for Export / Import
  Widget buildSmallButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.20),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(110, 50),
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }
}

Widget appFooter() {
  return const Text(
    "© Raimond Real Estate 2025",
    style: TextStyle(color: Color.fromARGB(246, 156, 146, 146), fontSize: 10),
  );
}

// ================= GLOBAL PROPERTY LIST ===================
final propertyBox = Hive.box<Property>('properties');





//=================================================================================================================================
//===============================================================================================================================
// THIS IS FOR SETTTING SCREEN
//=================================================================================================================================
//=================================================================================================================================
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF002b36), Color(0xFF065f73)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back + Title
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Text(
                    "Settings",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Export
              _settingsButton(
                context,
                "Export Properties",
                () async => await exportProperties(context),
              ),

              // Import
              _settingsButton(
                context,
                "Import Properties",
                () async => await importProperties(context),
              ),

              // Profile
              _settingsButton(context, "Profile", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              }),

              _settingsButton(
  context,
  "App Settings",
  () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AppSettingsScreen(),
      ),
    );
  },
),

              // Buy Premium
              _settingsButton(context, "Buy Premium", () {}),

              const Spacer(),
              appFooter(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- reusable settings button ---
  Widget _settingsButton(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.15),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          minimumSize: const Size(double.infinity, 55),
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

//---------------------------------------------------------------------------------------------------------------------
// PROFILE SCREEN
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final companyController = TextEditingController();
  final roleController = TextEditingController();

  late Box<ProfileModel> profileBox;

  @override
  void initState() {
    super.initState();
    profileBox = Hive.box<ProfileModel>('profile');

    if (profileBox.isNotEmpty) {
      final profile = profileBox.getAt(0)!;
      nameController.text = profile.name;
      phoneController.text = profile.phone;
      emailController.text = profile.email;
      companyController.text = profile.company;
      roleController.text = profile.role;
    }
  }

  void saveProfile() async {
    final profile = ProfileModel(
      name: nameController.text,
      phone: phoneController.text,
      email: emailController.text,
      company: companyController.text,
      role: roleController.text,
    );

    if (profileBox.isEmpty) {
      await profileBox.add(profile);
    } else {
      await profileBox.putAt(0, profile);
    }

    // ✅ ADD THIS
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile Saved")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF002b36), Color(0xFF065f73)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),

                const Text(
                  "Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                _input("Name", nameController),
                _input("Phone", phoneController),
                _input("Email", emailController),
                _input("Company", companyController),
                DropdownButtonFormField<String>(
                  initialValue: roleController.text.isEmpty
                      ? null
                      : roleController.text,
                  hint: const Text("Select Role"),
                  dropdownColor: const Color(0xFF003845),
                  style: const TextStyle(color: Colors.white),
                  items:
                      [
                            "Agent",
                            "Property Manager",
                            "Commercial Agent",
                            "Channel Manager",
                            "Media Manager",
                            "Operation Manager",
                            "Managing Director",
                            "Founder",
                            "Acquisition Manager",
                            "Appraiser",
                          ]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (val) {
                    setState(() {
                      roleController.text = val!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Role",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: saveProfile,
                  child: const Text("Save"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.08),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------
// this screen is for listing a new property
//--------------------------------------------------------------------------------------------------------------------------------------------------------


//===================================================================================================================================================================================================
//              THIS IS FOR THE RENT/SALR/LAND LISTING AND CARD VIEW
//===================================================================================================================================================================================================

//===================================================================================================================================================================================================
//              THIS IS FOR PROPERTY LIST SCREEN
//===================================================================================================================================================================================================


//===================================================================================================================================================================================================
//             THIS IS FOR THE PROPERTY DETAILS SCREEN
//===================================================================================================================================================================================================


//===================================================================================================================================================================================================
//             THIS IS FOR UPDATING OLD PROPERTIES WITH NEW FIELDS
//===================================================================================================================================================================================================
Future<void> updateOldProperties(BuildContext context) async {
  final box = Hive.box<Property>('properties');

  for (int i = 0; i < box.length; i++) {
    final property = box.getAt(i);

    if (property != null) {
      final updated = Property(
        propertyId: property.propertyId, // 🔴 IMPORTANT
        id: property.id,
        category: property.category,
        title: property.title,
        location: property.location,
        price: property.price,
        images: property.images,

        priceCategoryMax: property.priceCategoryMax,

        bhk: property.bhk,
        bathrooms: property.bathrooms,
        sbua: property.sbua,
        carpetArea: property.carpetArea,
        floor: property.floor,
        

        furnishing: property.furnishing,
        propertyType: property.propertyType,
        apartmentType: property.apartmentType,
        propertyAge: property.propertyAge,
        handoverDate: property.handoverDate,

        parking: property.parking,
        lift: property.lift,
        coupleFriendly: property.coupleFriendly,
        independent: property.independent,
        muslimAllowed: property.muslimAllowed,

        ownerName: property.ownerName,
        ownerPhone: property.ownerPhone,
        alternatePhone: property.alternatePhone,
        customLocation: property.customLocation,

        mapUrl: property.mapUrl,
        description: property.description,
        isAvailable: property.isAvailable,
      );

      await box.putAt(i, updated);
    }
  }
  ScaffoldMessenger.of(
    // ignore: use_build_context_synchronously
    context,
  ).showSnackBar(SnackBar(content: Text("✔ Old data updated successfully!")));

  // ignore: avoid_print
  print("OLD DATA UPDATED SUCCESSFULLY");
}

//===================================================================================================================================================================================================
//             THIS IS FOR PHOTO VIEW GALLERY SCREEN
//===================================================================================================================================================================================================

class PhotoViewGalleryScreen extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  const PhotoViewGalleryScreen({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: images.length,
            pageController: PageController(initialPage: initialIndex),
            builder: (context, index) {
              final file = File(images[index]);

              return PhotoViewGalleryPageOptions(
                imageProvider: file.existsSync()
                    ? FileImage(file)
                    : const AssetImage("assets/broken.png") as ImageProvider,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2.5,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 80,
                      color: Colors.white,
                    ),
                  );
                },
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),

          // Close button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

//===================================================================================================================================================================================================
//             EXPORT IMPORT FUNCTIONALITY
//===================================================================================================================================================================================================

Future<void> exportProperties(BuildContext context) async {
  final box = Hive.box<Property>('properties');

  if (box.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("No properties to export")));
    return;
  }

  // Get App Directory
  final baseDir = await getApplicationDocumentsDirectory();
  final backupDir = Directory('${baseDir.path}/backup');
  if (!backupDir.existsSync()) backupDir.createSync(recursive: true);

  // Write JSON
  final jsonFile = File('${backupDir.path}/properties.json');
  jsonFile.writeAsStringSync(
    jsonEncode(box.values.map((p) => p.toJson()).toList()),
  );

  // Copy Images
  final imagesDir = Directory('${backupDir.path}/images');
  if (!imagesDir.existsSync()) imagesDir.createSync();

  for (var p in box.values) {
    for (var imgPath in p.images) {
      final fileName = imgPath.split('/').last;
      final newPath = '${imagesDir.path}/$fileName';

      if (!File(newPath).existsSync()) {
        File(imgPath).copySync(newPath);
      }
    }
  }

  // Zip Folder
  final zipFilePath = '${baseDir.path}/real_estate_backup.zip';
  final encoder = ZipFileEncoder();
  encoder.create(zipFilePath);
  encoder.addDirectory(backupDir);
  encoder.close();

  // PLATFORM HANDLING
  if (Platform.isAndroid || Platform.isIOS) {
    await Share.shareXFiles([XFile(zipFilePath)], text: "Real Estate Backup");
  } else {
    // DESKTOP MODE
    ScaffoldMessenger.of(
      // ignore: use_build_context_synchronously
      context,
    ).showSnackBar(SnackBar(content: Text("📁 Backup Saved: $zipFilePath")));
  }
}

Future<void> importProperties(BuildContext context) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['zip'],
  );

  if (result == null) return;

  final zipFile = File(result.files.single.path!);
  final tempDir = await getTemporaryDirectory();

  // Extract ZIP
  final archive = ZipDecoder().decodeBytes(zipFile.readAsBytesSync());
  final extractedDir = Directory('${tempDir.path}/restore');
  if (!extractedDir.existsSync()) extractedDir.createSync();

  for (final file in archive) {
    final filePath = '${extractedDir.path}/${file.name}';
    if (file.isFile) {
      File(filePath).writeAsBytesSync(file.content as List<int>);
    } else {
      Directory(filePath).createSync();
    }
  }

  // Read JSON
  final jsonFile = File('${extractedDir.path}/properties.json');
  final data = jsonDecode(jsonFile.readAsStringSync());

  final box = Hive.box<Property>('properties');

  for (var item in data) {
    final savedProperty = Property.fromJson(Map<String, dynamic>.from(item));

    // Fix image paths
    final restoredImages = savedProperty.images.map((img) {
      final name = img.split('/').last;
      return '${extractedDir.path}/images/$name';
    }).toList();

    await box.add(savedProperty.copyWith(images: restoredImages));
  }

  if (!context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text("✔ Import completed successfully")));
}



