// lib/services/vehicle_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new vehicle for a user
  // In lib/services/vehicle_service.dart
  Future<void> addVehicle({
    required String ownerUid,
    required String ownerName, // Add this
    required String vehicleNumber,
    required String vehicleType,
    required String model,
  }) async {
    await _firestore.collection('vehicles').add({
      'ownerUid': ownerUid,
      'ownerName': ownerName, // Add this
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'model': model,
      'createdAt': FieldValue.serverTimestamp(),
      'parkingSpot': null,
    });
  }

  // Get a stream of vehicles for the current user
  Stream<QuerySnapshot> getMyVehiclesStream({required String ownerUid}) {
    return _firestore
        .collection('vehicles')
        .where('ownerUid', isEqualTo: ownerUid)
        .snapshots();
  }

  // In lib/services/vehicle_service.dart
  Stream<QuerySnapshot> getAllVehiclesStream() {
    return _firestore.collection('vehicles').orderBy('createdAt', descending: true).snapshots();
  }

// Get a stream of vehicles that have not been assigned a parking spot
  Stream<QuerySnapshot> getUnassignedVehiclesStream({required String vehicleType}) {
    return _firestore
        .collection('vehicles')
        .where('parkingSpot', isNull: true)
        .where('vehicleType', isEqualTo: vehicleType) // Add this filter
        .snapshots();
  }

  // In lib/services/vehicle_service.dart

// Find a vehicle document by its registration number
  Future<DocumentSnapshot?> getVehicleByNumber({required String vehicleNumber}) async {
    try {
      final querySnapshot = await _firestore
          .collection('vehicles')
          .where('vehicleNumber', isEqualTo: vehicleNumber)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      }
      return null; // No vehicle found with that number
    } catch (e) {
      print(e);
      return null;
    }
  }

// Get a stream of vehicles that HAVE been assigned a parking spot
  Stream<QuerySnapshot> getAssignedVehiclesStream({required String vehicleType}) {
    return _firestore
        .collection('vehicles')
        .where('parkingSpot', isNotEqualTo: null)
        .where('vehicleType', isEqualTo: vehicleType)
        .snapshots();
  }

}