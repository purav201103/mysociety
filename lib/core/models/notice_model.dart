// lib/core/models/notice_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Notice {
  final String id;
  final String title;
  final String content;
  final String author;
  final Timestamp createdAt;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
  });

  // A factory constructor to create a Notice from a Firestore document
  factory Notice.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Notice(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      author: data['author'] ?? 'Admin',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}