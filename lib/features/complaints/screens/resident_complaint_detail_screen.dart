// lib/features/complaints/screens/resident_complaint_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:mysociety/core/models/complaint_model.dart';
import 'package:mysociety/features/complaints/widgets/comment_section_widget.dart';

class ResidentComplaintDetailScreen extends StatelessWidget {
  final Complaint complaint;
  const ResidentComplaintDetailScreen({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(complaint.title)),
      body: Column(
        children: [
          // You can add more complaint details here (description, status, etc.)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(complaint.description, style: const TextStyle(fontSize: 16)),
          ),
          const Divider(),
          const Text("Discussion", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(child: CommentSectionWidget(complaintId: complaint.id)),
        ],
      ),
    );
  }
}