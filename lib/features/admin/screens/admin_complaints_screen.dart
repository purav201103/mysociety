// lib/features/admin/screens/admin_complaints_screen.dart
import 'package:flutter/material.dart';
import 'package:mysociety/features/admin/widgets/admin_complaint_list_view.dart';

class AdminComplaintsScreen extends StatelessWidget {
  const AdminComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Complaints')),
      body: const AdminComplaintListView(),
    );
  }
}