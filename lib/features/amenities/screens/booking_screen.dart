// lib/features/amenities/screens/booking_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysociety/core/models/amenity_model.dart';
import 'package:mysociety/features/amenities/screens/booking_confirmation_screen.dart';
import 'package:mysociety/services/amenity_service.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingScreen extends StatefulWidget {
  final Amenity amenity;
  const BookingScreen({super.key, required this.amenity});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  Future<TimeOfDay?> _pickTime(BuildContext context, {TimeOfDay? initialTime}) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );
  }

  void _navigateToConfirmation(List<QueryDocumentSnapshot> existingBookings) {
    if (_selectedDay == null || _startTime == null || _endTime == null) return;

    final newBookingStart = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, _startTime!.hour, _startTime!.minute);
    final newBookingEnd = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, _endTime!.hour, _endTime!.minute);

    // Validate that end time is after start time
    if (!newBookingEnd.isAfter(newBookingStart)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End time must be after start time.')));
      return;
    }

    // Validate that the booking does not overlap with existing bookings
    for (var bookingDoc in existingBookings) {
      final bookingData = bookingDoc.data() as Map<String, dynamic>;
      final existingStart = (bookingData['startTime'] as Timestamp).toDate();
      final existingEnd = (bookingData['endTime'] as Timestamp).toDate();

      if (newBookingStart.isBefore(existingEnd) && newBookingEnd.isAfter(existingStart)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This time slot overlaps with an existing booking.')));
        return;
      }
    }

    // If no overlaps, navigate to the confirmation screen
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => BookingConfirmationScreen(
        amenity: widget.amenity,
        startTime: newBookingStart,
        endTime: newBookingEnd,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.amenity.name}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _startTime = null;
                    _endTime = null;
                  });
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.indigo,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            if (_selectedDay != null) ...[
              const SizedBox(height: 20),
              const Text("Select Time", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.timer_outlined),
                    onPressed: () async {
                      final time = await _pickTime(context);
                      if (time != null) setState(() => _startTime = time);
                    },
                    label: Text(_startTime == null ? 'Start Time' : _startTime!.format(context)),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.timer_off_outlined),
                    onPressed: () async {
                      final time = await _pickTime(context, initialTime: _startTime);
                      if (time != null) setState(() => _endTime = time);
                    },
                    label: Text(_endTime == null ? 'End Time' : _endTime!.format(context)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: AmenityService().getBookingsForDate(widget.amenity.id, _selectedDay!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Checking availability...")));
                  if (!snapshot.hasData) return const Center(child: Text("Could not fetch bookings."));

                  final existingBookings = snapshot.data!.docs;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text("Today's Bookings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (existingBookings.isEmpty)
                        const Center(child: Text("No bookings for this day yet.", style: TextStyle(fontStyle: FontStyle.italic)))
                      else
                        ...existingBookings.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final start = (data['startTime'] as Timestamp).toDate();
                          final end = (data['endTime'] as Timestamp).toDate();
                          return Text(
                            '• Booked: ${DateFormat('h:mm a').format(start)} - ${DateFormat('h:mm a').format(end)}',
                            style: const TextStyle(color: Colors.redAccent, fontSize: 15),
                          );
                        }).toList(),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        onPressed: (_startTime == null || _endTime == null) ? null : () => _navigateToConfirmation(existingBookings),
                        child: const Text('Review & Book'),
                      )
                    ],
                  );
                },
              ),
            ]
          ],
        ),
      ),
    );
  }
}