// lib/features/amenities/screens/booking_confirmation_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysociety/core/models/amenity_model.dart';
import 'package:mysociety/services/amenity_service.dart';
import 'package:mysociety/services/user_service.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final Amenity amenity;
  final DateTime startTime;
  final DateTime endTime;

  // THIS IS THE FIX: We remove the unnecessary selectedDate and selectedTime
  const BookingConfirmationScreen({
    super.key,
    required this.amenity,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _isLoading = false;
  String _recurrence = 'Never';
  DateTime? _recurrenceEndDate;

  Future<void> _confirmBooking() async {
    // Prevent booking if recurrence is selected but no end date is set.
    if (_recurrence != 'Never' && _recurrenceEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an end date for the recurrence.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userProfile = await UserService().getUserProfile(user.uid);

      await AmenityService().createBookingRequests(
        amenityId: widget.amenity.id,
        amenityName: widget.amenity.name,
        residentUid: user.uid,
        residentName: userProfile?['name'] ?? 'Unknown',
        startTime: widget.startTime,
        endTime: widget.endTime,
        cost: widget.amenity.bookingCost,
        recurrence: _recurrence,
        recurrenceEndDate: _recurrenceEndDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Booking request(s) sent successfully!')));
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      // --- IMPROVEMENT: Show an error message to the user ---
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send booking request: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the button should be disabled
    final bool isButtonDisabled = _isLoading || (_recurrence != 'Never' && _recurrenceEndDate == null);

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Your Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Booking Summary',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const Divider(height: 24),
                    _SummaryRow(label: 'Amenity', value: widget.amenity.name),
                    _SummaryRow(
                        label: 'Date',
                        value: DateFormat('EEEE, d MMMM yyyy')
                            .format(widget.startTime)),
                    _SummaryRow(
                        label: 'Time',
                        value:
                        '${DateFormat('h:mm a').format(widget.startTime)} - ${DateFormat('h:mm a').format(widget.endTime)}'),
                    _SummaryRow(
                        label: 'Cost',
                        value: '₹${widget.amenity.bookingCost.toStringAsFixed(0)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // --- RECURRENCE SECTION ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Recurrence',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: _recurrence,
                      isExpanded: true,
                      items: ['Never', 'Weekly', 'Monthly']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                            value: value, child: Text(value));
                      }).toList(),
                      onChanged: (newValue) =>
                          setState(() => _recurrence = newValue!),
                    ),
                    if (_recurrence != 'Never') ...[
                      const SizedBox(height: 10),
                      ListTile(
                        title: Text(_recurrenceEndDate == null
                            ? 'Repeat Until...'
                            : DateFormat('d MMMM, yyyy')
                            .format(_recurrenceEndDate!)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            // --- FIX: All dates are now relative to startTime ---
                            initialDate: widget.startTime.add(const Duration(days: 30)),
                            firstDate: widget.startTime.add(const Duration(days: 1)),
                            lastDate: widget.startTime.add(const Duration(days: 365)),
                          );
                          if (pickedDate != null) {
                            setState(() => _recurrenceEndDate = pickedDate);
                          }
                        },
                      )
                    ]
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  // --- FIX: Cleaner button logic ---
                  backgroundColor: isButtonDisabled ? Colors.grey : Theme.of(context).primaryColor,
                  foregroundColor: Colors.white
              ),
              onPressed: isButtonDisabled ? null : _confirmBooking,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Confirm & Send Request'),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for a consistent row style
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}