// lib/features/resident/screens/my_visitors_screen.dart
import 'package:flutter/material.dart';
import 'package:mysociety/features/resident/screens/pre_approve_visitor_screen.dart';
import 'package:mysociety/features/resident/widgets/resident_visitor_list_view.dart';

class MyVisitorsScreen extends StatelessWidget {
  const MyVisitorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Visitors'),
      ),
      body: const ResidentVisitorListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const PreApproveVisitorScreen(),
          ));
        },
        tooltip: 'Pre-Approve Visitor',
        child: const Icon(Icons.person_add),
      ),
    );
  }
}