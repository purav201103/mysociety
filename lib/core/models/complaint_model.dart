// lib/core/models/complaint_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status;
  final String submittedByUid; // User's UID
  final String residentName;
  final Timestamp submittedAt;
  final String? imageUrl;

  Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.submittedByUid,
    required this.residentName,
    required this.submittedAt,
    this.imageUrl,
  });

  // lib/core/models/complaint_model.dart

  factory Complaint.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Complaint(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      status: data['status'] ?? 'Unknown',
      submittedByUid: data['submittedByUid'] ?? '',
      residentName: data['residentName'] ?? '',
      submittedAt: data['submittedAt'] ?? Timestamp.now(),
      imageUrl: data['imageUrl'], // Can be null
    );
  }
}