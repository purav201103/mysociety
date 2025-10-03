// lib/features/staff/widgets/staff_complaint_list_view.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mysociety/core/models/complaint_model.dart';
import 'package:mysociety/features/staff/screens/staff_complaint_detail_screen.dart';
import 'package:mysociety/services/complaint_service.dart';

class StaffComplaintListView extends StatefulWidget {
  const StaffComplaintListView({super.key});

  @override
  State<StaffComplaintListView> createState() => _StaffComplaintListViewState();
}

class _StaffComplaintListViewState extends State<StaffComplaintListView> {
  late Stream<QuerySnapshot> _complaintsStream;

  @override
  void initState() {
    super.initState();
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _complaintsStream = ComplaintService().getAssignedComplaintsStream(uid);
    } else {
      _complaintsStream = const Stream.empty();
    }
  }

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
    return StreamBuilder<QuerySnapshot>(
      stream: _complaintsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong.'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('You have no complaints assigned to you.'));
        }
        final complaints = snapshot.data!.docs.map((doc) => Complaint.fromFirestore(doc)).toList();
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: complaints.length,
          itemBuilder: (context, index) {
            final complaint = complaints[index];
            return Card(
              child: ListTile(
                title: Text(complaint.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('From: ${complaint.residentName}'),
                trailing: Chip(
                  label: Text(complaint.status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  backgroundColor: _getStatusColor(complaint.status),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => StaffComplaintDetailScreen(complaint: complaint),
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