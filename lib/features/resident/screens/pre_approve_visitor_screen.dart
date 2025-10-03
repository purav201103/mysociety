// lib/features/resident/screens/pre_approve_visitor_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysociety/services/user_service.dart';
import 'package:mysociety/services/visitor_service.dart';

class PreApproveVisitorScreen extends StatefulWidget {
  const PreApproveVisitorScreen({super.key});

  @override
  State<PreApproveVisitorScreen> createState() => _PreApproveVisitorScreenState();
}

class _PreApproveVisitorScreenState extends State<PreApproveVisitorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _purposeController = TextEditingController();
  DateTime? _selectedDateTime;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _selectedDateTime != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser!;
        final userProfile = await UserService().getUserProfile(user.uid);
        final residentName = userProfile?['name'] ?? 'Unknown';

        await VisitorService().preApproveVisitor(
          visitorName: _nameController.text.trim(),
          purpose: _purposeController.text.trim(),
          residentUid: user.uid,
          residentName: residentName,
          expectedAt: _selectedDateTime!,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Visitor pre-approved successfully!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to pre-approve visitor. Please try again.')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the expected arrival date and time.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pre-Approve Visitor"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Visitor's Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => value!.isEmpty ? "Please enter the visitor's name" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _purposeController,
                decoration: const InputDecoration(
                  labelText: "Purpose of Visit",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work_outline),
                ),
                validator: (value) => value!.isEmpty ? "Please enter the purpose of the visit" : null,
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(
                    _selectedDateTime == null
                        ? 'Expected Arrival Date & Time *'
                        : DateFormat('d MMM, yyyy  h:mm a').format(_selectedDateTime!),
                  ),
                  onTap: () => _selectDateTime(context),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Pre-Approve'),
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}