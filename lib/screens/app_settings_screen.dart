import 'package:flutter/material.dart';

import '../utils/property_migration.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  // 🔹 TEMP STATE (UI only)
  String? selectedCountry = "India";
  String? selectedState = "Assam";
  String? selectedCity = "Guwahati";

  String? selectedCurrency = "INR";
  String? selectedTheme = "Dark";

  bool includeProfile = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Settings"),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF002b36), Color(0xFF065f73)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ================= LOCATION =================
            const Text(
              "📍 Location",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            _buildDropdown(
              value: selectedCountry,
              hint: "Country",
              items: ["India"],
              onChanged: (val) => setState(() => selectedCountry = val),
            ),

            const SizedBox(height: 10),

            _buildDropdown(
              value: selectedState,
              hint: "State",
              items: ["Assam"],
              onChanged: (val) => setState(() => selectedState = val),
            ),

            const SizedBox(height: 10),

            _buildDropdown(
              value: selectedCity,
              hint: "City",
              items: ["Guwahati"],
              onChanged: (val) => setState(() => selectedCity = val),
            ),

            const SizedBox(height: 25),

            // ================= CURRENCY =================
            const Text(
              "💰 Currency",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            _buildDropdown(
              value: selectedCurrency,
              hint: "Currency",
              items: ["INR"],
              onChanged: (val) => setState(() => selectedCurrency = val),
            ),

            const SizedBox(height: 25),

            // ================= SHARING =================
            const Text(
              "📤 Sharing",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: _boxDecoration(),
              child: SwitchListTile(
                value: includeProfile,
                onChanged: (val) {
                  setState(() => includeProfile = val);
                },
                title: const Text(
                  "Include Profile in Share",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ================= THEME =================
            const Text(
              "🌙 Theme",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            _buildDropdown(
              value: selectedTheme,
              hint: "Theme",
              items: ["Dark", "Light"],
              onChanged: (val) => setState(() => selectedTheme = val),
            ),
            const SizedBox(height: 30),

const Text(
  "Maintenance",
  style: TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 12),

SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    icon: const Icon(Icons.sync),
    label: const Text("Migrate Existing Media"),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
    ),
    onPressed: () async {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(
                child: Text("Migrating photos and videos..."),
              ),
            ],
          ),
        ),
      );

      await PropertyMigration.migrateMedia();

      if (!mounted) return;

      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Migration completed successfully"),
        ),
      );
    },
  ),
),
          ],
        ),
      ),
    );
  }
  

  // 🔹 Reusable dropdown
  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: _boxDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        dropdownColor: const Color(0xFF003845),
        style: const TextStyle(color: Colors.white),
        hint: Text(
          hint,
          style: const TextStyle(color: Colors.white70),
        ),
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
            .toList(),
        onChanged: onChanged,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
      ),
    );
  }

  // 🔹 Common box style
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
    );
  }
  
}
