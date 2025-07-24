import 'package:flutter/material.dart';

/// Mutable event model to support resizing and width adjustment
class EventBlock {
  String day;
  String subject; // Title
  String subtitle; // Sub‑header
  String body; // our editable text
  Color color;
  int startHour;
  int startMinute; // Add minute support
  int finishHour; // Finish hour instead of duration
  int finishMinute; // Finish minute instead of duration
  double widthFactor;

  EventBlock({
    required this.day,
    required this.subject,
    this.subtitle = '',
    this.body = '',
    required this.color,
    required this.startHour,
    this.startMinute = 0, // Default to 0 minutes
    required this.finishHour,
    this.finishMinute = 0, // Default to 0 minutes
    this.widthFactor = 1.0,
  });

  // Helper getter for duration in minutes (for calculations)
  int get durationMinutes {
    final duration = (finishHour * 60 + finishMinute) - (startHour * 60 + startMinute);
    return duration > 0 ? duration : 15; // Minimum 15 minutes if invalid
  }

  // Helper getter for duration in hours (for display)
  double get durationHours {
    return durationMinutes / 60.0;
  }

  // Setter to validate finish time
  void setFinishTime(int hour, int minute) {
    final startMinutes = startHour * 60 + startMinute;
    final finishMinutes = hour * 60 + minute;
    
    if (finishMinutes > startMinutes) {
      finishHour = hour;
      finishMinute = minute;
    } else {
      // If finish time is before start time, set it to start time + 1 hour
      final newFinishMinutes = startMinutes + 60;
      finishHour = newFinishMinutes ~/ 60;
      finishMinute = newFinishMinutes % 60;
    }
  }
}

/// Layout info for overlapping events
class EventLayout {
  final EventBlock event;
  final int colIndex;
  final int totalCols;

  EventLayout({
    required this.event,
    required this.colIndex,
    required this.totalCols,
  });
} 