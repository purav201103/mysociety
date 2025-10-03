// lib/services/invoice_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mysociety/services/user_service.dart';

import '../core/models/invoice_model.dart';

class InvoiceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();
  final String _collectionName = 'invoices';

  // Generates an invoice for every resident
  Future<void> generateInvoicesForAllResidents({
    required double amount,
    required DateTime dueDate,
    required String month,
    required int year,
  }) async {
    final residents = await _userService.getAllResidents();
    final batch = _firestore.batch();

    for (var residentDoc in residents) {
      final residentData = residentDoc.data() as Map<String, dynamic>;
      final newInvoiceRef = _firestore.collection(_collectionName).doc();

      batch.set(newInvoiceRef, {
        'residentUid': residentData['uid'],
        'residentName': residentData['name'],
        'amount': amount,
        'dueDate': Timestamp.fromDate(dueDate),
        'month': month,
        'year': year,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  // Gets a stream of all invoices for the admin view
  Stream<QuerySnapshot> getAllInvoicesStream() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // lib/services/invoice_service.dart

// Gets a stream of invoices for a specific resident
  Stream<QuerySnapshot> getMyInvoicesStream({required String residentUid}) {
    return _firestore
        .collection(_collectionName)
        .where('residentUid', isEqualTo: residentUid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

// Marks a specific invoice as paid
  Future<void> markInvoiceAsPaid({required String invoiceId}) async {
    try {
      await _firestore.collection(_collectionName).doc(invoiceId).update({
        'status': 'Paid',
        'paidAt': FieldValue.serverTimestamp(), // Optional: track payment date
      });
    } catch (e) {
      rethrow;
    }
  }

  // Gets a list of invoices for a specific resident (one-time fetch)
  Future<List<Invoice>> getMyInvoicesAsList({required String residentUid}) async {
    final snapshot = await _firestore
        .collection(_collectionName)
        .where('residentUid', isEqualTo: residentUid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Invoice.fromFirestore(doc)).toList();
  }
}