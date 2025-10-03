// lib/features/admin/screens/admin_amenity_list_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mysociety/core/models/amenity_model.dart';
import 'package:mysociety/features/admin/screens/add_edit_amenity_screen.dart';
import 'package:mysociety/services/amenity_service.dart';

class AdminAmenityListScreen extends StatelessWidget {
  const AdminAmenityListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AmenityService amenityService = AmenityService();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Amenities')),
      body: StreamBuilder<QuerySnapshot>(
        stream: amenityService.getAmenitiesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final amenities = snapshot.data!.docs.map((doc) => Amenity.fromFirestore(doc)).toList();

          return ListView.builder(
            itemCount: amenities.length,
            itemBuilder: (context, index) {
              final amenity = amenities[index];
              return ListTile(
                title: Text(amenity.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AddEditAmenityScreen(amenity: amenity),
                      )),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => amenityService.deleteAmenity(id: amenity.id), // Add confirmation dialog for safety
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const AddEditAmenityScreen(),
        )),
        child: const Icon(Icons.add),
      ),
    );
  }
}