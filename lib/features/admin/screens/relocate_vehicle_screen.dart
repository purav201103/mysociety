// lib/features/admin/screens/relocate_vehicle_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mysociety/core/models/vehicle_model.dart';
import 'package:mysociety/services/parking_service.dart';

class RelocateVehicleScreen extends StatefulWidget {
  final Vehicle vehicle;
  const RelocateVehicleScreen({super.key, required this.vehicle});
  @override
  State<RelocateVehicleScreen> createState() => _RelocateVehicleScreenState();
}

class _RelocateVehicleScreenState extends State<RelocateVehicleScreen> {
  final ParkingService _parkingService = ParkingService();
  String? _selectedNewSpotId;
  String? _selectedNewSpotNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relocate Vehicle')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Vehicle: ${widget.vehicle.vehicleNumber}',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text('Current Spot: ${widget.vehicle.parkingSpot}',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 24),
              const Text('Select a new available spot:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: _parkingService.getAvailableParkingSpotsStream(
                    vehicleType: widget.vehicle.vehicleType),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final spots = snapshot.data!.docs;
                  if (spots.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                            "No other available spots of this type found.",
                            style: TextStyle(fontStyle: FontStyle.italic)),
                      ),
                    );
                  }
                  return DropdownButtonFormField<String>(
                    hint: const Text('Select an Empty Spot'),
                    value: _selectedNewSpotId,
                    isExpanded: true,
                    items: spots.map((spotDoc) {
                      final spotData = spotDoc.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: spotDoc.id,
                        child: Text(spotData['spotNumber']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedNewSpotId = value;
                        // Find and store the spot number as well
                        final selectedDoc =
                        spots.firstWhere((doc) => doc.id == value);
                        _selectedNewSpotNumber =
                        (selectedDoc.data()
                        as Map<String, dynamic>)['spotNumber'];
                      });
                    },
                    decoration:
                    const InputDecoration(border: OutlineInputBorder()),
                  );
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: _selectedNewSpotId == null
                    ? null
                    : () async {
                  await _parkingService.relocateVehicle(
                    vehicle: widget.vehicle,
                    newSpotId: _selectedNewSpotId!,
                    newSpotNumber: _selectedNewSpotNumber!,
                  );
                  if (mounted) Navigator.of(context).pop();
                },
                child: const Text('Confirm Relocation'),
              )
            ],
          ),
        ),
      ),
    );
  }
}