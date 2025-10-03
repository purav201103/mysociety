// lib/features/authentication/screens/role_selection_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mysociety/features/authentication/screens/auth_gate.dart';
import 'package:mysociety/features/authentication/widgets/custom_button.dart';
import 'package:mysociety/services/user_service.dart';


class RoleSelectionScreen extends StatefulWidget {
  final User newUser;
  final String name;
  final String phone;

  const RoleSelectionScreen({
    super.key,
    required this.newUser,
    required this.name,
    required this.phone,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;
  final UserService _userService = UserService();
  bool _isLoading = false;

  // In role_selection_screen.dart

  // In lib/features/authentication/screens/role_selection_screen.dart

  void _finishSetup() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Create the user profile in Firestore
    await _userService.createUserProfile(
      uid: widget.newUser.uid,
      name: widget.name,
      email: widget.newUser.email!,
      phone: widget.phone,
      role: _selectedRole!,
    );

    // Navigate straight to the main app
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthGate()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'One Last Step!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please select your role in the society.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 50),
              _buildRoleOption('Resident'),
              const SizedBox(height: 16),
              _buildRoleOption('Staff'),
              const SizedBox(height: 16),
              _buildRoleOption('Committee/Admin'),
              const SizedBox(height: 50),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                label: 'Finish Setup',
                onPressed: _finishSetup,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption(String role) {
    final isSelected = _selectedRole == role;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo.shade100 : Colors.grey.shade200,
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            role,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}