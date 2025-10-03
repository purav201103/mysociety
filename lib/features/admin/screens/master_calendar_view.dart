import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

// Data model for our calendar events. We'll expand this later.
class CalendarEvent {
  final String title;
  const CalendarEvent(this.title);

  @override
  String toString() => title;
}

class MasterCalendarView extends StatefulWidget {
  const MasterCalendarView({super.key});

  @override
  State<MasterCalendarView> createState() => _MasterCalendarViewState();
}

class _MasterCalendarViewState extends State<MasterCalendarView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // This will hold all our events fetched from the API
  // The key is the day, and the value is a list of events on that day.
  final Map<DateTime, List<CalendarEvent>> _events = {
    // Dummy Data for demonstration
    DateTime.utc(2025, 10, 16): [
      const CalendarEvent('Shift: John Doe (09:00-17:00)'),
      const CalendarEvent('Time Off: Jane Smith (Approved)'),
    ],
    DateTime.utc(2025, 10, 22): [
      const CalendarEvent('OPEN SHIFT (08:00-12:00)'),
    ],
  };

  // Function to get events for a specific day
  List<CalendarEvent> _getEventsForDay(DateTime day) {
    // Important: Use UTC for consistency
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin's Master Calendar"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          TableCalendar<CalendarEvent>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // update `_focusedDay` here as well
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              // Here you would typically fetch new data for the visible month
            },
            // This is the crucial part for displaying events
            eventLoader: _getEventsForDay,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  // A simple dot marker for days with events
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.redAccent,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 8.0),
          // List of events for the selected day
          Expanded(
            child: ListView.builder(
              itemCount: _getEventsForDay(_selectedDay ?? _focusedDay).length,
              itemBuilder: (context, index) {
                final event = _getEventsForDay(_selectedDay ?? _focusedDay)[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    onTap: () => print('Tapped on ${event.title}'),
                    title: Text(event.title),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}