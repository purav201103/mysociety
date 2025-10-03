// lib/features/resident/widgets/resident_visitor_list_view.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysociety/core/models/visitor_model.dart';
import 'package:mysociety/services/visitor_service.dart';
import 'package:mysociety/features/resident/screens/visitor_qr_code_screen.dart';

class ResidentVisitorListView extends StatelessWidget {
  const ResidentVisitorListView({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Expected':
        return Colors.blue.shade600;
      case 'Arrived':
        return Colors.green.shade600;
      case 'Departed':
        return Colors.grey.shade600;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Center(child: Text("Not logged in."));

    return StreamBuilder<QuerySnapshot>(
      stream: VisitorService().getMyVisitorsStream(residentUid: uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No visitors pre-approved yet.'));
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
                leading: const Icon(Icons.person, size: 40),
                title: Text(visitor.visitorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Purpose: ${visitor.purpose}\nExpected: ${DateFormat('d MMM, h:mm a').format(visitor.expectedAt.toDate())}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(visitor.status, style: const TextStyle(color: Colors.white)),
                      backgroundColor: _getStatusColor(visitor.status),
                    ),
                    // Add this IconButton
                    IconButton(
                      icon: const Icon(Icons.qr_code_2),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => VisitorQrCodeScreen(visitor: visitor),
                        ));
                      },
                    ),
                  ],
                ),
                isThreeLine: true,

              ),
            );
          },
        );
      },
    );
  }
}