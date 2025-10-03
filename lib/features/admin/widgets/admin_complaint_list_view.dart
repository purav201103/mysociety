// lib/features/admin/widgets/admin_complaint_list_view.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mysociety/core/models/complaint_model.dart';
import 'package:mysociety/features/admin/screens/admin_complaint_detail_screen.dart'; // We will create this
import 'package:mysociety/services/complaint_service.dart';

class AdminComplaintListView extends StatelessWidget {
  const AdminComplaintListView({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return Colors.blue.shade600;
      case 'In Progress':
        return Colors.orange.shade700;
      case 'Resolved':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ComplaintService complaintService = ComplaintService();
    return StreamBuilder<QuerySnapshot>(
      stream: complaintService.getAllComplaintsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No complaints have been submitted yet.'));
        }
        final complaints = snapshot.data!.docs.map((doc) => Complaint.fromFirestore(doc)).toList();
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: complaints.length,
          itemBuilder: (context, index) {
            final complaint = complaints[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              child: ListTile(
                title: Text(complaint.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('By: ${complaint.residentName}'),
                trailing: Chip(
                  label: Text(complaint.status, style: const TextStyle(color: Colors.white)),
                  backgroundColor: _getStatusColor(complaint.status),
                ),
                onTap: () {
                  // Navigate to a detail screen to update status
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AdminComplaintDetailScreen(complaint: complaint),
                  ));
                },
              ),
            );
          },
        );
      },
    );
  }
}