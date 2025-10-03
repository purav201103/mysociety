// lib/features/amenities/screens/my_bookings_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysociety/core/models/booking_model.dart';
import 'package:mysociety/services/amenity_service.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green.shade700;
      case 'Rejected':
        return Colors.red.shade700;
      case 'Pending':
        return Colors.orange.shade600;
      default:
        return Colors.grey;
    }
  }

  // Method to handle the cancellation
  void _cancelBooking(BuildContext context, Booking booking) async {
    // Show a confirmation dialog
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Cancellation'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AmenityService().cancelBooking(booking.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Booking successfully cancelled.'),
              backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to cancel booking: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
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
            return const Center(
                child: Text('You have not made any bookings yet.'));
          }

          final bookings = snapshot.data!.docs
              .map((doc) => Booking.fromFirestore(doc))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final startTime = booking.startTime.toDate();
              final endTime = booking.endTime.toDate();

              final dateText = DateFormat('EEEE, d MMMM yyyy').format(startTime);
              final timeText =
                  '${DateFormat('h:mm a').format(startTime)} - ${DateFormat('h:mm a').format(endTime)}';

              // Only show cancel button if the booking is 'Pending'
              final bool canCancel = booking.status == 'Pending';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    isThreeLine: true,
                    title: Text(booking.amenityName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$dateText\n$timeText'),
                        const SizedBox(height: 8),
                        if (canCancel)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _cancelBooking(context, booking),
                              child: const Text('Cancel Booking', style: TextStyle(color: Colors.red)),
                            ),
                          )
                      ],
                    ),
                    trailing: Chip(
                      label: Text(booking.status,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                      backgroundColor: _getStatusColor(booking.status),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}