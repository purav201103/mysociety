// lib/services/visitor_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/models/visitor_model.dart';

class VisitorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> preApproveVisitor({
    required String visitorName,
    required String purpose,
    required String residentUid,
    required String residentName,
    required DateTime expectedAt,
  }) async {
    await _firestore.collection('visitors').add({
      'visitorName': visitorName,
      'purpose': purpose,
      'residentUid': residentUid,
      'residentName': residentName,
      'expectedAt': Timestamp.fromDate(expectedAt),
      'status': 'Expected',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMyVisitorsStream({required String residentUid}) {
    return _firestore
        .collection('visitors')
        .where('residentUid', isEqualTo: residentUid)
        .orderBy('expectedAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getGateVisitorsStream() {
    return _firestore
        .collection('visitors')
        .where('status', whereIn: ['Expected', 'Arrived'])
        .orderBy('expectedAt', descending: false)
        .snapshots();
  }

  Future<void> markVisitorArrived({required String visitorId}) async {
    await _firestore.collection('visitors').doc(visitorId).update({
      'status': 'Arrived',
      'entryTimestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markVisitorDeparted({required String visitorId}) async {
    await _firestore.collection('visitors').doc(visitorId).update({
      'status': 'Departed',
      'exitTimestamp': FieldValue.serverTimestamp(),
    });
  }

  // In lib/services/visitor_service.dart

// Get a single visitor by their document ID
  Future<Visitor?> getVisitorById({required String visitorId}) async {
    try {
      final doc = await _firestore.collection('visitors').doc(visitorId).get();
      if (doc.exists) {
        return Visitor.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }
}