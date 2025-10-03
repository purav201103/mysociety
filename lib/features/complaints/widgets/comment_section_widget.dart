// lib/features/complaints/widgets/comment_section_widget.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mysociety/services/complaint_service.dart';
import 'package:mysociety/services/user_service.dart';

class CommentSectionWidget extends StatefulWidget {
  final String complaintId;
  const CommentSectionWidget({super.key, required this.complaintId});

  @override
  State<CommentSectionWidget> createState() => _CommentSectionWidgetState();
}

class _CommentSectionWidgetState extends State<CommentSectionWidget> {
  final _commentController = TextEditingController();
  final ComplaintService _complaintService = ComplaintService();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _postComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser!;
    final userProfile = await UserService().getUserProfile(user.uid);
    final authorName = userProfile?['name'] ?? 'Unknown User';

    await _complaintService.addCommentToComplaint(
      complaintId: widget.complaintId,
      commentText: _commentController.text.trim(),
      authorName: authorName,
      authorUid: user.uid,
    );
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _complaintService.getCommentsStream(complaintId: widget.complaintId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final comments = snapshot.data!.docs;
              return ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final commentData = comments[index].data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(commentData['authorName']),
                    subtitle: Text(commentData['text']),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(hintText: 'Add a comment...'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _postComment,
              ),
            ],
          ),
        ),
      ],
    );
  }
}