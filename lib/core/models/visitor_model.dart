// lib/core/models/visitor_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Visitor {
  final String id;
  final String visitorName;
  final String residentName;
  final String purpose;
  final String residentUid;
  final Timestamp expectedAt;
  final String status;

  Visitor({
    required this.id,
    required this.visitorName,
    required this.residentName,
    required this.purpose,
    required this.residentUid,
    required this.expectedAt,
    required this.status,
  });

  factory Visitor.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Visitor(
      id: doc.id,
      visitorName: data['visitorName'] ?? '',
      residentName: data['residentName'] ?? 'N/A',
      purpose: data['purpose'] ?? '',
      residentUid: data['residentUid'] ?? '',
      expectedAt: data['expectedAt'] ?? Timestamp.now(),
      status: data['status'] ?? 'Unknown',
    );
  }
}