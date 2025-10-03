// lib/features/profile/screens/my_account_screen.dart
import 'package:flutter/material.dart';
import 'package:mysociety/features/authentication/services/auth_service.dart';
import 'package:mysociety/features/directory/screens/contact_directory_screen.dart';
import 'package:mysociety/features/profile/screens/profile_screen.dart';
import 'package:mysociety/features/resident/screens/my_vehicles_screen.dart';
import 'package:mysociety/features/resident/screens/my_visitors_screen.dart'; // Import the new screen

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('My Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.directions_car_outlined),
            title: const Text('My Vehicles'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyVehiclesScreen()));
            },
          ),
          const Divider(),
          // This ListTile is now updated
          ListTile(
            leading: const Icon(Icons.group_outlined),
            title: const Text('My Visitors'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyVisitorsScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.contacts_outlined),
            title: const Text('Contact Directory'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ContactDirectoryScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => AuthService().signOut(),
          ),
        ],
      ),
    );
  }
}