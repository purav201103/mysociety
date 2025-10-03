// lib/features/authentication/screens/signup_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mysociety/features/authentication/widgets/custom_button.dart';
import 'package:mysociety/features/authentication/widgets/custom_text_field.dart';
import 'package:mysociety/features/authentication/services/auth_service.dart';
import 'package:mysociety/features/authentication/screens/role_selection_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              // Title
              const Text(
                'Create Your Account',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Let\'s get you started!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // Input Fields
              CustomTextField(controller: _nameController, hintText: 'Full Name', icon: Icons.person_outline),
              const SizedBox(height: 20),
              CustomTextField(controller: _emailController, hintText: 'Email Address', icon: Icons.email_outlined),
              const SizedBox(height: 20),
              CustomTextField(controller: _phoneController, hintText: 'Phone Number', icon: Icons.phone_outlined),
              const SizedBox(height: 20),
              CustomTextField(controller: _passwordController, hintText: 'Password', icon: Icons.lock_outline, isPassword: true),
              const SizedBox(height: 20),
              CustomTextField(controller: _confirmPasswordController, hintText: 'Confirm Password', icon: Icons.lock_outline, isPassword: true),
              const SizedBox(height: 30),

              // Signup Button
              CustomButton(
                label: 'Sign Up',
                // In signup_screen.dart
                // In signup_screen.dart

                onPressed: () async {
                  // Basic validation
                  if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Passwords do not match.')),
                    );
                    return;
                  }
                  if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in all fields.')),
                    );
                    return;
                  }

                  // First, create the user in FirebaseAuth
                  User? user = await _authService.signUpWithEmailAndPassword(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                    context,
                  );

                  // If user creation is successful, navigate to role selection
                  if (user != null && mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => RoleSelectionScreen(
                          newUser: user,
                          name: _nameController.text.trim(),
                          phone: _phoneController.text.trim(),
                        ),
                      ),
                    );
                  }
                  // If user is null, the error snackbar is already shown by the auth service
                },
              ),
              const SizedBox(height: 20),

              // Login Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      // Navigate back to the Login Screen
                      Navigator.of(context).pop();
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}