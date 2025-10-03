// lib/models/calendar_event_model.dart

import 'package:flutter/material.dart';

// Enum to define the type of event
enum EventType { scheduledShift, timeOff, openShift }

// Enum for the status of a request or shift
enum EventStatus { confirmed, pending, approved, denied }

class MasterCalendarEvent {
  final String title; // e.g., "John Doe", "Sick Leave", "Morning Shift"
  final String description; // e.g., "Senior Nurse", "Full Day", "Cashier Needed"
  final DateTime date;
  final EventType eventType;
  final EventStatus status;

  MasterCalendarEvent({
    required this.title,
    required this.description,
    required this.date,
    required this.eventType,
    required this.status,
  });

  // Helper function to get a color based on the event type and status
  Color get eventColor {
    switch (eventType) {
      case EventType.scheduledShift:
        return Colors.blue.shade700;
      case EventType.timeOff:
        return status == EventStatus.approved ? Colors.green.shade700 : Colors.orange.shade700;
      case EventType.openShift:
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  // Helper function to get an icon based on the event type
  IconData get eventIcon {
    switch (eventType) {
      case EventType.scheduledShift:
        return Icons.person_outline;
      case EventType.timeOff:
        return Icons.beach_access_outlined;
      case EventType.openShift:
        return Icons.add_alert_outlined;
      default:
        return Icons.event_note_outlined;
    }
  }
}