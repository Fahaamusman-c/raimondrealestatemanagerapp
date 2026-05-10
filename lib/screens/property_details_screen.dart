import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
// ignore: unnecessary_import
import 'package:image_picker/image_picker.dart';
// ignore: unused_import
import 'package:photo_view/photo_view.dart';
// ignore: unused_import
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../models/client_model.dart';
import '../models/profile_model.dart';
import '../models/property_model.dart';
import 'list_property_screen.dart';
// ignore: unused_import
import 'property_listing_screen.dart';
import 'client_details_screen.dart';

class PropertyDetailsScreen extends StatelessWidget {
  final Property property;
  final int index;

  const PropertyDetailsScreen({
    super.key,
    required this.property,
    required this.index,
  });

  bool get isRent => property.category == "Rent (Residential)";
  bool get isSale => property.category == "Sale (Residential)";
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
    String text =
        """
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
    if (property.carpetArea != null)
      details.add("📐 ${property.carpetArea} sqft");
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
      details.add(
        "❤️ ${property.coupleFriendly! ? "Couple OK" : "No Couples"}",
      );
    }

    if (isRent && property.independent != null) {
      details.add("🏠 ${property.independent! ? "Independent" : "Shared"}");
    }

    // LAND DETAILS

    if (isLand) {
      if (property.landArea != null && property.landArea!.trim().isNotEmpty) {
        details.add("🌍 ${property.landArea} ${property.landAreaUnit ?? ""}");
      }

      if (property.landAreaSqft != null &&
          property.landAreaSqft!.trim().isNotEmpty) {
        details.add("📐 ${property.landAreaSqft} sq ft");
      }

      if (property.landType != null && property.landType!.trim().isNotEmpty) {
        details.add("🏷 ${property.landType}");
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
      text +=
          """

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
                          _infoRow(
                            "Land Area",
                            property.safeDash(property.landArea),
                          ),

                          _infoRow(
                            "Unit",
                            property.safeDash(property.landAreaUnit),
                          ),

                          _infoRow(
                            "Area in Sq Ft",
                            property.landAreaSqft != null
                                ? "${property.safeDash(property.landAreaSqft)} sq ft"
                                : "-",
                          ),
                        ],

                        _infoRow(
                          "Land Type",
                          property.safeDash(property.landType),
                        ),

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
