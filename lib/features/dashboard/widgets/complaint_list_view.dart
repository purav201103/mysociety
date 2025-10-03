// lib/features/dashboard/widgets/complaint_list_view.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysociety/core/models/complaint_model.dart';
import 'package:mysociety/services/complaint_service.dart';
import 'package:mysociety/features/complaints/screens/resident_complaint_detail_screen.dart';

class ComplaintListView extends StatelessWidget {
  const ComplaintListView({super.key});

  // Helper function to get a color based on the complaint's status
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
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text("Error: You are not logged in."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: complaintService.getMyComplaintsStream(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong.'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'You have not submitted any complaints yet.\nTap the + button to add one!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final complaints = snapshot.data!.docs
            .map((doc) => Complaint.fromFirestore(doc))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: complaints.length,
          itemBuilder: (context, index) {
            final complaint = complaints[index];
            final formattedDate =
            DateFormat('d MMM, yyyy').format(complaint.submittedAt.toDate());

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              child: ListTile(
                title: Text(complaint.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Category: ${complaint.category} • $formattedDate'),
                trailing: Chip(
                  label: Text(
                    complaint.status,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: _getStatusColor(complaint.status),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ResidentComplaintDetailScreen(complaint: complaint),
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