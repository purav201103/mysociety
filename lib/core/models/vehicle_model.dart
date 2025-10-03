// lib/core/models/vehicle_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';


class Vehicle extends Equatable {
  final String id;
  final String ownerUid;
  final String ownerName;
  final String vehicleNumber;
  final String vehicleType;
  final String model;
  final String? parkingSpot;

  const Vehicle({
    required this.id,
    required this.ownerUid,
    required this.ownerName,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.model,
    this.parkingSpot,
  });

  @override
  // This tells Equatable that two Vehicle objects are the same
  // if and only if their 'id' is the same.
  List<Object?> get props => [id];

  factory Vehicle.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Vehicle(
      id: doc.id,
      ownerUid: data['ownerUid'] ?? '',
      ownerName: data['ownerName'] ?? 'N/A',
      vehicleNumber: data['vehicleNumber'] ?? '',
      vehicleType: data['vehicleType'] ?? '',
      model: data['model'] ?? '',
      parkingSpot: data['parkingSpot'],
    );
  }
}