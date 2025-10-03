// lib/features/dashboard/screens/dashboard_dispatcher.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mysociety/features/dashboard/screens/admin_dashboard.dart';
import 'package:mysociety/features/dashboard/screens/resident_dashboard.dart';
import 'package:mysociety/features/dashboard/screens/staff_dashboard.dart';
import 'package:mysociety/services/notification_service.dart';
import 'package:mysociety/services/user_service.dart';

class DashboardDispatcher extends StatefulWidget {
  const DashboardDispatcher({super.key});

  @override
  State<DashboardDispatcher> createState() => _DashboardDispatcherState();
}

class _DashboardDispatcherState extends State<DashboardDispatcher> {
  final UserService _userService = UserService();
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    // Initialize notifications for the logged-in user
    if (uid != null) {
      NotificationService().initNotifications(uid!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      // This is a fallback, AuthGate should prevent this state.
      return const Scaffold(body: Center(child: Text('Error: User not found.')));
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: _userService.getUserProfile(uid!),
      builder: (context, snapshot) {
        // While waiting for the user's role, show a loading screen
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If there's an error or no data, show an error message
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('Error: Could not load user data.')),
          );
        }

        // If we have data, get the user's role
        final userRole = snapshot.data!['role'];

        // Show the correct dashboard based on the role
        switch (userRole) {
          case 'Resident':
            return const ResidentDashboard();
          case 'Staff':
            return const StaffDashboard();
          case 'Committee/Admin':
            return const AdminDashboard();
          default:
          // Fallback for unknown or missing roles
            return const Scaffold(
              body: Center(child: Text('Error: Unknown user role.')),
            );
        }
      },
    );
  }
}