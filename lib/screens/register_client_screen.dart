import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ignore: unused_import
import '../main.dart';
import '../models/client_model.dart';
import 'list_property_screen.dart';





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