// lib/features/amenities/screens/amenity_list_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mysociety/core/models/amenity_model.dart';
import 'package:mysociety/features/amenities/screens/booking_screen.dart';
import 'package:mysociety/services/amenity_service.dart';
import 'package:mysociety/features/amenities/screens/my_bookings_screen.dart';

class AmenityListScreen extends StatelessWidget {
  const AmenityListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book an Amenity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_outlined),
            tooltip: 'My Bookings',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const MyBookingsScreen(),
              ));
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: AmenityService().getAmenitiesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No amenities available.'));
          }

          final amenities = snapshot.data!.docs.map((doc) => Amenity.fromFirestore(doc)).toList();

          return ListView.builder(
            itemCount: amenities.length,
            itemBuilder: (context, index) {
              final amenity = amenities[index];
              return Card(
                margin: const EdgeInsets.all(12.0),
                elevation: 5,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => BookingScreen(amenity: amenity),
                    ));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 150,
                        child: Image.network(
                          amenity.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 50),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(amenity.name, style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 8),
                            Text(amenity.description),
                            const SizedBox(height: 8),
                            Text('Cost: ₹${amenity.bookingCost.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}