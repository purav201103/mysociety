// lib/features/resident/screens/add_vehicle_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mysociety/services/user_service.dart';
import 'package:mysociety/services/vehicle_service.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  final _modelController = TextEditingController();
  String? _selectedType;
  bool _isLoading = false;

  final List<String> _vehicleTypes = ['2-Wheeler', '4-Wheeler'];

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _submitVehicle() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });
      try {
        final user = FirebaseAuth.instance.currentUser!;
        final userProfile = await UserService().getUserProfile(user.uid);
        final ownerName = userProfile?['name'] ?? 'Unknown';

        await VehicleService().addVehicle(
          ownerUid: user.uid,
          ownerName: ownerName,
          vehicleNumber: _vehicleNumberController.text.toUpperCase().trim(),
          vehicleType: _selectedType!,
          model: _modelController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehicle added successfully!')));
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) {
          setState(() { _isLoading = false; });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Vehicle')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [ // <-- Make sure this 'children:' keyword is present
              TextFormField(
                controller: _vehicleNumberController,
                decoration: const InputDecoration(labelText: 'Vehicle Number (e.g., GJ01AB1234)', border: OutlineInputBorder()),
                textCapitalization: TextCapitalization.characters,
                validator: (value) => value!.isEmpty ? 'Please enter a vehicle number' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Vehicle Type', border: OutlineInputBorder()),
                items: _vehicleTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (value) => setState(() => _selectedType = value),
                validator: (value) => value == null ? 'Please select a type' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Make & Model (e.g., Honda Activa)', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter make and model' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submitVehicle,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Add Vehicle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}