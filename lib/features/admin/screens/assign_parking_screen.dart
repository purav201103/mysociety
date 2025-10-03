// lib/features/admin/screens/assign_parking_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mysociety/core/models/vehicle_model.dart';
import 'package:mysociety/services/parking_service.dart';

class AssignParkingScreen extends StatefulWidget {
  final Vehicle vehicle;
  const AssignParkingScreen({super.key, required this.vehicle});

  @override
  State<AssignParkingScreen> createState() => _AssignParkingScreenState();
}

class _AssignParkingScreenState extends State<AssignParkingScreen> {
  final ParkingService _parkingService = ParkingService();
  String? _selectedSpotId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assign Spot to ${widget.vehicle.vehicleNumber}')),
      // Wrap the Padding with SingleChildScrollView to prevent overflow
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Assigning spot for:', style: Theme.of(context).textTheme.titleMedium),
              Text(widget.vehicle.model, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              StreamBuilder<QuerySnapshot>(
                stream: _parkingService.getAvailableParkingSpotsStream(vehicleType: widget.vehicle.vehicleType),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final spots = snapshot.data!.docs;
                  if (spots.isEmpty) {
                    return const Text("No available spots found.");
                  }
                  return DropdownButtonFormField<String>(
                    hint: const Text('Select an Available Spot'),
                    value: _selectedSpotId,
                    items: spots.map((spot) {
                      return DropdownMenuItem(
                        value: spot.id,
                        child: Text(spot['spotNumber']),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedSpotId = value),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: _selectedSpotId == null ? null : () async {
                    final selectedSpotDoc = await FirebaseFirestore.instance.collection('parking_spots').doc(_selectedSpotId).get();
                    await _parkingService.assignParkingSpot(
                      vehicleId: widget.vehicle.id,
                      vehicleNumber: widget.vehicle.vehicleNumber,
                      spotId: _selectedSpotId!,
                      spotNumber: selectedSpotDoc['spotNumber'],
                      residentUid: widget.vehicle.ownerUid,
                      vehicleType: widget.vehicle.vehicleType, // <-- ADD THIS
                    );
                    if (mounted) Navigator.of(context).pop();
                  },
                child: const Text('Confirm Assignment'),
              )
            ],
          ),
        ),
      ),
    );
  }
}