// lib/features/admin/screens/assign_vehicle_to_spot_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mysociety/core/models/vehicle_model.dart';
import 'package:mysociety/services/parking_service.dart';
import 'package:mysociety/services/vehicle_service.dart';

class AssignVehicleToSpotScreen extends StatefulWidget {
  final String spotId;
  final String spotNumber;
  final String spotType; // Add this to know what type of vehicle to show
  const AssignVehicleToSpotScreen({
    super.key,
    required this.spotId,
    required this.spotNumber,
    required this.spotType,
  });

  @override
  State<AssignVehicleToSpotScreen> createState() => _AssignVehicleToSpotScreenState();
}

class _AssignVehicleToSpotScreenState extends State<AssignVehicleToSpotScreen> {
  final ParkingService _parkingService = ParkingService();
  final VehicleService _vehicleService = VehicleService();
  Vehicle? _selectedVehicle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assign Vehicle to ${widget.spotNumber}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Assigning a ${widget.spotType} to spot:', style: Theme.of(context).textTheme.titleMedium),
            Text(widget.spotNumber, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            StreamBuilder<QuerySnapshot>(
              stream: _vehicleService.getUnassignedVehiclesStream(vehicleType: widget.spotType),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final vehicles = snapshot.data!.docs.map((doc) => Vehicle.fromFirestore(doc)).toList();

                if (vehicles.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("No unassigned ${widget.spotType}s available.", style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16)),
                    ),
                  );
                }

                return DropdownButtonFormField<Vehicle>(
                  hint: Text('Select an Unassigned ${widget.spotType}'),
                  value: _selectedVehicle,
                  isExpanded: true,
                  items: vehicles.map((vehicle) {
                    return DropdownMenuItem(
                      value: vehicle,
                      child: Text('${vehicle.vehicleNumber} (${vehicle.ownerName})', overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedVehicle = value),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                );
              },
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: _selectedVehicle == null ? null : () async {
                await _parkingService.assignParkingSpot(
                  vehicleId: _selectedVehicle!.id,
                  vehicleNumber: _selectedVehicle!.vehicleNumber,
                  spotId: widget.spotId,
                  spotNumber: widget.spotNumber,
                  residentUid: _selectedVehicle!.ownerUid,
                  vehicleType: _selectedVehicle!.vehicleType,
                );
                if (mounted) Navigator.of(context).pop();
              },
              child: const Text('Confirm Assignment'),
            )
          ],
        ),
      ),
    );
  }
}