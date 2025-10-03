// lib/features/profile/screens/profile_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mysociety/features/authentication/services/auth_service.dart';
import 'package:mysociety/features/profile/screens/edit_profile_screen.dart'; // We will create this next
import 'package:mysociety/services/user_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text("Not logged in.")));

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: UserService().getUserProfile(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Could not load profile.'));
          }
          final userData = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Name'),
                  subtitle: Text(userData['name'] ?? 'N/A'),
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: Text(userData['email'] ?? 'N/A'),
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Phone'),
                  subtitle: Text(userData['phone'] ?? 'N/A'),
                ),
                ListTile(
                  leading: const Icon(Icons.badge),
                  title: const Text('Role'),
                  subtitle: Text(userData['role'] ?? 'N/A'),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EditProfileScreen(userData: userData),
                    ));
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Logout', style: TextStyle(color: Colors.red)),
                  onPressed: () => AuthService().signOut(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}