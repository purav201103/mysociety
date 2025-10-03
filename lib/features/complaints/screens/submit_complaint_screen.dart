// lib/features/complaints/screens/submit_complaint_screen.dart
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mysociety/services/complaint_service.dart';
import 'package:mysociety/services/user_service.dart';

class SubmitComplaintScreen extends StatefulWidget {
  const SubmitComplaintScreen({super.key});

  @override
  State<SubmitComplaintScreen> createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends State<SubmitComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = false;
  File? _imageFile;

  final List<String> _categories = ['Plumbing', 'Electrical', 'Security', 'Housekeeping', 'Other'];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      try {
        final user = FirebaseAuth.instance.currentUser!;
        final userProfile = await UserService().getUserProfile(user.uid);
        final residentName = userProfile?['name'] ?? 'Unknown Resident';

        String complaintId = await ComplaintService().submitComplaint(
          title: _titleController.text,
          description: _descriptionController.text,
          category: _selectedCategory!,
          submittedByUid: user.uid,
          residentName: residentName,
        );

        if (_imageFile != null) {
          String imageUrl = await ComplaintService().uploadComplaintImage(_imageFile!);
          await ComplaintService().updateComplaintWithImageUrl(
            complaintId: complaintId,
            imageUrl: imageUrl,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complaint submitted successfully!')));
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit complaint.')));
        }
      } finally {
        if (mounted) setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit a Complaint')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Text Fields for Complaint Details ---
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Complaint Title', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Detailed Description', border: OutlineInputBorder()),
                maxLines: 6,
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 20),

              // --- UI for Optional Photo Attachment ---
              if (_imageFile != null)
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover),
                      ),
                    ),
                    IconButton(
                      icon: const CircleAvatar(backgroundColor: Colors.black54, child: Icon(Icons.close, color: Colors.white, size: 18)),
                      onPressed: () => setState(() => _imageFile = null),
                    ),
                  ],
                ),
              if (_imageFile == null)
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: const Text('Add a Photo (Optional)'),
                  onPressed: _pickImage,
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16)
                  ),
                ),
              const SizedBox(height: 24),

              // --- Submit Button ---
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), textStyle: const TextStyle(fontSize: 18)),
                child: const Text('Submit Complaint'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}