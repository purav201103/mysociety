// lib/features/admin/screens/reassign_spot_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mysociety/core/models/vehicle_model.dart';
import 'package:mysociety/services/parking_service.dart';
import 'package:mysociety/services/vehicle_service.dart';

class ReassignSpotScreen extends StatefulWidget {
  final DocumentSnapshot spot;
  const ReassignSpotScreen({super.key, required this.spot});

  @override
  State<ReassignSpotScreen> createState() => _ReassignSpotScreenState();
}

class _ReassignSpotScreenState extends State<ReassignSpotScreen> {
  final ParkingService _parkingService = ParkingService();
  final VehicleService _vehicleService = VehicleService();

  // We will store the ID and the full object of the selected vehicle
  String? _selectedNewVehicleId;
  Vehicle? _selectedNewVehicleObject;

  @override
  Widget build(BuildContext context) {
    final spotData = widget.spot.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(title: Text('Edit Assignment for ${spotData['spotNumber']}')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Currently assigned to:', style: Theme.of(context).textTheme.titleMedium),
              Text(spotData['assignedVehicleNumber'], style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              const Text('Assign a new vehicle:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: _vehicleService.getUnassignedVehiclesStream(vehicleType: spotData['spotType']),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final vehicles = snapshot.data!.docs.map((doc) => Vehicle.fromFirestore(doc)).toList();

                  if (vehicles.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("No other unassigned vehicles of this type are available.",
                            textAlign: TextAlign.center, style: TextStyle(fontStyle: FontStyle.italic)),
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>( // Use String for the value type
                    hint: const Text('Select a New Vehicle'),
                    value: _selectedNewVehicleId, // Use the ID here
                    isExpanded: true,
                    items: vehicles.map((vehicle) {
                      return DropdownMenuItem(
                        value: vehicle.id, // The value is the String ID
                        child: Text('${vehicle.vehicleNumber} (${vehicle.ownerName})', overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedNewVehicleId = value;
                        // Find and store the full vehicle object when the ID is selected
                        _selectedNewVehicleObject = vehicles.firstWhere((v) => v.id == value);
                      });
                    },
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: _selectedNewVehicleObject == null ? null : () async {
                  final oldVehicleDoc = await _vehicleService.getVehicleByNumber(vehicleNumber: spotData['assignedVehicleNumber']);
                  if (oldVehicleDoc == null) return;

                  await _parkingService.reassignSpot(
                    spotId: widget.spot.id,
                    spotNumber: spotData['spotNumber'],
                    oldVehicleId: oldVehicleDoc.id,
                    newVehicleId: _selectedNewVehicleObject!.id,
                    newVehicleNumber: _selectedNewVehicleObject!.vehicleNumber,
                    newVehicleType: _selectedNewVehicleObject!.vehicleType,
                    newResidentUid: _selectedNewVehicleObject!.ownerUid,
                  );
                  if (mounted) Navigator.of(context).pop();
                },
                child: const Text('Confirm Re-assignment'),
              )
            ],
          ),
        ),
      ),
    );
  }
}