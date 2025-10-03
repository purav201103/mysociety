// lib/services/complaint_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ComplaintService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'complaints';

  // Creates a complaint and returns its ID
  Future<String> submitComplaint({
    required String title,
    required String description,
    required String category,
    required String submittedByUid,
    required String residentName,
  }) async {
    try {
      final docRef = await _firestore.collection(_collectionName).add({
        'title': title,
        'description': description,
        'category': category,
        'submittedByUid': submittedByUid,
        'residentName': residentName,
        'status': 'Open',
        'submittedAt': FieldValue.serverTimestamp(),
        'imageUrl': null,
      });
      return docRef.id;
    } catch (e) {
      print('Error submitting complaint: $e');
      rethrow;
    }
  }

  // Gets complaints for a specific user
  Stream<QuerySnapshot> getMyComplaintsStream(String uid) {
    return _firestore
        .collection(_collectionName)
        .where('submittedByUid', isEqualTo: uid)
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  // Gets all complaints for an admin
  Stream<QuerySnapshot> getAllComplaintsStream() {
    return _firestore
        .collection(_collectionName)
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  // Gets complaints assigned to a staff member
  Stream<QuerySnapshot> getAssignedComplaintsStream(String staffUid) {
    return _firestore
        .collection(_collectionName)
        .where('assignedToUid', isEqualTo: staffUid)
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  // Updates a complaint's status
  Future<void> updateComplaintStatus({
    required String complaintId,
    required String newStatus,
  }) async {
    try {
      await _firestore.collection(_collectionName).doc(complaintId).update({
        'status': newStatus,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Assigns a complaint to a staff member
  Future<void> assignComplaint({
    required String complaintId,
    required String staffUid,
    required String staffName,
  }) async {
    try {
      await _firestore.collection(_collectionName).doc(complaintId).update({
        'assignedToUid': staffUid,
        'assignedToName': staffName,
        'status': 'In Progress',
      });
    } catch (e) {
      rethrow;
    }
  }

  // --- METHODS FOR IMAGE UPLOAD ---

  // Method to upload an image and get its URL
  Future<String> uploadComplaintImage(File imageFile) async {
    try {
      String fileName = 'complaints/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  // Method to update the complaint with the image URL
  Future<void> updateComplaintWithImageUrl({
    required String complaintId,
    required String imageUrl,
  }) async {
    await _firestore.collection(_collectionName).doc(complaintId).update({
      'imageUrl': imageUrl,
    });
  }
  
  Future<void> addCommentToComplaint({
    required String complaintId,
    required String commentText,
    required String authorName,
    required String authorUid,
  }) async {
    await _firestore
        .collection(_collectionName)
        .doc(complaintId)
        .collection('comments') // Access the sub-collection
        .add({
      'text': commentText,
      'authorName': authorName,
      'authorUid': authorUid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

// Get a real-time stream of comments for a complaint
  Stream<QuerySnapshot> getCommentsStream({required String complaintId}) {
    return _firestore
        .collection(_collectionName)
        .doc(complaintId)
        .collection('comments')
        .orderBy('timestamp', descending: false) // Show oldest first
        .snapshots();
  }
}