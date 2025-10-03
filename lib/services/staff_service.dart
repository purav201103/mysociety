// lib/services/staff_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot>> getStaffList() async {
    try {
      final snapshot = await _firestore.collection('staff').get();
      return snapshot.docs;
    } catch (e) {
      print(e);
      return [];
    }
  }
}