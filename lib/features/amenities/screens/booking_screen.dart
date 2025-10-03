// lib/features/amenities/screens/booking_screen.dart
import 'package:flutter/material.dart';
import 'package:mysociety/core/models/amenity_model.dart';
import 'package:mysociety/services/amenity_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'booking_confirmation_screen.dart';

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
  TimeOfDay? _endTime; // New state for end time
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  // Generic method to show a time picker
  Future<TimeOfDay?> _selectTime(BuildContext context, {TimeOfDay? initialTime}) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );
  }

  // --- NEW METHOD TO HANDLE THE BOOKING PROCESS ---
  Future<void> _proceedToBooking() async {
    // 1. Basic Validation
    if (_selectedDay == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date, start time, and end time.')),
      );
      return;
    }

    final startTime = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, _startTime!.hour, _startTime!.minute);
    final endTime = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, _endTime!.hour, _endTime!.minute);

    if (endTime.isBefore(startTime) || endTime.isAtSameMomentAs(startTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after the start time.')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    // 2. Check for Clashes using our new service method
    final bool isAvailable = await AmenityService().isSlotAvailable(
      amenityId: widget.amenity.id,
      newStartTime: startTime,
      newEndTime: endTime,
    );

    setState(() { _isLoading = false; });

    if (!mounted) return; // Check if the widget is still in the tree

    // 3. Navigate or Show Error
    if (isAvailable) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmationScreen(
            amenity: widget.amenity,
            startTime: startTime,
            endTime: endTime,
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Booking Clash'),
          content: const Text('The selected time slot is unavailable. Please choose a different time.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.amenity.name}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Date', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
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
            ),
            const SizedBox(height: 20),
            Text('Select Time', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),

            // --- NEW UI FOR START AND END TIME ---
            Row(
              children: [
                Expanded(
                  child: _TimePickerTile(
                    label: 'Start Time',
                    time: _startTime,
                    onTap: () async {
                      final time = await _selectTime(context, initialTime: _startTime);
                      if (time != null) setState(() => _startTime = time);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _TimePickerTile(
                    label: 'End Time',
                    time: _endTime,
                    onTap: () async {
                      final time = await _selectTime(context, initialTime: _endTime ?? _startTime);
                      if (time != null) setState(() => _endTime = time);
                    },
                  ),
                ),
              ],
            ),
            // --- END OF NEW UI ---

            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _proceedToBooking,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Check Availability & Proceed'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for a consistent time picker button style
class _TimePickerTile extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;

  const _TimePickerTile({required this.label, this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              time == null ? 'Select' : time!.format(context),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}