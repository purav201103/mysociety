// lib/features/admin/screens/admin_booking_management_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mysociety/core/models/booking_model.dart';
import 'package:mysociety/services/amenity_service.dart';

class AdminBookingManagementScreen extends StatelessWidget {
  const AdminBookingManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Using DefaultTabController to manage the tabs state
    return DefaultTabController(
      length: 3, // For Pending, Approved, Rejected
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Bookings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Each child is a dedicated list view for a specific status
            _BookingList(status: 'Pending'),
            _BookingList(status: 'Approved'),
            _BookingList(status: 'Rejected'),
          ],
        ),
      ),
    );
  }
}

// A reusable widget to display a list of bookings based on status
class _BookingList extends StatelessWidget {
  final String status;
  const _BookingList({required this.status});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: AmenityService().getBookingsByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No $status bookings found.'));
        }

        final bookings = snapshot.data!.docs
            .map((doc) => Booking.fromFirestore(doc))
            .toList();

        return ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return _BookingCard(booking: booking);
          },
        );
      },
    );
  }
}

// A detailed card widget to display booking info and admin actions
class _BookingCard extends StatelessWidget {
  final Booking booking;
  const _BookingCard({required this.booking});

  Future<void> _updateBookingStatus(BuildContext context, String newStatus) async {
    try {
      await AmenityService().updateBookingStatus(booking.id, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking ${newStatus.toLowerCase()} successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('d MMM yyyy').format(booking.startTime.toDate());
    final time =
        '${DateFormat('h:mm a').format(booking.startTime.toDate())} - ${DateFormat('h:mm a').format(booking.endTime.toDate())}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(booking.amenityName, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Booked by: ${booking.residentName}', style: Theme.of(context).textTheme.bodyLarge),
            const Divider(height: 16),
            _InfoRow(icon: Icons.calendar_today, text: date),
            _InfoRow(icon: Icons.access_time, text: time),
            if (booking.status == 'Pending') ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => _updateBookingStatus(context, 'Approved'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Approve'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => _updateBookingStatus(context, 'Rejected'),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                    child: const Text('Reject', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// Helper widget for consistent info rows
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}