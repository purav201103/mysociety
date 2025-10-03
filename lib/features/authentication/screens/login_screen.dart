// lib/features/authentication/screens/login_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mysociety/features/authentication/widgets/custom_button.dart';
import 'package:mysociety/features/authentication/widgets/custom_text_field.dart';
import 'package:mysociety/features/authentication/screens/signup_screen.dart';
import 'package:mysociety/features/authentication/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
              const SizedBox(height: 80),
              // Logo and Title
              Icon(Icons.apartment, size: 80, color: Theme.of(context).primaryColor),
              const SizedBox(height: 20),
              const Text(
                'Welcome Back!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sign in to your MySociety account',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 50),

              // Email/Phone Field
              CustomTextField(
                controller: _emailController,
                hintText: 'Email Address',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),

              // Password Field
              CustomTextField(
                controller: _passwordController,
                hintText: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 30),

              // Login Button
              CustomButton(
                label: 'Login',
                onPressed: () async {
                  User? user = await _authService.signInWithEmailAndPassword(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                    context, // Pass the context for error messages
                  );
                  if (user != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login Successful!')),
                    );
                    // TODO: Navigate to the correct dashboard based on user role
                  }
                  // If user is null, the error is handled by the service
                },
              ),
              const SizedBox(height: 20),

              // Sign Up Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      // Navigate to the Signup Screen
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      );
                    },
                    child: const Text('Sign Up'),
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