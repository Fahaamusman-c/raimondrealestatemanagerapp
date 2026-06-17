import 'package:flutter/material.dart';
import 'property_listing_screen.dart';

class CommercialCategoryScreen extends StatelessWidget {
  const CommercialCategoryScreen({super.key});

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
            colors: [
              Color(0xFF002b36),
              Color(0xFF065f73),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // TOP BAR
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),

                  const Text(
                    "Commercial",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              _buildButton(
  context,
  "Sale",
  Icons.sell,
  () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PropertyListScreen(
          filterCategory: "Commercial",
          filterType: "Sale",
        ),
      ),
    );
  },
),

            _buildButton(
  context,
  "Rent",
  Icons.home_work,
  () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PropertyListScreen(
          filterCategory: "Commercial",
          filterType: "Rent",
        ),
      ),
    );
  },
),
_buildButton(
  context,
  "Lease",
  Icons.business_center,
  () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PropertyListScreen(
          filterCategory: "Commercial",
          filterType: "Lease",
        ),
      ),
    );
  },
),

              const Spacer(),

              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  "© Raimond Real Estate 2025",
                  style: TextStyle(
                    color: Color.fromARGB(246, 156, 146, 146),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 10,
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.15),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}