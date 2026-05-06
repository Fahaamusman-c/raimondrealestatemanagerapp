import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/property_model.dart';

class ListPropertyScreen extends StatefulWidget {
  final Property? existingProperty;
  final int? editIndex;

  const ListPropertyScreen({super.key, this.existingProperty, this.editIndex});

  @override
  State<ListPropertyScreen> createState() => _ListPropertyScreenState();
}

class _ListPropertyScreenState extends State<ListPropertyScreen> {
  String? _category;
  String? _condition;
  String? _landType;
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

  final TextEditingController _landSpaceController = TextEditingController();

  String selectedUnit = "Sq ft";

  final List<String> landUnits = [
    "Sq ft",
    "Sqm",
    "Acres",
    "Hectares",
    "Bigha (Assam)",
    "Bigha (West Bengal)",
    "Bigha (Rajasthan)",
    "Bigha (Bihar)",
    "Katha (Assam)",
    "Katha (Bihar)",
    "Katha (West Bengal)",
    "Lecha/Lessa (Assam)",
    "Guntha/Gunta",
    "Cent",
    "Kanal",
    "Marla",
    "Biswa",
    "Dhur",
    "Are",
    "Decimals",
  ];
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

  String? _landAreaUnit;
  final TextEditingController _landAreaController = TextEditingController();
  final TextEditingController _landSqftController = TextEditingController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _pricePerSqftController = TextEditingController();

  final TextEditingController _sbuaController = TextEditingController();
  final TextEditingController _carpetAreaController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();

  final TextEditingController _mapUrlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _propertyAgeController = TextEditingController();
  final TextEditingController _propertyIdController = TextEditingController();
  final TextEditingController _propertyPrefixController =
      TextEditingController();

  bool get isRent => _category == "Rent (Residential)";
  bool get isSale => _category == "Sale (Residential)";
  bool get isLand => _category == "Land";
  bool? _lift;
  bool? _coupleFriendly;
  bool? _independent;
  bool? _muslimAllowed;

  void calculateSqft() {
    final value = double.tryParse(_landAreaController.text);

    if (value == null || _landAreaUnit == null) {
      _landSqftController.clear();
      return;
    }

    final sqft = value * landUnitToSqft[_landAreaUnit]!;

    _landSqftController.text = sqft.toStringAsFixed(2);
  }

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
                  items: const [
                    "Rent (Residential)",
                    "Sale (Residential)",
                    "Commercial",
                    "Villas & Buildings",
                    "Land",
                  ],
                  onChanged: (val) {
                    setState(() {
                      _category = val;
                      _propertyPrefixController.text = getPropertyPrefix(
                        val!,
                      ); // 👈 THIS LINE
                    });
                  },
                ),

                if (isLand)
                  _buildDropdown(
                    label: "Type",
                    value: _landType,
                    items: const ["Residential", "Commercial", "Agriculture"],
                    onChanged: (val) {
                      setState(() {
                        _landType = val;
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

                if (isLand)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _landSpaceController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                              "Space",
                              "Ex: 12.5 or 20,000",
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedUnit,
                            dropdownColor: const Color(0xFF003845),
                            decoration: _inputDecoration("Unit", null),
                            items: landUnits
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  selectedUnit = val;
                                });
                              }
                            },
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (isLand)
                  _buildNumberField(
                    label: "Land Area",
                    controller: _landAreaController,
                    onChanged: (_) => calculateSqft(),
                  ),

                if (isLand)
                  _buildDropdown(
                    label: "Unit",
                    value: _landAreaUnit,
                    items: landUnitToSqft.keys.toList(),
                    onChanged: (val) {
                      setState(() {
                        _landAreaUnit = val;
                      });

                      calculateSqft();
                    },
                  ),

                if (isLand)
                  _buildTextField(
                    label: "Area in Sq Ft",
                    controller: _landSqftController,
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
                    label: "Condition",
                    value: _condition,
                    items: const [
                      "Resell",
                      "Newly Constructed",
                      "Under Construction",
                    ],
                    onChanged: (val) => setState(() => _condition = val),
                  ),
                if (isSale && _condition == "Resell")
                  _buildNumberField(
                    label: "Property Age (Years)",
                    controller: _propertyAgeController,
                  ),

                if (isSale && _condition== "Under Construction")
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

                        landArea: _landAreaController.text.trim().isNotEmpty
                            ? _landAreaController.text.trim()
                            : null,

                        landAreaUnit: _landAreaUnit,

                        landAreaSqft: _landSqftController.text.trim().isNotEmpty
                            ? _landSqftController.text.trim()
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

                        propertyType: _condition,
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
    case "Sale (Residential)":
      return "RRES-20";

    case "Rent (Residential)":
      return "RRER-10";

    case "Commercial":
      return "RREC-40";

    case "Villas & Buildings":
      return "RREV-50";

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

const Map<String, double> landUnitToSqft = {
  "Sqm": 10.7639,
  "Acres": 43560,
  "Hectares": 107639,
  "Bigha (Assam)": 14400,
  "Bigha (West Bengal)": 14400,
  "Bigha (Rajasthan)": 27225,
  "Bigha (Bihar)": 27220,
  "Katha (Assam)": 2880,
  "Katha (Bihar)": 1361,
  "Katha (West Bengal)": 720,
  "Lecha/Lessa (Assam)": 144,
  "Guntha/Gunta": 1089,
  "Cent": 435.6,
  "Kanal": 5445,
  "Marla": 272.25,
  "Biswa": 1350,
  "Dhur": 68.06,
  "Are": 1076.39,
  "Decimals": 435.6,
};
