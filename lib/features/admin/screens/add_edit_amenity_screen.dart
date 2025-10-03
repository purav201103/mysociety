// lib/features/admin/screens/add_edit_amenity_screen.dart
import 'package:flutter/material.dart';
import 'package:mysociety/core/models/amenity_model.dart';
import 'package:mysociety/services/amenity_service.dart';

class AddEditAmenityScreen extends StatefulWidget {
  final Amenity? amenity; // If amenity is null, it's a new one. Otherwise, we're editing.
  const AddEditAmenityScreen({super.key, this.amenity});

  @override
  State<AddEditAmenityScreen> createState() => _AddEditAmenityScreenState();
}

class _AddEditAmenityScreenState extends State<AddEditAmenityScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _costController;
  late TextEditingController _imageUrlController;
  bool get _isEditing => widget.amenity != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.amenity?.name ?? '');
    _descController = TextEditingController(text: widget.amenity?.description ?? '');
    _costController = TextEditingController(text: widget.amenity?.bookingCost.toString() ?? '');
    _imageUrlController = TextEditingController(text: widget.amenity?.imageUrl ?? '');
  }

  Future<void> _saveAmenity() async {
    if (_formKey.currentState!.validate()) {
      final service = AmenityService();
      if (_isEditing) {
        await service.updateAmenity(
          id: widget.amenity!.id,
          name: _nameController.text,
          description: _descController.text,
          bookingCost: double.parse(_costController.text),
          imageUrl: _imageUrlController.text,
        );
      } else {
        await service.addAmenity(
          name: _nameController.text,
          description: _descController.text,
          bookingCost: double.parse(_costController.text),
          imageUrl: _imageUrlController.text,
        );
      }
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Amenity' : 'Add Amenity')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Amenity Name')),
              TextFormField(controller: _descController, decoration: const InputDecoration(labelText: 'Description')),
              TextFormField(controller: _costController, decoration: const InputDecoration(labelText: 'Booking Cost'), keyboardType: TextInputType.number),
              TextFormField(controller: _imageUrlController, decoration: const InputDecoration(labelText: 'Image URL')),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _saveAmenity, child: const Text('Save Amenity')),
            ],
          ),
        ),
      ),
    );
  }
}