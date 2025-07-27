// lib/models/term_models.dart

import 'package:flutter/material.dart';

class Term {
  final String id;
  final String name;
  final DateTime startDate;
  final int weekCount;

  Term({
    required this.id,
    required this.name,
    required this.startDate,
    required this.weekCount,
  });

  DateTime get endDate {
    // Calculate end date based on start date and week count
    // End on Friday of the last week
    final lastMonday = startDate.add(Duration(days: (weekCount - 1) * 7));
    final lastFriday = lastMonday.add(Duration(days: 4));
    return lastFriday;
  }

  int get totalDays {
    // Total teaching days (Monday to Friday only)
    return weekCount * 5;
  }

  List<DateTime> get weekStartDates {
    List<DateTime> dates = [];
    for (int i = 0; i < weekCount; i++) {
      dates.add(startDate.add(Duration(days: i * 7)));
    }
    return dates;
  }

  bool isDateInTerm(DateTime date) {
    return date.isAfter(startDate.subtract(Duration(days: 1))) &&
           date.isBefore(endDate.add(Duration(days: 1)));
  }

  int getWeekNumber(DateTime date) {
    if (!isDateInTerm(date)) return -1;
    
    final daysDiff = date.difference(startDate).inDays;
    return (daysDiff ~/ 7) + 1;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'weekCount': weekCount,
    };
  }

  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
      id: json['id'],
      name: json['name'],
      startDate: DateTime.parse(json['startDate']),
      weekCount: json['weekCount'],
    );
  }

  Term copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    int? weekCount,
  }) {
    return Term(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      weekCount: weekCount ?? this.weekCount,
    );
  }
}

class TermEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime? endDate; // Optional - null means single day event
  final TermEventType type;
  final Color color;

  TermEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    this.endDate, // Made optional
    required this.type,
    required this.color,
  });

  bool isOnDate(DateTime date) {
    final eventEndDate = endDate ?? startDate; // Use startDate if no endDate
    return date.isAfter(startDate.subtract(Duration(days: 1))) &&
           date.isBefore(eventEndDate.add(Duration(days: 1)));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'type': type.name,
      'color': color.value,
    };
  }

  factory TermEvent.fromJson(Map<String, dynamic> json) {
    return TermEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      type: TermEventType.values.firstWhere((t) => t.name == json['type']),
      color: Color(json['color']),
    );
  }
}

enum TermEventType {
  publicHoliday,
  schoolEvent,
  parentEvent,
  assessment,
  excursion,
  professionalDevelopment,
  staffMeeting,
  other;

  String get displayName {
    switch (this) {
      case TermEventType.publicHoliday:
        return 'Public Holiday';
      case TermEventType.schoolEvent:
        return 'School Event';
      case TermEventType.parentEvent:
        return 'Parent Event';
      case TermEventType.assessment:
        return 'Assessment';
      case TermEventType.excursion:
        return 'Excursion';
      case TermEventType.professionalDevelopment:
        return 'Professional Development';
      case TermEventType.staffMeeting:
        return 'Staff Meeting';
      case TermEventType.other:
        return 'Other';
    }
  }

  Color get defaultColor {
    switch (this) {
      case TermEventType.publicHoliday:
        return Colors.red;
      case TermEventType.schoolEvent:
        return Colors.blue;
      case TermEventType.parentEvent:
        return Colors.green;
      case TermEventType.assessment:
        return Colors.orange;
      case TermEventType.excursion:
        return Colors.purple;
      case TermEventType.professionalDevelopment:
        return Colors.teal;
      case TermEventType.staffMeeting:
        return Colors.brown;
      case TermEventType.other:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case TermEventType.publicHoliday:
        return Icons.beach_access;
      case TermEventType.schoolEvent:
        return Icons.school;
      case TermEventType.parentEvent:
        return Icons.people;
      case TermEventType.assessment:
        return Icons.quiz;
      case TermEventType.excursion:
        return Icons.directions_bus;
      case TermEventType.professionalDevelopment:
        return Icons.work;
      case TermEventType.staffMeeting:
        return Icons.meeting_room;
      case TermEventType.other:
        return Icons.event;
    }
  }
}

// Utility methods for working with Term Events
class TermEventUtils {
  static List<TermEvent> getEventsForDate(List<TermEvent> events, DateTime date) {
    return events.where((event) => event.isOnDate(date)).toList();
  }

  static List<TermEvent> getEventsForWeek(List<TermEvent> events, DateTime weekStart) {
    final weekEnd = weekStart.add(Duration(days: 6));
    return events.where((event) {
      final eventEndDate = event.endDate ?? event.startDate;
      // Event overlaps with this week
      return (event.startDate.isBefore(weekEnd.add(Duration(days: 1))) &&
              (eventEndDate.isAfter(weekStart.subtract(Duration(days: 1))) || 
               event.startDate.isAfter(weekStart.subtract(Duration(days: 1)))));
    }).toList();
  }
} 