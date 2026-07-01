import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/property_model.dart';
import '../main.dart';
import 'property_details_screen.dart';

import 'list_property_screen.dart';

class PropertyListScreen extends StatefulWidget {
  final String filterCategory;
  final String? filterType;

  const PropertyListScreen({
    super.key,
    required this.filterCategory,
    this.filterType,
  });

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

      if (widget.filterType != null && p.commercialType != widget.filterType) {
        continue;
      }

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
