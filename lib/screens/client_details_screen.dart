import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../models/client_model.dart';
import '../models/property_model.dart';

import 'property_details_screen.dart';
import 'register_client_screen.dart';

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
