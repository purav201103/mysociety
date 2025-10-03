// lib/features/dashboard/screens/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:mysociety/features/admin/screens/admin_booking_management_screen.dart';
import 'package:mysociety/features/admin/screens/admin_complaints_screen.dart';
import 'package:mysociety/features/admin/screens/admin_maintenance_screen.dart';
import 'package:mysociety/features/admin/screens/admin_notices_screen.dart';
import 'package:mysociety/features/admin/screens/parking_management_screen.dart';
import 'package:mysociety/features/authentication/services/auth_service.dart';
import 'package:mysociety/features/profile/screens/profile_screen.dart';
import 'package:mysociety/features/admin/screens/admin_amenity_list_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'My Profile',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileScreen())),
            icon: const Icon(Icons.account_circle),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16.0),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: <Widget>[
          _FeatureCard(
              icon: Icons.campaign_outlined,
              label: 'Notices',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AdminNoticesScreen()))),
          _FeatureCard(
              icon: Icons.list_alt_outlined,
              label: 'Complaints',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AdminComplaintsScreen()))),
          _FeatureCard(
              icon: Icons.receipt_long_outlined,
              label: 'Invoices',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AdminMaintenanceScreen()))),
          _FeatureCard(
              icon: Icons.directions_car_outlined,
              label: 'Parking',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ParkingManagementScreen()))),
          _FeatureCard(
              icon: Icons.pool_outlined,
              label: 'Approve Bookings',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AdminBookingManagementScreen()))),
          _FeatureCard(
              icon: Icons.edit_location_alt_outlined, // New Card
              label: 'Manage Amenities',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AdminAmenityListScreen()))),
          _FeatureCard(
              icon: Icons.logout,
              label: 'Logout',
              onTap: () => AuthService().signOut()),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FeatureCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}