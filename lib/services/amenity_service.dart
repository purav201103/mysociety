// lib/services/amenity_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mysociety/core/models/booking_model.dart';

class AmenityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get a stream of all available amenities
  Stream<QuerySnapshot> getAmenitiesStream() {
    return _firestore.collection('amenities').snapshots();
  }

  // In lib/services/amenity_service.dart

  Stream<QuerySnapshot> getBookingsForDate(String amenityId, DateTime date) {
    // Set the time to the very beginning of the selected day
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    // Set the time to the beginning of the next day
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('bookings')
        .where('amenityId', isEqualTo: amenityId)
    // CORRECTED: Query using the 'startTime' field instead of 'bookingDate'
        .where('startTime', isGreaterThanOrEqualTo: startOfDay)
        .where('startTime', isLessThan: endOfDay)
        .snapshots();
  }

  // In lib/services/amenity_service.dart

  Future<void> requestBooking({
    required String amenityId,
    required String amenityName,
    required String residentUid,
    required String residentName,
    required DateTime startTime, // Use DateTime for start
    required DateTime endTime,   // Use DateTime for end
    required double cost,
  }) async {
    await _firestore.collection('bookings').add({
      'amenityId': amenityId,
      'amenityName': amenityName,
      'residentUid': residentUid,
      'residentName': residentName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'cost': cost,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getBookingRequestsStream() {
    return _firestore
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // In lib/services/amenity_service.dart

// CREATE a new amenity
  Future<void> addAmenity({
    required String name,
    required String description,
    required double bookingCost,
    required String imageUrl,
  }) async {
    await _firestore.collection('amenities').add({
      'name': name,
      'description': description,
      'bookingCost': bookingCost,
      'image_url': imageUrl,
    });
  }

// UPDATE an existing amenity
  Future<void> updateAmenity({
    required String id,
    required String name,
    required String description,
    required double bookingCost,
    required String imageUrl,
  }) async {
    await _firestore.collection('amenities').doc(id).update({
      'name': name,
      'description': description,
      'bookingCost': bookingCost,
      'image_url': imageUrl,
    });
  }

// DELETE an amenity
  Future<void> deleteAmenity({required String id}) async {
    await _firestore.collection('amenities').doc(id).delete();
  }

// Get a stream of bookings for a specific resident
  Stream<QuerySnapshot> getMyBookingsStream({required String residentUid}) {
    return _firestore
        .collection('bookings')
        .where('residentUid', isEqualTo: residentUid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // In lib/services/amenity_service.dart

// Handles creation of single OR recurring bookings
  Future<void> createBookingRequests({
    required String amenityId,
    required String amenityName,
    required String residentUid,
    required String residentName,
    required DateTime startTime,
    required DateTime endTime,
    required double cost,
    required String recurrence, // "Never", "Weekly", "Monthly"
    DateTime? recurrenceEndDate,
  }) async {
    final batch = _firestore.batch();

    List<DateTime> bookingDates = [startTime];

    // If recurring, calculate all future dates
    if (recurrence != 'Never' && recurrenceEndDate != null) {
      DateTime nextDate = startTime;
      while (nextDate.isBefore(recurrenceEndDate)) {
        if (recurrence == 'Weekly') {
          nextDate = nextDate.add(const Duration(days: 7));
        } else if (recurrence == 'Monthly') {
          nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
        }
        if (nextDate.isBefore(recurrenceEndDate)) {
          bookingDates.add(nextDate);
        }
      }
    }

    // Create a booking document for each calculated date
    for (var date in bookingDates) {
      final docRef = _firestore.collection('bookings').doc();
      final newStartTime = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
      final newEndTime = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);

      batch.set(docRef, {
        'amenityId': amenityId,
        'amenityName': amenityName,
        'residentUid': residentUid,
        'residentName': residentName,
        'startTime': Timestamp.fromDate(newStartTime),
        'endTime': Timestamp.fromDate(newEndTime),
        'cost': cost,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).delete();
    } catch (e) {
      // It's good practice to handle potential errors
      print("Error cancelling booking: $e");
      throw Exception('Could not cancel the booking. Please try again later.');
    }
  }

  // Fetches start times for all approved/pending bookings for a specific amenity on a given day
  Stream<List<Timestamp>> getBookedSlotsForDay(String amenityId, DateTime day) {
    // Set start of the day
    final startOfDay = Timestamp.fromDate(DateTime(day.year, day.month, day.day));
    // Set end of the day
    final endOfDay = Timestamp.fromDate(DateTime(day.year, day.month, day.day, 23, 59, 59));

    return _firestore
        .collection('bookings')
        .where('amenityId', isEqualTo: amenityId)
        .where('startTime', isGreaterThanOrEqualTo: startOfDay)
        .where('startTime', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return doc.data()['startTime'] as Timestamp;
      }).toList();
    });
  }

  Future<bool> isSlotAvailable({
    required String amenityId,
    required DateTime newStartTime,
    required DateTime newEndTime,
  }) async {
    // 1. Fetch all bookings for the amenity on the selected day
    final startOfDay = DateTime(newStartTime.year, newStartTime.month, newStartTime.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final querySnapshot = await _firestore
        .collection('bookings')
        .where('amenityId', isEqualTo: amenityId)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('startTime', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    if (querySnapshot.docs.isEmpty) {
      // No bookings on this day, so the slot is definitely available
      return true;
    }

    // 2. Check for overlaps in the app
    for (final doc in querySnapshot.docs) {
      final existingBooking = Booking.fromFirestore(doc); // Using our model
      final existingStartTime = existingBooking.startTime.toDate();
      final existingEndTime = existingBooking.endTime.toDate();

      // The logic to check for an overlap is:
      // (NewStart < ExistingEnd) and (ExistingStart < NewEnd)
      if (newStartTime.isBefore(existingEndTime) && existingStartTime.isBefore(newEndTime)) {
        // A clash was found!
        return false;
      }
    }

    // No clashes found after checking all existing bookings
    return true;
  }

  Stream<QuerySnapshot> getBookingsByStatus(String status) {
    return _firestore
        .collection('bookings')
        .where('status', isEqualTo: status)
        .orderBy('startTime', descending: true) // Show most recent first
        .snapshots();
  }

  // --- NEW METHOD 2: Update the status of a booking ---
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    await _firestore
        .collection('bookings')
        .doc(bookingId)
        .update({'status': newStatus});
  }

}