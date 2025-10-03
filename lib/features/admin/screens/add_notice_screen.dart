// lib/features/admin/screens/add_notice_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mysociety/services/notice_service.dart';
import 'package:mysociety/services/user_service.dart';

class AddNoticeScreen extends StatefulWidget {
  const AddNoticeScreen({super.key});

  @override
  State<AddNoticeScreen> createState() => _AddNoticeScreenState();
}

class _AddNoticeScreenState extends State<AddNoticeScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final NoticeService _noticeService = NoticeService();
  final UserService _userService = UserService();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _postNotice() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      // Get the current user's name to use as the author
      final user = FirebaseAuth.instance.currentUser;
      final userProfile = await _userService.getUserProfile(user!.uid);
      final authorName = userProfile?['name'] ?? 'Admin';

      await _noticeService.createNotice(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        author: authorName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notice posted successfully!')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post a New Notice')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 8,
                validator: (value) =>
                value!.isEmpty ? 'Please enter the content' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _postNotice,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Post Notice'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}