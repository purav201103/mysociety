// lib/features/amenities/screens/my_bookings_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysociety/services/amenity_service.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text("Not logged in.")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: StreamBuilder<QuerySnapshot>(
        stream: AmenityService().getMyBookingsStream(residentUid: uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('You have not made any bookings yet.'));
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final data = bookings[index].data() as Map<String, dynamic>;

              // --- START OF FIX ---
              // Safely handle potentially null timestamps
              final Timestamp? startTimeStamp = data['startTime'];
              final Timestamp? endTimeStamp = data['endTime'];

              String dateText;
              String timeText;

              if (startTimeStamp != null) {
                final startTime = startTimeStamp.toDate();
                dateText = DateFormat('d MMM, yyyy').format(startTime);

                if (endTimeStamp != null) {
                  final endTime = endTimeStamp.toDate();
                  timeText = '${DateFormat('h:mm a').format(startTime)} - ${DateFormat('h:mm a').format(endTime)}';
                } else {
                  timeText = DateFormat('h:mm a').format(startTime);
                }
              } else {
                // Fallback if data is old/missing
                dateText = 'Date not specified';
                timeText = 'Time not specified';
              }
              // --- END OF FIX ---

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                child: ListTile(
                  title: Text(data['amenityName'] ?? 'Unknown Amenity', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$dateText\n$timeText'),
                  trailing: Chip(
                    label: Text(data['status'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
                    backgroundColor: _getStatusColor(data['status'] ?? 'Unknown'),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}