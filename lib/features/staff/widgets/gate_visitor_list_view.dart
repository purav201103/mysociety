// lib/features/staff/widgets/gate_visitor_list_view.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysociety/core/models/visitor_model.dart';
import 'package:mysociety/features/staff/screens/gate_visitor_detail_screen.dart';
import 'package:mysociety/services/visitor_service.dart';

class GateVisitorListView extends StatelessWidget {
  const GateVisitorListView({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Expected': return Colors.blue.shade600;
      case 'Arrived': return Colors.green.shade600;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: VisitorService().getGateVisitorsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No expected or current visitors.'));
        }

        final visitors = snapshot.data!.docs.map((doc) => Visitor.fromFirestore(doc)).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: visitors.length,
          itemBuilder: (context, index) {
            final visitor = visitors[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              child: ListTile(
                title: Text(visitor.visitorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Visiting: ${visitor.residentName}'),
                trailing: Chip(
                  label: Text(visitor.status, style: const TextStyle(color: Colors.white)),
                  backgroundColor: _getStatusColor(visitor.status),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => GateVisitorDetailScreen(visitor: visitor),
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