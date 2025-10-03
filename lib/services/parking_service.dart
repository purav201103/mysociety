// lib/services/parking_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/models/vehicle_model.dart';

class ParkingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get a stream of available parking spots
  Stream<QuerySnapshot> getAvailableParkingSpotsStream({required String vehicleType}) {
    return _firestore
        .collection('parking_spots')
        .where('status', isEqualTo: 'Available')
        .where('spotType', isEqualTo: vehicleType) // Add this filter
        .snapshots();
  }

  // Assign a spot to a vehicle in a single transaction
  Future<void> assignParkingSpot({
    required String vehicleId,
    required String vehicleNumber,
    required String spotId,
    required String spotNumber,
    required String residentUid,
    required String vehicleType,
  }) async {
    final vehicleRef = _firestore.collection('vehicles').doc(vehicleId);
    final spotRef = _firestore.collection('parking_spots').doc(spotId);

    return _firestore.runTransaction((transaction) async {
      // 1. Update the vehicle document
      transaction.update(vehicleRef, {'parkingSpot': spotNumber});
      // 2. Update the parking spot document
      transaction.update(spotRef, {
        'status': 'Assigned',
        'assignedToUid': residentUid,
        'assignedVehicleNumber': vehicleNumber,
        'vehicleType': vehicleType,
      });
    });
  }

// Get a stream of ALL parking spots, ordered by name
  Stream<QuerySnapshot> getAllParkingSpotsStream({required String spotType}) {
    return _firestore
        .collection('parking_spots')
        .where('spotType', isEqualTo: spotType)
        .orderBy('spotNumber')
        .snapshots();
  }

// Un-assign a spot from a vehicle (transactional update)
  Future<void> unassignParkingSpot({
    required String vehicleId,
    required String spotId,
  }) async {
    final vehicleRef = _firestore.collection('vehicles').doc(vehicleId);
    final spotRef = _firestore.collection('parking_spots').doc(spotId);

    return _firestore.runTransaction((transaction) async {
      // 1. Update the vehicle document, setting parkingSpot to null
      transaction.update(vehicleRef, {'parkingSpot': null});
      // 2. Update the parking spot document to be 'Available'
      transaction.update(spotRef, {
        'status': 'Available',
        'assignedToUid': null,
        'assignedVehicleNumber': null,
      });
    });
  }


// Creates a range of parking spots in a single batch operation
  Future<void> createParkingSpotsInRange({
    required String spotType,
    required String prefix,
    required int startNumber,
    required int endNumber,
  }) async {
    // Get a new write batch
    final batch = _firestore.batch();

    // Loop from the start to the end number
    for (int i = startNumber; i <= endNumber; i++) {
      // Format the spot number, e.g., "A-101"
      final spotNumber = '$prefix-${i.toString().padLeft(3, '0')}';
      // Create a reference for a new document with an auto-generated ID
      final spotRef = _firestore.collection('parking_spots').doc();

      // Add the set operation to the batch
      batch.set(spotRef, {
        'spotNumber': spotNumber,
        'spotType': spotType,
        'status': 'Available',
        'assignedToUid': null,
        'assignedVehicleNumber': null,
      });
    }

    // Commit the batch - this writes all the documents at once
    await batch.commit();
  }

// Deletes a parking spot document from Firestore
  Future<void> deleteParkingSpot({required String spotId}) async {
    try {
      await _firestore.collection('parking_spots').doc(spotId).delete();
    } catch (e) {
      print('Error deleting spot: $e');
      rethrow;
    }
  }

  // In lib/services/parking_service.dart

// Deletes all available spots of a specific type
  Future<void> deleteAllAvailableSpots({required String spotType}) async {
    final batch = _firestore.batch();
    final querySnapshot = await _firestore
        .collection('parking_spots')
        .where('spotType', isEqualTo: spotType)
        .where('status', isEqualTo: 'Available')
        .get();

    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

// Re-assigns a spot from an old vehicle to a new one
  Future<void> reassignSpot({
    required String spotId,
    required String spotNumber,
    required String oldVehicleId,
    required String newVehicleId,
    required String newVehicleNumber,
    required String newVehicleType,
    required String newResidentUid,
  }) async {
    final batch = _firestore.batch();

    // 1. Un-assign the old vehicle
    final oldVehicleRef = _firestore.collection('vehicles').doc(oldVehicleId);
    batch.update(oldVehicleRef, {'parkingSpot': null});

    // 2. Assign the new vehicle
    final newVehicleRef = _firestore.collection('vehicles').doc(newVehicleId);
    batch.update(newVehicleRef, {'parkingSpot': spotNumber});

    // 3. Update the parking spot itself
    final spotRef = _firestore.collection('parking_spots').doc(spotId);
    batch.update(spotRef, {
      'assignedToUid': newResidentUid,
      'assignedVehicleNumber': newVehicleNumber,
      'vehicleType': newVehicleType,
    });

    await batch.commit();
  }

  // In lib/services/parking_service.dart

// Helper to find a spot document by its number
  Future<DocumentSnapshot?> getSpotByNumber(String spotNumber) async {
    final querySnapshot = await _firestore
        .collection('parking_spots')
        .where('spotNumber', isEqualTo: spotNumber)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first;
    }
    return null;
  }

// A transaction to safely relocate a vehicle
  // In lib/services/parking_service.dart

  Future<void> relocateVehicle({
    required Vehicle vehicle,
    required String newSpotId,
    required String newSpotNumber,
  }) async {
    // --- START OF FIX ---
    // 1. Add a safety check to ensure the vehicle has a current spot.
    if (vehicle.parkingSpot == null) {
      throw Exception("Cannot relocate a vehicle that has no assigned spot.");
    }
    // --- END OF FIX ---

    final oldSpotDoc = await getSpotByNumber(vehicle.parkingSpot!);
    if (oldSpotDoc == null) {
      throw Exception("Could not find the old parking spot document in the database.");
    }

    final vehicleRef = _firestore.collection('vehicles').doc(vehicle.id);
    final oldSpotRef = oldSpotDoc.reference;
    final newSpotRef = _firestore.collection('parking_spots').doc(newSpotId);

    return _firestore.runTransaction((transaction) async {
      // Make the OLD spot "Available"
      transaction.update(oldSpotRef, {
        'status': 'Available',
        'assignedToUid': null,
        'assignedVehicleNumber': null,
      });

      // Make the NEW spot "Assigned"
      transaction.update(newSpotRef, {
        'status': 'Assigned',
        'assignedToUid': vehicle.ownerUid,
        'assignedVehicleNumber': vehicle.vehicleNumber,
        'vehicleType': vehicle.vehicleType,
      });

      // Update the VEHICLE with its new spot
      transaction.update(vehicleRef, {'parkingSpot': newSpotNumber});
    });
  }
}