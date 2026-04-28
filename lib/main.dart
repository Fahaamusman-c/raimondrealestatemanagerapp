// Core Dart
import 'dart:io';
import 'dart:convert';

// Flutter + UI
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Local storage
import 'package:hive_flutter/hive_flutter.dart';
import 'models/property_model.dart';

// Media & file handling
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive_io.dart';

// Sharing + platform
import 'package:share_plus/share_plus.dart';

// Map + URL
import 'package:url_launcher/url_launcher.dart';

import 'package:my_real_estate_manager/models/client_model.dart';
// Photo Viewer
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'models/profile_model.dart';

import 'screens/app_settings_screen.dart';

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

//====================================================================================================================
//=================================================================================================================================
//   TIS IS FOR PROPERTY CATEGORY SCREEN (RENT/SALE/LAND) (VIEW YOUR PROPERTY BUTTON)
//=================================================================================================================================
//=================================================================================================================================

class PropertyCategoryScreen extends StatelessWidget {
  const PropertyCategoryScreen({super.key});

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
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Text(
                    "Select Category",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Sale
              _categoryButton(context, "Sale Properties", "Sale"),

              // Rent
              _categoryButton(context, "Rent Properties", "Rent"),

              // Land
              _categoryButton(context, "Land / Plot Properties", "Land"),

              const Spacer(),
              appFooter(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryButton(BuildContext context, String label, String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.15),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          minimumSize: const Size(double.infinity, 55),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PropertyListScreen(filterCategory: category),
            ),
          );
        },
        child: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

//=================================================================================================================================================================================
// =================================================================================================================
//                THIS IS FOR CLIENT MANAGEMENT SCREEN
// =================================================================================================================
//=================================================================================================================================================================================

class ClientManagementScreen extends StatelessWidget {
  const ClientManagementScreen({super.key});

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
              // Back Button + Title
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Text(
                    "Client Management",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Register Client Button
              _clientButton(
                context,
                "Register Your Client",
                const RegisterClientScreen(),
              ),

              // View Clients Button
              _clientButton(
                context,
                "View Your Clients",
                const ViewClientsScreen(),
              ),

              const Spacer(),
              appFooter(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable button
  Widget _clientButton(BuildContext context, String label, Widget screen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.15),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          minimumSize: const Size(double.infinity, 55),
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        },
        child: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

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

class ListPropertyScreen extends StatefulWidget {
  final Property? existingProperty;
  final int? editIndex;

  const ListPropertyScreen({super.key, this.existingProperty, this.editIndex});

  @override
  State<ListPropertyScreen> createState() => _ListPropertyScreenState();
}

class _ListPropertyScreenState extends State<ListPropertyScreen> {
  String? _category;
  String? _type;
  String? _bhk;
  String? _bathrooms;
  String? _carParking;
  // ignore: unused_field
  String? _ownerPhone;
  // ignore: unused_field
  String? _alternatePhone;
  String? _location;
  String? _ownerName;
  String? _customLocation;
  String? _apartmentType;
  String? _handoverDate;
  String? pricePerSqft;
  String? _furnishing;
  String? _selectedPriceCategoryLabel;
  int? _priceCategoryMax;

  final List<String> _images = [];

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();

    if (picked.isNotEmpty) {
      setState(() {
        _images.addAll(picked.map((e) => e.path));
      });
    }
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _pricePerSqftController = TextEditingController();

  final TextEditingController _sbuaController = TextEditingController();
  final TextEditingController _carpetAreaController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _bighaController = TextEditingController();
  final TextEditingController _kathaController = TextEditingController();
  final TextEditingController _lessaController = TextEditingController();
  final TextEditingController _pricePerBighaController =
      TextEditingController();
  final TextEditingController _pricePerKathaController =
      TextEditingController();
  final TextEditingController _pricePerLessaController =
      TextEditingController();
  final TextEditingController _mapUrlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _propertyAgeController = TextEditingController();
  final TextEditingController _propertyIdController = TextEditingController();
  final TextEditingController _propertyPrefixController =
      TextEditingController();

  bool get isRent => _category == "Rent";
  bool get isSale => _category == "Sale";
  bool get isLand => _category == "Land";
  bool? _lift;
  bool? _coupleFriendly;
  bool? _independent;
  bool? _muslimAllowed;

  @override
  void initState() {
    super.initState();

    // 🔵 EDIT MODE: prefill data
    if (widget.existingProperty != null) {
      final p = widget.existingProperty!;

      _category = p.category;
      _propertyPrefixController.text = getPropertyPrefix(p.category);
      _propertyIdController.text = p.propertyId.replaceFirst(
        getPropertyPrefix(p.category),
        "",
      );

      _titleController.text = p.title;
      _priceController.text = p.price;
      _pricePerSqftController.text = p.pricePerSqft ?? "";

      _location = p.location;
      _bhk = p.bhk;
      _bathrooms = p.bathrooms;
      _carParking = p.parking;
      _furnishing = p.furnishing;

      _sbuaController.text = p.sbua ?? "";
      _carpetAreaController.text = p.carpetArea ?? "";
      _floorController.text = p.floor ?? "";

      _bighaController.text = p.bigha ?? "";
      _kathaController.text = p.katha ?? "";
      _lessaController.text = p.lessa ?? "";

      _pricePerBighaController.text = p.pricePerBigha ?? "";
      _pricePerKathaController.text = p.pricePerKatha ?? "";
      _pricePerLessaController.text = p.pricePerLessa ?? "";

      _mapUrlController.text = p.mapUrl ?? "";
      _descriptionController.text = p.description ?? "";

      _ownerName = p.ownerName;
      _customLocation = p.customLocation;
      _apartmentType = p.apartmentType;
      _propertyAgeController.text = p.propertyAge ?? "";
      _handoverDate = p.handoverDate;

      _lift = p.lift;
      _coupleFriendly = p.coupleFriendly;
      _independent = p.independent;
      _muslimAllowed = p.muslimAllowed;

      _ownerPhone = p.ownerPhone;
      _alternatePhone = p.alternatePhone;

      _priceCategoryMax = p.priceCategoryMax;
      _selectedPriceCategoryLabel = priceCategories
          .firstWhere(
            (e) => e.maxAmount == p.priceCategoryMax,
            orElse: () => const PriceCategory("No Limit", null),
          )
          .label;

      _images.addAll(p.images);
    }
  }

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, size: 18),
                      SizedBox(width: 6),
                      Text("Back"),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Center(
                  child: Text(
                    "List Your Property",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // === FORM START ===

                // Always visible
                _buildDropdown(
                  label: "Category",
                  value: _category,
                  items: const ["Rent", "Sale", "Land"],
                  onChanged: (val) {
                    setState(() {
                      _category = val;
                      _propertyPrefixController.text = getPropertyPrefix(
                        val!,
                      ); // 👈 THIS LINE
                    });
                  },
                ),

                if (_category != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        // PREFIX (read-only)
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _propertyPrefixController,
                            enabled: false,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration("Prefix", null),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // SUFFIX (you type)
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _propertyIdController,
                            enabled:
                                widget.editIndex ==
                                null, // 🔒 lock when editing
                            keyboardType: TextInputType.text,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                              "Property ID",
                              "Enter number",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (!isLand)
                  _buildDropdown(
                    label: "Furnishing",
                    value: _furnishing,
                    items: const [
                      "Unfurnished",
                      "Semi-Furnished",
                      "Fully-Furnished",
                    ],
                    onChanged: (val) => setState(() => _furnishing = val),
                  ),

                _buildTextField(label: "Title", controller: _titleController),
                _buildTextField(label: "Price", controller: _priceController),

                if (isSale)
                  _buildNumberField(
                    label: "Price per sqft",
                    controller: _pricePerSqftController,
                  ),

                if (isSale || isLand)
                  _buildDropdown(
                    label: "Price Category",
                    value: _selectedPriceCategoryLabel,
                    items: priceCategories.map((e) => e.label).toList(),
                    onChanged: (val) {
                      final selected = priceCategories.firstWhere(
                        (e) => e.label == val,
                      );
                      setState(() {
                        _selectedPriceCategoryLabel = val;
                        _priceCategoryMax = selected.maxAmount;
                      });
                    },
                  ),

                if (isSale)
                  _buildDropdown(
                    label: "Type",
                    value: _type,
                    items: const [
                      "Resell",
                      "Newly Constructed",
                      "Under Construction",
                    ],
                    onChanged: (val) => setState(() => _type = val),
                  ),
                if (isSale && _type == "Resell")
                  _buildNumberField(
                    label: "Property Age (Years)",
                    controller: _propertyAgeController,
                  ),

                if (isSale && _type == "Under Construction")
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2050),
                      );

                      if (picked != null) {
                        setState(
                          () =>
                              _handoverDate = "${picked.month}/${picked.year}",
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        _handoverDate ?? "Select Date",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                _buildDropdown(
                  label: "Location",
                  value: _location,
                  items: guwahatiAreas,
                  onChanged: (val) => setState(() => _location = val),
                ),

                _buildTextField(
                  label: "Custom Location (Optional)",
                  onChanged: (v) => _customLocation = v,
                ),

                if (!isLand)
                  _buildDropdown(
                    label: "BHK",
                    value: _bhk,
                    items: const [
                      "Single Room",
                      "1RK",
                      "2RK",
                      "1 BHK",
                      "2 BHK",
                      "3 BHK",
                      "4 BHK",
                      "5 BHK",
                    ],

                    onChanged: (val) => setState(() => _bhk = val),
                  ),

                if (!isLand)
                  _buildDropdown(
                    label: "Bathrooms",
                    value: _bathrooms,
                    items: const ["1", "2", "3", "4", "5"],
                    onChanged: (val) => setState(() => _bathrooms = val),
                  ),

                if (!isLand)
                  _buildNumberField(label: "SBUA", controller: _sbuaController),

                if (!isLand)
                  _buildNumberField(
                    label: "Carpet Area",
                    controller: _carpetAreaController,
                  ),

                if (!isLand)
                  _buildRadioRow(
                    label: "Apartment?",
                    value: _apartmentType == "Yes",
                    onChanged: (val) =>
                        setState(() => _apartmentType = val! ? "Yes" : "No"),
                  ),

                if (!isLand)
                  _buildRadioRow(
                    label: "Lift",
                    value: _lift,
                    onChanged: (val) => setState(() => _lift = val),
                  ),

                if (isRent)
                  _buildRadioRow(
                    label: "Couple Friendly",
                    value: _coupleFriendly,
                    onChanged: (val) => setState(() => _coupleFriendly = val),
                  ),

                if (isRent)
                  _buildRadioRow(
                    label: "Independent",
                    value: _independent,
                    onChanged: (val) => setState(() => _independent = val),
                  ),

                if (!isLand)
                  _buildRadioRow(
                    label: "Muslim Allowed",
                    value: _muslimAllowed,
                    onChanged: (val) => setState(() => _muslimAllowed = val),
                  ),

                if (!isLand)
                  _buildDropdown(
                    label: "Car Parking",
                    value: _carParking,
                    items: const ["0", "1", "2", "3", "4", "5"],
                    onChanged: (val) => setState(() => _carParking = val),
                  ),

                if (!isLand)
                  _buildTextField(
                    label: "Floor / Total Floor",
                    hint: "2 / 3",
                    controller: _floorController,
                  ),

                if (isLand)
                  _buildNumberField(
                    label: "Bigha",
                    controller: _bighaController,
                  ),
                if (isLand)
                  _buildNumberField(
                    label: "Katha",
                    controller: _kathaController,
                  ),
                if (isLand)
                  _buildNumberField(
                    label: "Lessa",
                    controller: _lessaController,
                  ),
                if (isLand)
                  _buildNumberField(
                    label: "Price per Bigha",
                    controller: _pricePerBighaController,
                  ),
                if (isLand)
                  _buildNumberField(
                    label: "Price per Katha",
                    controller: _pricePerKathaController,
                  ),
                if (isLand)
                  _buildNumberField(
                    label: "Price per Lessa",
                    controller: _pricePerLessaController,
                  ),

                _buildTextField(
                  label: "Owner Name",
                  onChanged: (v) => _ownerName = v,
                ),

                _buildNumberField(
                  label: "Owner Number",
                  onChanged: (value) => setState(() => _ownerPhone = value),
                ),

                _buildNumberField(
                  label: "Alternate Number (Optional)",
                  onChanged: (value) => setState(() => _alternatePhone = value),
                ),

                _buildTextField(
                  label: "Map URL",
                  controller: _mapUrlController,
                ),

                _buildTextField(
                  label: "Description",
                  maxLines: 3,
                  controller: _descriptionController,
                ),
                const SizedBox(height: 20),

                Text(
                  "Photos",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.20),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _pickImages,
                  child: const Text("+ Add Photos"),
                ),

                const SizedBox(height: 10),

                if (_images.isNotEmpty)
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _images.map((img) {
                      final file = File(img);

                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: file.existsSync()
                                ? Image.file(
                                    file,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 90,
                                    height: 90,
                                    color: Colors.white24,
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _images.remove(img);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 20),

                // For now just a placeholder button
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.20),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      // ---------- BASIC VALIDATION ----------
                      if (_category == null ||
                          _location == null ||
                          _images.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Please complete all required fields",
                            ),
                          ),
                        );
                        return;
                      }

                      // ---------- PROPERTY ID VALIDATION ----------
                      if (_propertyIdController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter Property ID"),
                          ),
                        );
                        return;
                      }

                      // ---------- BUILD FULL PROPERTY ID ----------
                      final fullPropertyId =
                          "${getPropertyPrefix(_category!)}${_propertyIdController.text.trim()}";

                      final box = Hive.box<Property>('properties');

                      // ---------- CREATE PROPERTY ----------
                      final newProperty = Property(
                        propertyId: fullPropertyId, // ✅ CORRECT PLACE
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        category: _category!,
                        furnishing: _furnishing,
                        title: _titleController.text,
                        location: _location!,
                        price: _priceController.text.replaceAll("₹", "").trim(),
                        pricePerSqft: _pricePerSqftController.text.isNotEmpty
                            ? _pricePerSqftController.text
                            : null,
                        images: _images,
                        priceCategoryMax: _priceCategoryMax, // ✅ ADD THIS LINE

                        bhk: _bhk,
                        bathrooms: _bathrooms,

                        sbua: _sbuaController.text.isNotEmpty
                            ? _sbuaController.text
                            : null,
                        carpetArea: _carpetAreaController.text.isNotEmpty
                            ? _carpetAreaController.text
                            : null,
                        floor: _floorController.text.isNotEmpty
                            ? _floorController.text
                            : null,

                        bigha: _bighaController.text.isNotEmpty
                            ? _bighaController.text
                            : null,
                        katha: _kathaController.text.isNotEmpty
                            ? _kathaController.text
                            : null,
                        lessa: _lessaController.text.isNotEmpty
                            ? _lessaController.text
                            : null,

                        pricePerBigha: _pricePerBighaController.text.isNotEmpty
                            ? _pricePerBighaController.text
                            : null,
                        pricePerKatha: _pricePerKathaController.text.isNotEmpty
                            ? _pricePerKathaController.text
                            : null,
                        pricePerLessa: _pricePerLessaController.text.isNotEmpty
                            ? _pricePerLessaController.text
                            : null,

                        parking: _carParking,

                        ownerPhone: _ownerPhone,
                        alternatePhone: _alternatePhone,

                        mapUrl: _mapUrlController.text.isNotEmpty
                            ? _mapUrlController.text
                            : null,
                        description: _descriptionController.text.isNotEmpty
                            ? _descriptionController.text
                            : null,

                        propertyType: _type,
                        lift: _lift,
                        coupleFriendly: _coupleFriendly,
                        independent: _independent,
                        muslimAllowed: _muslimAllowed,
                        ownerName: _ownerName?.trim().isNotEmpty == true
                            ? _ownerName!.trim()
                            : null,
                        customLocation:
                            _customLocation?.trim().isNotEmpty == true
                            ? _customLocation!.trim()
                            : null,
                        apartmentType: _apartmentType,
                        propertyAge:
                            _propertyAgeController.text.trim().isNotEmpty
                            ? _propertyAgeController.text.trim()
                            : null,
                        handoverDate: _handoverDate,
                      );

                      // ---------- SAVE ----------
                      // ---------- SAVE / UPDATE ----------
                      if (widget.editIndex != null) {
                        // ✏️ EDIT MODE
                        await box.putAt(widget.editIndex!, newProperty);

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Property Updated")),
                        );
                      } else {
                        // 🆕 NEW PROPERTY
                        await box.add(newProperty);

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Property Saved")),
                        );
                      }

                      Navigator.pop(context);
                    },

                    child: Text(
                      widget.editIndex != null
                          ? "Update Property"
                          : "Save Property",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- helpers ---

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    String? hint,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: Colors.white),
        onChanged: onChanged,
        decoration: _inputDecoration(label, hint),
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label, null),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        dropdownColor: const Color(0xFF003845),
        decoration: _inputDecoration(label, null),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildRadioRow({
    required String label,
    required bool? value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white)),
          ),

          Radio<bool>(
            value: true,
            // ignore: deprecated_member_use
            groupValue: value,
            // ignore: deprecated_member_use
            onChanged: onChanged,
            activeColor: Colors.white,
          ),
          const Text("Yes", style: TextStyle(color: Colors.white70)),

          Radio<bool>(
            value: false,
            // ignore: deprecated_member_use
            groupValue: value,
            // ignore: deprecated_member_use
            onChanged: onChanged,
            activeColor: Colors.white,
          ),
          const Text("No", style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String? hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.08),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white),
      ),
    );
  }
}

// ================= TEMP LOCATION LIST (GUWAHATI ONLY) =================
List<String> guwahatiAreas = [
  "Guwahati",
  "Adabari",
  "Ajanta Path",
  "Amsing Jorabat",
  "Amingaon",
  "Ananda Nagar",
  "Athgaon",
  "Ambikagiri",
  "Bamunimaidam",
  "Barbari Village",
  "Barsapara",
  "Basistha",
  "Beltola",
  "Bhangagarh",
  "Bharalumukh",
  "Bhetapara",
  "Bonda",
  "Borbari",
  "Bora Service",
  "Bormotoria",
  "Chandmari",
  "Chenikuthi",
  "Chatribari",
  "Christian Basti",
  "Dhirenpara",
  "Dispur",
  "Dharapur",
  "Downtown",
  "Fatasil Ambari",
  "Fancy Bazar",
  "Forest Gate",
  "Ganeshguri",
  "Gandhi Basti",
  "Garchuk",
  "Gauhati Club",
  "Geetanagar",
  "Ghoramara",
  "Gopal Nagar",
  "Gotanagar",
  "GS Road",
  "Hatigaon",
  "Hengrabari",
  "Hajo Road",
  "ISBT (Betkuchi)",
  "Indrapur",
  "Jalukbari",
  "Japorigog",
  "Jayanagar",
  "Jatia",
  "Jonali",
  "Joyanagar",
  "Jyotikuchi",
  "Kahilipara",
  "Kalapahar",
  "Kalitakuchi",
  "Kamakhya",
  "Kharghuli",
  "Khanapara",
  "Kumarpara",
  "Lachit Nagar",
  "Lal Ganesh",
  "Lankeswar",
  "Lokhra",
  "Maligaon",
  "Mathgharia",
  "Milanpur",
  "Maanpara",
  "Mother Teresa Road",
  "MRD Road",
  "Noonmati",
  "Narengi",
  "Nabagraha",
  "Nayanpur",
  "Nizarapar",
  "Narikalbasti",
  "Odalbakra",
  "Pan Bazar",
  "Paltan Bazar",
  "Panjabari",
  "Patharquerry",
  "Pub Sarania",
  "Pamohi",
  "Pandu",
  "Rehabari",
  "Rupnagar",
  "Rukminigaon",
  "Rani",
  "Rajgarh",
  "Ram Nagar",
  "Santipur",
  "Sarumotoria",
  "Sijubari",
  "Six Mile",
  "Sonaighuli",
  "Silpukhuri",
  "Sunchali",
  "South Sarania",
  "Tarun Nagar",
  "Tengapara",
  "Tetelia",
  "Tinali",
  "Ulubari",
  "Uzan Bazar",
  "VIP Road",
  "Wireless",
  "Zoo Road",
  "Zoo Tiniali",
];
String getPropertyPrefix(String category) {
  switch (category) {
    case "Sale":
      return "RRES-20";
    case "Rent":
      return "RRER-10";
    case "Land":
      return "RREPL-30";
    default:
      return "";
  }
}

class PriceCategory {
  final String label;
  final int? maxAmount; // in rupees, null = No Limit

  const PriceCategory(this.label, this.maxAmount);
}

const List<PriceCategory> priceCategories = [
  PriceCategory("Under 30 LACs", 3000000),
  PriceCategory("Under 40 LACs", 4000000),
  PriceCategory("Under 50 LACs", 5000000),
  PriceCategory("Under 60 LACs", 6000000),
  PriceCategory("Under 70 LACs", 7000000),
  PriceCategory("Under 80 LACs", 8000000),
  PriceCategory("Under 90 LACs", 9000000),
  PriceCategory("Under 1 CR", 10000000),
  PriceCategory("Under 1.5 CR", 15000000),
  PriceCategory("Under 2 CR", 20000000),
  PriceCategory("No Limit", null),
];

//===================================================================================================================================================================================================
//              THIS IS FOR THE RENT/SALR/LAND LISTING AND CARD VIEW
//===================================================================================================================================================================================================

//===================================================================================================================================================================================================
//              THIS IS FOR PROPERTY LIST SCREEN
//===================================================================================================================================================================================================
class PropertyListScreen extends StatefulWidget {
  final String filterCategory;

  const PropertyListScreen({super.key, required this.filterCategory});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  String? selectedBhk;
  String? selectedLocation;

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Property>('properties');
    final filtered = <Map<String, dynamic>>[];

    for (int i = box.length - 1; i >= 0; i--) {
      final p = box.getAt(i);

      if (p == null) continue;

      // CATEGORY
      if (p.category != widget.filterCategory) continue;

      // BHK FILTER
      if (selectedBhk != null && selectedBhk!.isNotEmpty) {
        if (p.bhk != selectedBhk) continue;
      }

      // LOCATION FILTER
      if (selectedLocation != null && selectedLocation!.isNotEmpty) {
        if (p.location != selectedLocation) continue;
      }

      filtered.add({"property": p, "hiveIndex": i});
    }

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
              // ---------- HEADER ----------
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Text(
                    "${widget.filterCategory} Properties",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              const SizedBox(height: 10),

              // ---------- PROPERTY LIST ----------
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length + 1, // 👈 IMPORTANT
                  itemBuilder: (context, index) {
                    // 🔥 FIRST ITEM = FILTER UI
                    if (index == 0) {
                      if (widget.filterCategory == "Land") {
                        return const SizedBox(); // no filter for land
                      }
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: selectedBhk,
                                    isExpanded: true,
                                    hint: const Text(
                                      "BHK",
                                      style: TextStyle(color: Colors.white70),
                                    ), //
                                    dropdownColor: const Color(0xFF003845),
                                    style: const TextStyle(color: Colors.white),
                                    items:
                                        [
                                              "Single Room",
                                              "1RK",
                                              "2RK",
                                              "1 BHK",
                                              "2 BHK",
                                              "3 BHK",
                                              "4 BHK",
                                              "5 BHK",
                                            ]
                                            .map(
                                              (e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(e),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (val) {
                                      setState(() => selectedBhk = val);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: selectedLocation,
                                    isExpanded: true,
                                    hint: const Text(
                                      "Location",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    dropdownColor: const Color(0xFF003845),
                                    style: const TextStyle(color: Colors.white),
                                    items: guwahatiAreas
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(e),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) {
                                      setState(() => selectedLocation = val);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              setState(() {
                                selectedBhk = null;
                                selectedLocation = null;
                              });
                            },
                            child: const Text(
                              "Clear Filters",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),

                          const SizedBox(height: 10),
                        ],
                      );
                    }

                    // 🔥 EMPTY STATE (IMPORTANT FIX)
                    if (filtered.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Text(
                            "No properties found",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      );
                    }

                    final item = filtered[index - 1];
                    final p = item["property"];
                    final hiveIndex = item["hiveIndex"];

                    final bool unavailable = p.isAvailable == false;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PropertyDetailsScreen(
                              property: p,
                              index: hiveIndex,
                            ),
                          ),
                        );
                      },

                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: unavailable
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: unavailable
                                ? Colors.redAccent
                                : Colors.white24,
                          ),
                        ),

                        child: Row(
                          children: [
                            // ---------- IMAGE PREVIEW ----------
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: () {
                                if (p.images.isEmpty) {
                                  return Container(
                                    width: 90,
                                    height: 90,
                                    color: Colors.white24,
                                    child: const Icon(
                                      Icons.home,
                                      color: Colors.white70,
                                    ),
                                  );
                                }

                                final file = File(p.images.first);

                                return file.existsSync()
                                    ? Image.file(
                                        file,
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 90,
                                        height: 90,
                                        color: Colors.white24,
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.white,
                                        ),
                                      );
                              }(),
                            ),

                            const SizedBox(width: 12),

                            // ---------- TEXT DETAILS ----------
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.safeDash(p.title),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),

                                  if (unavailable)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        "UNAVAILABLE",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                  Text(
                                    p.propertyId,
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),

                                  const SizedBox(height: 4),
                                  Text(
                                    p.safeDash(p.location),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),

                                  const SizedBox(height: 8),
                                  Text(
                                    "₹${p.safeDash(p.price)}/-",
                                    style: const TextStyle(
                                      color: Color(0xFF5FFFAF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ---------- FOOTER ----------
              appFooter(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

//===================================================================================================================================================================================================
//             THIS IS FOR THE PROPERTY DETAILS SCREEN
//===================================================================================================================================================================================================
class PropertyDetailsScreen extends StatelessWidget {
  final Property property;
  final int index;

  const PropertyDetailsScreen({
    super.key,
    required this.property,
    required this.index,
  });

  bool get isRent => property.category == "Rent";
  bool get isSale => property.category == "Sale";
  bool get isLand => property.category == "Land";

  String formatPricePerSqft() {
    if (property.sbua == null) return "";

    final price =
        int.tryParse(property.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final area =
        int.tryParse(property.sbua!.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    if (price == 0 || area == 0) return "";

    return "💲 Price/sqft: ₹${(price / area).round()}";
  }

  String addLine(String? label, dynamic value, {String? suffix}) {
    if (value == null || value.toString().trim().isEmpty) return "";
    return "$label${suffix != null ? "$value $suffix" : value}\n";
  }

  String buildPropertyShareText() {
    final profileBox = Hive.box<ProfileModel>('profile');
ProfileModel? profile;

if (profileBox.isNotEmpty) {
  profile = profileBox.getAt(0);
}
String text = """
📍 ${property.title}
🆔 ${property.propertyId}
📌 ${property.location}
${property.customLocation?.isNotEmpty == true ? "📍 Nearby: ${property.customLocation}" : ""}
💰 ₹${property.price}
""";

  // 🔹 COMPACT DETAILS LINE
  List<String> details = [];

  if (property.bhk != null) details.add("🛏 ${property.bhk}");
  if (property.bathrooms != null) details.add("🚿 ${property.bathrooms} Ba");
  if (property.furnishing != null) details.add("🛋 ${property.furnishing}");
  if (property.sbua != null) details.add("📏 ${property.sbua} sqft");
  if (property.carpetArea != null) details.add("📐 ${property.carpetArea} sqft");
  if (property.parking != null) details.add("🚗 ${property.parking}");
  if (property.lift != null) {
    details.add("🛗 ${property.lift! ? "Yes" : "No"}");
  }

  if (isSale && property.propertyType != null) {
    details.add("🧾 ${property.propertyType}");
  }

  if (property.apartmentType != null) {
    details.add("🏢 ${property.apartmentType}");
  }

  if (property.floor != null) {
    details.add("🏬 Floor ${property.floor}");
  }

  if (property.propertyAge != null) {
    details.add("⏳ ${property.propertyAge} yrs");
  }

  if (property.handoverDate != null) {
    details.add("📅 ${property.handoverDate}");
  }

  if (isRent && property.coupleFriendly != null) {
    details.add("❤️ ${property.coupleFriendly! ? "Couple OK" : "No Couples"}");
  }

  if (isRent && property.independent != null) {
    details.add("🏠 ${property.independent! ? "Independent" : "Shared"}");
  }

  // LAND DETAILS
  if (isLand) {
    if (property.bigha != null) details.add("🌾 ${property.bigha} Bigha");
    if (property.katha != null) details.add("📌 ${property.katha} Katha");
    if (property.lessa != null) details.add("📍 ${property.lessa} Lessa");

    if (property.pricePerBigha != null) {
      details.add("💸 ₹${property.pricePerBigha}/Bigha");
    }
    if (property.pricePerKatha != null) {
      details.add("💸 ₹${property.pricePerKatha}/Katha");
    }
    if (property.pricePerLessa != null) {
      details.add("💸 ₹${property.pricePerLessa}/Lessa");
    }
  }

  // 🔹 ADD DETAILS LINE
  if (details.isNotEmpty) {
    text += "\n\n${details.join(" | ")}";
  }

  // 🔹 DESCRIPTION
  if (property.description != null &&
      property.description!.trim().isNotEmpty) {
    text += "\n\n📝 ${property.description}";
  }

  // 🔹 PROFILE
  if (profile != null) {
    text += """

━━━━━━━━━━━━━━━━━
👤 ${profile.name}
💼 ${profile.role}
🏢 ${profile.company}
📞 ${profile.phone}
${profile.email.isNotEmpty ? "📧 ${profile.email}" : ""}
""";
  }

    return text
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .join('\n')
        .replaceAll('\n━━━━━━━━━━━━━━━━━━\n\n', '\n━━━━━━━━━━━━━━━━━━\n')
        .replaceAll('\n\n━━━━━━━━━━━━━━━━━━', '\n━━━━━━━━━━━━━━━━━━');
  }

  Future<void> copyPropertyDetails(BuildContext context) async {
    final cleanedText = buildPropertyShareText();

    await Clipboard.setData(ClipboardData(text: cleanedText));

    ScaffoldMessenger.of(
      // ignore: use_build_context_synchronously
      context,
    ).showSnackBar(const SnackBar(content: Text("Copied to clipboard")));
  }

  Future<void> shareProperty() async {
    final cleanedText = buildPropertyShareText();

    await Clipboard.setData(ClipboardData(text: cleanedText));

    final imageFiles = property.images.map((path) => XFile(path)).toList();

    if (imageFiles.isNotEmpty) {
      await Share.shareXFiles(imageFiles, text: cleanedText);
    } else {
      await Share.share(cleanedText);
    }

    ScaffoldMessenger.of(
      navigatorKey.currentContext!,
    ).showSnackBar(const SnackBar(content: Text("📋 Caption copied & ready")));
  }

  Future<void> sendPropertyToClient(ClientModel client) async {
    final text = buildPropertyShareText();

    // Clean phone number (remove spaces, +, etc.)
    final phone = client.phone.replaceAll(RegExp(r'[^0-9]'), '');

    final encodedText = Uri.encodeComponent(text);

    final url = Uri.parse("https://wa.me/$phone?text=$encodedText");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        navigatorKey.currentContext!,
      ).showSnackBar(const SnackBar(content: Text("WhatsApp not installed")));
    }
  }

  

  @override
  Widget build(BuildContext context) {
    final interestedClients = getInterestedClients(property);
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
              // ---------- TOP BAR ----------
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      property.safeDash(property.title),

                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---------- IMAGE SLIDER ----------
                        if (property.images.isNotEmpty)
                          SizedBox(
                            height: 220,
                            child: PageView(
                              children: property.images.map((img) {
                                final file = File(img);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                PhotoViewGalleryScreen(
                                                  images: property.images,
                                                  initialIndex: property.images
                                                      .indexOf(img),
                                                ),
                                          ),
                                        );
                                      },
                                      child: file.existsSync()
                                          ? Image.file(
                                              file,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            )
                                          : Container(
                                              width: double.infinity,
                                              height: 220,
                                              color: Colors.white24,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  color: Colors.white,
                                                  size: 50,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        else
                          Container(
                            height: 220,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.home,
                                size: 60,
                                color: Colors.white70,
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // ---------- INFO ----------
                        // ---------- TITLE + LOCATION + PRICE ----------
                        // ---------- INFO ----------
                        // ---------- TITLE + LOCATION + PRICE ----------
                        Text(
                          property.safeDash(property.title),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          property.safeDash(property.location),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          "₹${property.safeDash(property.price)}/-",
                          style: const TextStyle(
                            fontSize: 22,
                            color: Color(0xFF5FFFAF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // ---------- MAIN DETAILS ----------
                        Text(
                          "Property Details",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 10),

                        _infoRow(
                          "Category",
                          property.safeDash(property.category),
                        ),

                        _infoRow("Property ID", property.propertyId),

                        if (property.priceCategoryMax != null)
                          _infoRow(
                            "Price Category",
                            "Under ₹${property.priceCategoryMax! ~/ 100000} L",
                          )
                        else
                          _infoRow("Price Category", "No Limit"),

                        if (property.furnishing != null)
                          _infoRow(
                            "Furnishing",
                            property.safeDash(property.furnishing),
                          ),

                        // ---------- RENT & SALE ----------
                        if (!isLand) ...[
                          _infoRow("BHK", property.safeDash(property.bhk)),
                          _infoRow(
                            "Bathrooms",
                            property.safeDash(property.bathrooms),
                          ),

                          _infoRow(
                            "SBUA",
                            property.sbua == null
                                ? "-"
                                : "${property.safeDash(property.sbua)} sqft",
                          ),

                          _infoRow(
                            "Carpet Area",
                            property.carpetArea == null
                                ? "-"
                                : "${property.safeDash(property.carpetArea)} sqft",
                          ),

                          _infoRow(
                            "Price per Sqft",
                            property.pricePerSqft != null
                                ? "₹${property.safeDash(property.pricePerSqft)}"
                                : "N/A",
                          ),

                          _infoRow("Floor", property.safeDash(property.floor)),
                          _infoRow(
                            "Parking",
                            property.safeDash(property.parking),
                          ),

                          _infoRow(
                            "Lift",
                            property.lift == true ? "Yes" : "No",
                          ),

                          _infoRow(
                            "Custom Location",
                            property.safeDash(property.customLocation),
                          ),
                        ],

                        // ---------- SALE ONLY ----------
                        if (isSale)
                          _infoRow(
                            "Sale Type",
                            property.safeDash(property.propertyType),
                          ),

                        // ---------- RENT ONLY ----------
                        if (isRent) ...[
                          _infoRow(
                            "Couple Friendly",
                            property.coupleFriendly == true ? "Yes" : "No",
                          ),
                          _infoRow(
                            "Independent",
                            property.independent == true ? "Yes" : "No",
                          ),
                          _infoRow(
                            "Muslim Allowed",
                            property.muslimAllowed == true ? "Yes" : "No",
                          ),
                        ],

                        if (property.apartmentType != null)
                          _infoRow(
                            "Apartment",
                            property.safeDash(property.apartmentType),
                          ),

                        if (property.propertyAge != null)
                          _infoRow(
                            "Property Age",
                            "${property.safeDash(property.propertyAge)} years",
                          ),

                        if (property.handoverDate != null)
                          _infoRow(
                            "Handover Date",
                            property.safeDash(property.handoverDate),
                          ),

                        // ---------- LAND ONLY ----------
                        if (isLand) ...[
                          _infoRow("Bigha", property.safeDash(property.bigha)),
                          _infoRow("Katha", property.safeDash(property.katha)),
                          _infoRow("Lessa", property.safeDash(property.lessa)),
                          _infoRow(
                            "Price per Bigha",
                            property.safeDash(property.pricePerBigha),
                          ),
                          _infoRow(
                            "Price per Katha",
                            property.safeDash(property.pricePerKatha),
                          ),
                          _infoRow(
                            "Price per Lessa",
                            property.safeDash(property.pricePerLessa),
                          ),
                        ],

                        const SizedBox(height: 25),

                        // ---------- CONTACT ----------
                        Text(
                          "Owner Details",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        if (property.ownerName != null &&
                            property.ownerName!.trim().isNotEmpty)
                          _infoRow(
                            "Name",
                            property.safeDash(property.ownerName),
                          ),

                        if (property.ownerPhone != null)
                          _infoRow(
                            "Phone",
                            property.safeDash(property.ownerPhone),
                            isPhone: true,
                          ),

                        if (property.alternatePhone != null)
                          _infoRow(
                            "Alternate",
                            property.safeDash(property.alternatePhone),
                            isPhone: true,
                          ),

                        if (property.mapUrl != null &&
                            property.mapUrl!.isNotEmpty)
                          _infoRow(
                            "Map",
                            property.safeDash(property.mapUrl),
                            isUrl: true,
                          ),

                        // ---------- DESCRIPTION ----------
                        if (property.description != null &&
                            property.description!.trim().isNotEmpty) ...[
                          Text(
                            "Description",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            property.safeDash(property.description),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],

                        if (interestedClients.isNotEmpty) ...[
                          const SizedBox(height: 30),

                          const Text(
                            "Interested Clients",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 10),

                          ...interestedClients.map((client) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${client.name} • ${client.categories.join(", ")} • ${client.preferredLocations.join(", ")}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      sendPropertyToClient(client);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],

                        // ---------- ACTION BUTTONS ----------
                        Wrap(
                          spacing: 14, // horizontal gap
                          runSpacing: 12, // vertical gap when wrapped
                          alignment: WrapAlignment.center,
                          children: [
                            _actionButton(Icons.edit, "Edit", () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ListPropertyScreen(
                                    existingProperty: property,
                                    editIndex: index,
                                  ),
                                ),
                              );
                            }),

                            _actionButton(
                              Icons.share,
                              "Share",
                              () => shareProperty(),
                            ),

                            _actionButton(
                              Icons.copy,
                              "Copy",
                              () => copyPropertyDetails(context),
                            ),

                            _actionButton(Icons.delete, "Delete", () async {
                              final box = Hive.box<Property>('properties');

                              final confirm = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: const Text("Delete Property?"),
                                    content: const Text(
                                      "Are you sure you want to permanently delete this property?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirm == true) {
                                final parentContext = context;

                                await box.deleteAt(index);

                                if (!parentContext.mounted) return;

                                Navigator.pop(parentContext);

                                ScaffoldMessenger.of(
                                  parentContext,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Property deleted successfully",
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }),

                            _actionButton(
                              property.isAvailable
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              property.isAvailable
                                  ? "Mark Unavailable"
                                  : "Mark Available",
                              () async {
                                final box = Hive.box<Property>('properties');

                                final updated = property.copyWith(
                                  isAvailable: !property.isAvailable,
                                );

                                await box.putAt(index, updated);

                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      updated.isAvailable
                                          ? "Property marked AVAILABLE"
                                          : "Property marked UNAVAILABLE",
                                    ),
                                  ),
                                );

                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),

              appFooter(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    bool isPhone = false,
    bool isUrl = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                if (isPhone) {
                  final uri = Uri(scheme: 'tel', path: value);
                  await launchUrl(uri);
                } else if (isUrl) {
                  String url = value.trim();

                  // Fix missing protocol
                  if (!url.startsWith("http://") &&
                      !url.startsWith("https://")) {
                    url = "https://$url";
                  }

                  // Detect Google Maps link
                  if (url.contains("google.com/maps") ||
                      url.contains("goo.gl/maps")) {
                    final googleMapsUri = Uri.parse(url);

                    // Try opening Google Maps app using geo: scheme
                    final mobileUri = Uri.parse("geo:0,0?q=$url");

                    // If maps app available → open app, else open browser
                    if (await canLaunchUrl(mobileUri)) {
                      await launchUrl(
                        mobileUri,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      await launchUrl(
                        googleMapsUri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  } else {
                    // Normal link
                    final uri = Uri.parse(url);
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              },

              child: Text(
                value,
                style: TextStyle(
                  color: Colors.white70, // normal text color
                  decoration: TextDecoration.none, // remove underline
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: Colors.white.withValues(alpha: 0.20),
            foregroundColor: Colors.white,
          ),
          onPressed: onTap,
          child: Icon(icon, size: 22),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

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
        bigha: property.bigha,
        katha: property.katha,
        lessa: property.lessa,

        pricePerSqft: property.pricePerSqft,
        pricePerBigha: property.pricePerBigha,
        pricePerKatha: property.pricePerKatha,
        pricePerLessa: property.pricePerLessa,

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

//===================================================================================================================================================================================================
//               REGISTER YOUR CLIENT SCREEN
//===================================================================================================================================================================================================
class RegisterClientScreen extends StatefulWidget {
  final ClientModel? existingClient;
  final dynamic hiveKey;

  const RegisterClientScreen({super.key, this.existingClient, this.hiveKey});

  @override
  State<RegisterClientScreen> createState() => _RegisterClientScreenState();
}

class _RegisterClientScreenState extends State<RegisterClientScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController altPhoneController = TextEditingController();

  // Selected values
  List<String> selectedCategories = [];
  List<String> selectedBHK = [];
  List<String> selectedLocations = [];
  List<String> selectedAmenities = [];
  List<String> selectedPriceLabels = []; // 👈 ADD THIS

  // Options
  final categoryOptions = ["Sale", "Rent", "Land"];
  final bhkOptions = [
    "Single Room",
    "1RK",
    "2RK",
    "3RK",
    "1 BHK",
    "2 BHK",
    "3 BHK",
    "4 BHK",
    "5 BHK",
  ];

  final amenitiesOptions = [
    "Car Parking",
    "Lift",
    "Independent",
    "Couple Friendly",
    "Muslim Allowed",
  ];
  final TextEditingController hometownController = TextEditingController();
  final TextEditingController professionController = TextEditingController();

  String? selectedClientType;

  final clientTypeOptions = ["Family", "Working Bachelors", "Student"];

  @override
  void initState() {
    super.initState();

    if (widget.existingClient != null) {
      final c = widget.existingClient!;

      nameController.text = c.name;
      phoneController.text = c.phone;
      altPhoneController.text = c.alternatePhone ?? "";

      hometownController.text = c.hometown ?? "";
      professionController.text = c.profession ?? "";

      selectedClientType = c.clientType;

      selectedCategories = List.from(c.categories);
      selectedBHK = List.from(c.bhkPreferences);
      selectedLocations = List.from(c.preferredLocations);
      selectedAmenities = List.from(c.amenities);

      selectedPriceLabels = c.priceCategoryMaxes.map((e) {
        if (e == null) return "No Limit";
        return priceCategories.firstWhere((p) => p.maxAmount == e).label;
      }).toList();
    }
  }

  // Accent for selected chips

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BACK BUTTON
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),

                const SizedBox(height: 10),

                // TITLE
                const Center(
                  child: Text(
                    "Register Client",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // INPUTS
                _buildTextField("Name", nameController),
                TextField(
                  controller: phoneController,
                  enabled: widget.existingClient == null, // 🔒 lock on edit
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Phone",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                  ),
                ),

                _buildTextField(
                  "Alternate Phone (Optional)",
                  altPhoneController,
                ),
                _buildTextField("Hometown", hometownController),

                _buildTextField("Profession", professionController),

                const SizedBox(height: 20),

                _buildTitle("Client Type"),
                _buildSingleSelectChips(clientTypeOptions),

                const SizedBox(height: 25),

                // CATEGORY
                _buildTitle("Category (max 3)"),
                _buildMultiSelectChips(categoryOptions, selectedCategories, 3),

                const SizedBox(height: 25),

                // BHK
                _buildTitle("BHK Preference (max 5)"),
                _buildMultiSelectChips(bhkOptions, selectedBHK, 5),

                const SizedBox(height: 25),

                // LOCATIONS
                _buildTitle("Preferred Locations (max 20)"),
                _buildMultiSelectChips(guwahatiAreas, selectedLocations, 20),

                const SizedBox(height: 25),

                // AMENITIES
                _buildTitle("Amenities"),
                _buildMultiSelectChips(amenitiesOptions, selectedAmenities, 20),

                if (selectedCategories.contains("Sale") ||
                    selectedCategories.contains("Land")) ...[
                  _buildTitle("Price Category (max 5)"),
                  _buildMultiSelectChips(
                    priceCategories.map((e) => e.label).toList(),
                    selectedPriceLabels,
                    3,
                  ),
                ],

                const SizedBox(height: 35),

                // SAVE BUTTON
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.20),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: saveClient,
                    child: Text(
                      widget.existingClient != null
                          ? "Update Client"
                          : "Save Client",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 35),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleSelectChips(List<String> options) {
    return Wrap(
      spacing: 10,
      children: options.map((item) {
        final isSelected = selectedClientType == item;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedClientType = item;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              item,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------- UI BUILDERS ----------------

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.08),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Improved chip styling so they are readable over the dark gradient.
  Widget _buildMultiSelectChips(
    List<String> options,
    List<String> selectedList,
    int maxSelection,
  ) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((item) {
        final bool isSelected = selectedList.contains(item);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedList.remove(item);
              } else if (selectedList.length < maxSelection) {
                selectedList.add(item);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.08,
              ), // SAME AS INPUT BOXES
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Colors
                          .white // highlight border
                    : Colors.white.withValues(alpha: 0.25),
                width: 1.2,
              ),
            ),
            child: Text(
              item,
              style: TextStyle(
                color: Colors.white, // SAME AS INPUT BOX TEXT
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------- SAVE CLIENT ----------------
  Future<void> saveClient() async {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name & phone are required")),
      );
      return;
    }

    final clientBox = Hive.box<ClientModel>('clients');

    final selectedMaxes = selectedPriceLabels
        .map(
          (label) =>
              priceCategories.firstWhere((e) => e.label == label).maxAmount,
        )
        .toList();

    final client = ClientModel(
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      alternatePhone: altPhoneController.text.trim().isEmpty
          ? null
          : altPhoneController.text.trim(),
      categories: selectedCategories,
      bhkPreferences: selectedBHK,
      preferredLocations: selectedLocations,
      amenities: selectedAmenities,

      // 🆕 NEW DATA
      hometown: hometownController.text.trim().isNotEmpty
          ? hometownController.text.trim()
          : null,
      profession: professionController.text.trim().isNotEmpty
          ? professionController.text.trim()
          : null,
      clientType: selectedClientType,
      priceCategoryMaxes: selectedMaxes,
    );

    if (widget.existingClient != null) {
      // ✏️ EDIT MODE
      await clientBox.put(widget.hiveKey, client);
    } else {
      // 🆕 NEW CLIENT
      await clientBox.add(client);
    }

    // ✅ SAFETY CHECK
    if (!mounted) return;

    // ✅ SINGLE UI UPDATE
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.existingClient != null
              ? "Client updated successfully"
              : "Client saved successfully",
        ),
      ),
    );

    // ✅ GO BACK
    Navigator.pop(context);
  }
}

//===================================================================================================================================================================================================
//           VIEW YOUR CLIENT SCREEN
//===================================================================================================================================================================================================

// ViewClientsScreen.dart (place into your main file or a new file and import it)
class ViewClientsScreen extends StatefulWidget {
  const ViewClientsScreen({super.key});

  @override
  State<ViewClientsScreen> createState() => _ViewClientsScreenState();
}

class _ViewClientsScreenState extends State<ViewClientsScreen> {
  late Box<ClientModel> clientsBox;

  @override
  void initState() {
    super.initState();
    clientsBox = Hive.box<ClientModel>('clients');
  }

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
              // ---------- HEADER (MATCHES PROPERTY LIST) ----------
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Text(
                    "Your Clients",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ---------- CLIENT LIST ----------
              Expanded(
                child: ValueListenableBuilder<Box<ClientModel>>(
                  valueListenable: clientsBox.listenable(),
                  builder: (context, box, _) {
                    if (box.isEmpty) {
                      return const Center(
                        child: Text(
                          "No clients registered",
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: box.length,
                      itemBuilder: (context, index) {
                        final client = box.getAt(index)!;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ClientDetailsScreen(
                                  client: client,
                                  hiveKey: box.keyAt(index),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              children: [
                                // Avatar
                                CircleAvatar(
                                  backgroundColor: Colors.white12,
                                  child: Text(
                                    client.name.isNotEmpty
                                        ? client.name[0].toUpperCase()
                                        : "?",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        client.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        client.phone,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Category: ${client.categories.join(", ")}",
                                        style: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // More actions
                                PopupMenuButton(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.white,
                                  ),
                                  color: const Color(0xFF003845),
                                  onSelected: (value) {
                                    if (value == "delete") {
                                      box.delete(box.keyAt(index));

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Client deleted"),
                                        ),
                                      );
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: "delete",
                                      child: Text("Delete"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

//===================================================================================================================================================================================================
//       CLIENT DETAIL SCREEN
//===================================================================================================================================================================================================

class ClientDetailsScreen extends StatelessWidget {
  final ClientModel client;
  final dynamic hiveKey;

  const ClientDetailsScreen({
    super.key,
    required this.client,
    required this.hiveKey,
  });

  @override
  Widget build(BuildContext context) {
    final matchingProperties = getMatchingProperties(client);
    return Scaffold(
      body: Container(
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
              // ---------- TOP BAR ----------
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Text(
                    "Client Details",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("Basic Info"),
                      _info("Name", client.name),
                      GestureDetector(
                        onTap: () async {
                          final uri = Uri(scheme: 'tel', path: client.phone);
                          await launchUrl(uri);
                        },
                        child: _info("Phone", client.phone),
                      ),

                      if (client.alternatePhone != null)
                        GestureDetector(
                          onTap: () async {
                            final uri = Uri(
                              scheme: 'tel',
                              path: client.alternatePhone!,
                            );
                            await launchUrl(uri);
                          },
                          child: _info("Alternate", client.alternatePhone!),
                        ),

                      const SizedBox(height: 20),
                      if (client.hometown != null)
                        _info("Hometown", client.hometown!),

                      if (client.profession != null)
                        _info("Profession", client.profession!),

                      if (client.clientType != null)
                        _info("Type", client.clientType!),

                      _sectionTitle("Preferences"),
                      _chips("Category", client.categories),
                      _chips("BHK", client.bhkPreferences),
                      _chips("Locations", client.preferredLocations),
                      _chips("Amenities", client.amenities),

                      if (matchingProperties.isNotEmpty) ...[
                        const SizedBox(height: 30),

                        const Text(
                          "Matching Properties",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        if (client.priceCategoryMaxes.isNotEmpty)
                          _chips(
                            "Price Category",
                            client.priceCategoryMaxes.map((e) {
                              if (e == null) return "No Limit";
                              return "Under ₹${e ~/ 100000} L";
                            }).toList(),
                          ),

                        const SizedBox(height: 10),

                        ...matchingProperties.map((p) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "${p.title} • ${p.location} • ${p.bhk ?? ""}",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.open_in_new,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                PropertyDetailsScreen(
                                                  property: p,
                                                  index: Hive.box<Property>(
                                                    'properties',
                                                  ).values.toList().indexOf(p),
                                                ),
                                          ),
                                        );
                                      },
                                    ),

                                    IconButton(
                                      icon: const Icon(
                                        Icons.send,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        sendPropertyToClientOnWhatsApp(
                                          property: p,
                                          client: client, // 👈 fixed client
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],

                      const SizedBox(height: 30),

                      // ---------- ACTIONS ----------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _actionButton(Icons.edit, "Edit", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RegisterClientScreen(
                                  existingClient: client,
                                  hiveKey: hiveKey,
                                ),
                              ),
                            );
                          }),

                          _actionButton(Icons.delete, "Delete", () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Delete client?"),
                                content: const Text(
                                  "This action cannot be undone.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              final box = Hive.box<ClientModel>('clients');
                              await box.delete(hiveKey);

                              if (!context.mounted) return;
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Client deleted")),
                              );
                            }
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- UI HELPERS ----------

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        "$label: $value",
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _chips(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((e) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08), // 🔥 SAME AS BOXES
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Text(e, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: Colors.white.withValues(alpha: 0.20),
          ),
          onPressed: onTap,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

//===================================================================================================================================================================================================
//           MATCHING ENGINE code can go here
//===================================================================================================================================================================================================
// 🔹 Matching Engine (Property → Clients)
List<ClientModel> getInterestedClients(Property property) {
  final box = Hive.box<ClientModel>('clients');
  final List<ClientModel> matches = [];

  if (property.isAvailable == false) return [];

  for (int i = 0; i < box.length; i++) {
    final client = box.getAt(i);
    if (client == null) continue;

    // 1️⃣ CATEGORY
    if (!client.categories.contains(property.category)) continue;

    // 2️⃣ LOCATION (FIXED)
    final propertyLocation = property.location.toLowerCase().trim();

    final clientLocations = client.preferredLocations
        .map((e) => e.toLowerCase().trim())
        .toList();

    if (!clientLocations.contains("guwahati")) {
      if (!clientLocations.any(
        (loc) =>
            propertyLocation == loc ||
            propertyLocation.contains(loc) ||
            loc.contains(propertyLocation),
      )) {
        continue;
      }
    }

    // 3️⃣ BHK
    if (client.bhkPreferences.isNotEmpty &&
        property.bhk != null &&
        property.bhk!.isNotEmpty) {
      if (!client.bhkPreferences.contains(property.bhk)) continue;
    }

    // 4️⃣ PRICE
    if (!priceMatches(property, client)) continue;

    matches.add(client);
  }

  return matches;
}

// 🔹 Matching Engine (Client → Properties)
List<Property> getMatchingProperties(ClientModel client) {
  final box = Hive.box<Property>('properties');
  final List<Property> matches = [];

  for (int i = 0; i < box.length; i++) {
    final property = box.getAt(i);
    if (property == null) continue;

    if (property.isAvailable == false) continue;

    // 1️⃣ CATEGORY
    if (!client.categories.contains(property.category)) continue;

    // 2️⃣ LOCATION (FIXED)
    final propertyLocation = property.location.toLowerCase().trim();

    final clientLocations = client.preferredLocations
        .map((e) => e.toLowerCase().trim())
        .toList();

    if (!clientLocations.contains("guwahati")) {
      if (!clientLocations.any(
        (loc) =>
            propertyLocation == loc ||
            propertyLocation.contains(loc) ||
            loc.contains(propertyLocation),
      )) {
        continue;
      }
    }

    // 3️⃣ BHK
    if (client.bhkPreferences.isNotEmpty &&
        property.bhk != null &&
        property.bhk!.isNotEmpty) {
      if (!client.bhkPreferences.contains(property.bhk)) continue;
    }

    // 4️⃣ PRICE
    if (!priceMatches(property, client)) continue;

    matches.add(property);
  }

  return matches;
}

bool priceMatches(Property property, ClientModel client) {
  // 🔴 Skip price logic for Rent
  if (property.category == "Rent") {
    return true;
  }

  if (client.priceCategoryMaxes.contains(null)) {
    return true;
  }

  if (property.priceCategoryMax == null) {
    return true;
  }

  for (final clientMax in client.priceCategoryMaxes) {
    if (clientMax != null && property.priceCategoryMax! <= clientMax) {
      return true;
    }
  }

  return false;
}

Future<void> sendPropertyToClientOnWhatsApp({
  required Property property,
  required ClientModel client,
}) async {
  String buildPropertyShareText(Property property) {
    String text =
        """
📍 *${property.title}*
📌 Location: ${property.location}
${property.customLocation?.isNotEmpty == true ? "📍 Nearby: ${property.customLocation}" : ""}
💰 Price: ₹${property.price}

━━━━━━━━━━━━━━━━━
🏢 *Property Details*
━━━━━━━━━━━━━━━━━
${property.bhk != null ? "🛏 BHK: ${property.bhk}" : ""}
${property.bathrooms != null ? "🚿 Bathrooms: ${property.bathrooms}" : ""}
${property.furnishing != null ? "🛋 Furnishing: ${property.furnishing}" : ""}
${property.sbua != null ? "📏 SBUA: ${property.sbua} sqft" : ""}
${property.carpetArea != null ? "📐 Carpet Area: ${property.carpetArea} sqft" : ""}
${property.floor != null ? "🏬 Floor: ${property.floor}" : ""}
${property.parking != null ? "🚗 Parking: ${property.parking}" : ""}
━━━━━━━━━━━━━━━━━
${property.description?.isNotEmpty == true ? "📝 *Description:*\n${property.description}" : ""}
""";

    return text.split('\n').where((l) => l.trim().isNotEmpty).join('\n');
  }

  final message = Uri.encodeComponent(buildPropertyShareText(property));

  final phone = client.phone.replaceAll(RegExp(r'[^0-9]'), '');

  final url = Uri.parse("https://wa.me/$phone?text=$message");

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(
      navigatorKey.currentContext!,
    ).showSnackBar(const SnackBar(content: Text("WhatsApp not installed")));
  }
}
