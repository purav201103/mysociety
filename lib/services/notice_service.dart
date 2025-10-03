// lib/services/notice_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'notices';

  // Get a stream of notices, ordered by the newest first
  Stream<QuerySnapshot> getNoticesStream() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // In lib/services/notice_service.dart

  Future<void> createNotice({
    required String title,
    required String content,
    required String author,
  }) async {
    try {
      await _firestore.collection(_collectionName).add({
        'title': title,
        'content': content,
        'author': author,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Handle errors, e.g., show a dialog or log the error
      print('Error creating notice: $e');
    }
  }
}