import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/client_model.dart';
import 'client_details_screen.dart';




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

