import 'package:flutter/material.dart';

import '../main.dart';
import 'property_listing_screen.dart';

import 'residential_category_screen.dart';
import 'commercial_category_screen.dart';
import 'villas_buildings_category_screen.dart';


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

             _categoryNavigationButton(
  context,
  "Residential",
  const ResidentialCategoryScreen(),
),

_categoryNavigationButton(
  context,
  "Commercial",
  const CommercialCategoryScreen(),
),

_categoryNavigationButton(
  context,
  "Villas & Buildings",
  const VillasBuildingsCategoryScreen(),
),

_categoryButton(
  context,
  "Land / Plot Properties",
  "Land",
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
  Widget _categoryNavigationButton(
  BuildContext context,
  String label,
  Widget screen,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      vertical: 12,
      horizontal: 30,
    ),
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
            builder: (_) => screen,
          ),
        );
      },
      child: Text(
        label,
        style: const TextStyle(fontSize: 18),
      ),
    ),
  );
}
}