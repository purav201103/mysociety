// lib/features/admin/screens/create_parking_spots_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mysociety/services/parking_service.dart';

class CreateParkingSpotsScreen extends StatefulWidget {
  const CreateParkingSpotsScreen({super.key});
  @override
  State<CreateParkingSpotsScreen> createState() => _CreateParkingSpotsScreenState();
}

class _CreateParkingSpotsScreenState extends State<CreateParkingSpotsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _prefixController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  String _selectedType = '4-Wheeler';
  bool _isLoading = false;

  Future<void> _generateSpots() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });
      try {
        await ParkingService().createParkingSpotsInRange(
          spotType: _selectedType,
          prefix: _prefixController.text.toUpperCase().trim(),
          startNumber: int.parse(_startController.text),
          endNumber: int.parse(_endController.text),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Parking spots created successfully!')));
          Navigator.of(context).pop();
        }
      } catch (e) {
        // Handle error
      } finally {
        if (mounted) setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Parking Spots')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Select Spot Type", style: TextStyle(fontWeight: FontWeight.bold)),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: '4-Wheeler', label: Text('4-Wheeler')),
                  ButtonSegment(value: '2-Wheeler', label: Text('2-Wheeler')),
                ],
                selected: {_selectedType},
                onSelectionChanged: (newSelection) {
                  setState(() { _selectedType = newSelection.first; });
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _prefixController,
                decoration: const InputDecoration(labelText: 'Prefix (e.g., A, B, P1)', border: OutlineInputBorder()),
                textCapitalization: TextCapitalization.characters,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startController,
                      decoration: const InputDecoration(labelText: 'Start Number', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _endController,
                      decoration: const InputDecoration(labelText: 'End Number', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(onPressed: _generateSpots, child: const Text('Generate Spots')),
            ],
          ),
        ),
      ),
    );
  }
}