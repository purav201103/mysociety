// lib/services/user_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'users';

  // In lib/services/user_service.dart

// Method to get a user's profile by their UID
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collectionName).doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String role,
  }) async {
    try {
      await _firestore.collection(_collectionName).doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // You can add more robust error handling here
      print('Error creating user profile: $e');
    }
  }


  // In lib/services/user_service.dart
  Future<List<QueryDocumentSnapshot>> getAllResidents() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('role', isEqualTo: 'Resident')
          .get();
      return snapshot.docs;
    } catch (e) {
      print(e);
      return [];
    }
  }

  // In lib/services/user_service.dart

  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String phone,
  }) async {
    try {
      // We also need to update the staff collection if the user is staff
      // For simplicity, we'll just update the main 'users' collection for now.
      await _firestore.collection(_collectionName).doc(uid).update({
        'name': name,
        'phone': phone,
      });
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  Future<void> saveUserToken({required String uid, required String token}) async {
    await _firestore.collection(_collectionName).doc(uid).set({
      'fcmToken': token,
    }, SetOptions(merge: true)); // Use set with merge instead of update
  }
}