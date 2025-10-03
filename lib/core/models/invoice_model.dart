// lib/core/models/invoice_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Invoice {
  final String id;
  final String residentUid;
  final String residentName;
  final double amount;
  final Timestamp dueDate;
  final String month;
  final int year;
  final String status;

  Invoice({
    required this.id,
    required this.residentUid,
    required this.residentName,
    required this.amount,
    required this.dueDate,
    required this.month,
    required this.year,
    required this.status,
  });

  factory Invoice.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Invoice(
      id: doc.id,
      residentUid: data['residentUid'] ?? '',
      residentName: data['residentName'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      dueDate: data['dueDate'] ?? Timestamp.now(),
      month: data['month'] ?? '',
      year: data['year'] ?? 0,
      status: data['status'] ?? 'Unknown',
    );
  }
}