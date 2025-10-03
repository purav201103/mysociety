// lib/features/admin/widgets/assigned_vehicle_list_view.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mysociety/core/models/vehicle_model.dart';
import 'package:mysociety/features/admin/screens/relocate_vehicle_screen.dart';
import 'package:mysociety/services/vehicle_service.dart';

class AssignedVehicleListView extends StatefulWidget {
  const AssignedVehicleListView({super.key});
  @override
  State<AssignedVehicleListView> createState() =>
      _AssignedVehicleListViewState();
}

class _AssignedVehicleListViewState extends State<AssignedVehicleListView> {
  String _selectedType = '4-Wheeler';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ToggleButtons(
            borderRadius: BorderRadius.circular(8.0),
            isSelected: [
              _selectedType == '4-Wheeler',
              _selectedType == '2-Wheeler'
            ],
            onPressed: (index) {
              setState(() {
                _selectedType = index == 0 ? '4-Wheeler' : '2-Wheeler';
              });
            },
            children: const [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('4-Wheelers')),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('2-Wheelers')),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: VehicleService()
                .getAssignedVehiclesStream(vehicleType: _selectedType),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                    child: Text('No assigned $_selectedType found.'));
              }
              final vehicles = snapshot.data!.docs
                  .map((doc) => Vehicle.fromFirestore(doc))
                  .toList();
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    child: ListTile(
                      leading: Icon(
                          _selectedType == '4-Wheeler'
                              ? Icons.directions_car
                              : Icons.two_wheeler,
                          size: 40),
                      title: Text(vehicle.vehicleNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Spot: ${vehicle.parkingSpot}'),
                      trailing: const Icon(Icons.sync_alt_outlined),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              RelocateVehicleScreen(vehicle: vehicle),
                        ));
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}