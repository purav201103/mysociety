// lib/features/authentication/screens/auth_gate.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mysociety/features/authentication/screens/login_screen.dart';
import 'package:mysociety/features/dashboard/screens/dashboard_dispatcher.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the connection is still waiting, show a loading screen
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If a user is logged in (snapshot has data), show the home screen
        if (snapshot.hasData) {
          return const DashboardDispatcher();
        }

        // If no user is logged in, show the login screen
        return const LoginScreen();
      },
    );
  }
}