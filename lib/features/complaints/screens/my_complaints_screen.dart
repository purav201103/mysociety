// lib/features/complaints/screens/my_complaints_screen.dart
import 'package:flutter/material.dart';
import 'package:mysociety/features/complaints/screens/submit_complaint_screen.dart';
import 'package:mysociety/features/dashboard/widgets/complaint_list_view.dart';

class MyComplaintsScreen extends StatelessWidget {
  const MyComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Complaints')),
      body: const ComplaintListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SubmitComplaintScreen())),
        tooltip: 'New Complaint',
        child: const Icon(Icons.add),
      ),
    );
  }
}