// lib/core/models/booking_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String amenityId;
  final String amenityName;
  final String residentUid;
  final String residentName;
  final Timestamp startTime;
  final Timestamp endTime;
  final double cost;
  final String status; // Pending, Approved, Rejected

  Booking({
    required this.id,
    required this.amenityId,
    required this.amenityName,
    required this.residentUid,
    required this.residentName,
    required this.startTime,
    required this.endTime,
    required this.cost,
    required this.status,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      amenityId: data['amenityId'] ?? '',
      amenityName: data['amenityName'] ?? 'Unknown Amenity',
      residentUid: data['residentUid'] ?? '',
      residentName: data['residentName'] ?? 'N/A',
      startTime: data['startTime'] ?? Timestamp.now(),
      endTime: data['endTime'] ?? Timestamp.now(),
      cost: (data['cost'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'Unknown',
    );
  }
}