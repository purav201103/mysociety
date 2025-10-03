// lib/features/resident/screens/my_vehicles_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mysociety/core/models/vehicle_model.dart';
import 'package:mysociety/features/resident/screens/add_vehicle_screen.dart';
import 'package:mysociety/services/vehicle_service.dart';

class MyVehiclesScreen extends StatelessWidget {
  const MyVehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Scaffold(body: Center(child: Text("Not logged in.")));

    return Scaffold(
      appBar: AppBar(title: const Text('My Vehicles')),
      body: StreamBuilder<QuerySnapshot>(
        stream: VehicleService().getMyVehiclesStream(ownerUid: uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No vehicles registered yet.'));
          }
          final vehicles = snapshot.data!.docs.map((doc) => Vehicle.fromFirestore(doc)).toList();
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return Card(
                child: ListTile(
                  leading: Icon(vehicle.vehicleType == '4-Wheeler' ? Icons.directions_car : Icons.two_wheeler),
                  title: Text(vehicle.vehicleNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${vehicle.model}\nSpot: ${vehicle.parkingSpot ?? 'Not Assigned'}'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddVehicleScreen()));
        },
        tooltip: 'Add Vehicle',
        child: const Icon(Icons.add),
      ),
    );
  }
}