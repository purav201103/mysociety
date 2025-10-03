// lib/features/dashboard/screens/resident_dashboard.dart
import 'package:flutter/material.dart';
import 'package:mysociety/features/amenities/screens/amenity_list_screen.dart';
import 'package:mysociety/features/authentication/services/auth_service.dart';
import 'package:mysociety/features/complaints/screens/my_complaints_screen.dart';
import 'package:mysociety/features/directory/screens/contact_directory_screen.dart';
import 'package:mysociety/features/notices/screens/notices_screen.dart';
import 'package:mysociety/features/profile/screens/profile_screen.dart';
import 'package:mysociety/features/resident/screens/maintenance_screen.dart';
import 'package:mysociety/features/resident/screens/my_vehicles_screen.dart';
import 'package:mysociety/features/resident/screens/my_visitors_screen.dart';

class ResidentDashboard extends StatelessWidget {
  const ResidentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MySociety Dashboard'),
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
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NoticesScreen())),
          ),
          _FeatureCard(
            icon: Icons.report_problem_outlined,
            label: 'Complaints',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyComplaintsScreen())),
          ),
          _FeatureCard(
            icon: Icons.receipt_long_outlined,
            label: 'Maintenance',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MaintenanceScreen())),
          ),
          _FeatureCard(
            icon: Icons.group_outlined,
            label: 'Visitors',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyVisitorsScreen())),
          ),
          _FeatureCard(
            icon: Icons.directions_car_outlined,
            label: 'Vehicles',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyVehiclesScreen())),
          ),
          _FeatureCard(
            icon: Icons.contacts_outlined,
            label: 'Directory',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ContactDirectoryScreen())),
          ),
          _FeatureCard(
            icon: Icons.pool_outlined,
            label: 'Amenity Booking',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AmenityListScreen())),
          ),
          _FeatureCard(
            icon: Icons.logout,
            label: 'Logout',
            onTap: () => AuthService().signOut(),
          ),
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