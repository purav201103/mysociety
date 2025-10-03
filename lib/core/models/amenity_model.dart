// lib/core/models/amenity_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Amenity {
  final String id;
  final String name;
  final String description;
  final double bookingCost;
  final String imageUrl;

  Amenity({
    required this.id,
    required this.name,
    required this.description,
    required this.bookingCost,
    required this.imageUrl,
  });

  factory Amenity.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Amenity(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      bookingCost: (data['bookingCost'] ?? 0.0).toDouble(),
      imageUrl: data['image_url'] ?? '',
    );
  }
}