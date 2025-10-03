// lib/features/admin/screens/admin_booking_management_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysociety/services/amenity_service.dart';

class AdminBookingManagementScreen extends StatelessWidget {
  const AdminBookingManagementScreen({super.key});

  // Helper to get a color based on status
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
    final AmenityService amenityService = AmenityService();
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Bookings')),
      body: StreamBuilder<QuerySnapshot>(
        stream: amenityService.getBookingRequestsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No booking requests found.'));
          }
          final bookings = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final data = booking.data() as Map<String, dynamic>;
              final status = data['status'] ?? 'Unknown';

              // --- START OF FIX ---
              // Safely handle the bookingDate which might be null in old documents
              final Timestamp? bookingTimestamp = data['bookingDate']; // Fixed: Used to be startTime
              final String dateText;
              if (bookingTimestamp != null) {
                dateText = DateFormat('d MMMM, yyyy').format(bookingTimestamp.toDate());
              } else {
                // Also check for startTime for backward compatibility with flexible bookings
                final Timestamp? startTimestamp = data['startTime'];
                if (startTimestamp != null) {
                  dateText = DateFormat('d MMMM, yyyy').format(startTimestamp.toDate());
                } else {
                  dateText = 'Date Not Available';
                }
              }
              // --- END OF FIX ---

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              data['amenityName'] ?? 'Unknown Amenity',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Chip(
                            label: Text(status, style: const TextStyle(color: Colors.white)),
                            backgroundColor: _getStatusColor(status),
                          ),
                        ],
                      ),
                      const Divider(),
                      Text('Resident: ${data['residentName'] ?? 'N/A'}'),
                      Text('Date: $dateText'), // Use the safe dateText variable
                      const SizedBox(height: 10),
                      if (status == 'Pending')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              child: const Text('Reject', style: TextStyle(color: Colors.red)),
                              onPressed: () => amenityService.updateBookingStatus(bookingId: booking.id, newStatus: 'Rejected'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              child: const Text('Approve'),
                              onPressed: () => amenityService.updateBookingStatus(bookingId: booking.id, newStatus: 'Approved'),
                            ),
                          ],
                        ),
                    ],
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