import 'package:flutter/material.dart';

class WeeklyPlanData {
  final int dayIndex;
  final int periodIndex;
  final String content;
  final String subject;
  final String notes;
  final String lessonId; // Add unique lesson ID for drag and drop
  final DateTime? date; // Add date for term planner integration
  final bool isLesson; // Distinguish between lessons and other content
  final bool isFullWeekEvent; // For events like lunch, recess that span all days
  final List<WeeklyPlanData> subLessons; // For multiple lessons in one cell
  final Color? lessonColor; // Add custom color for lessons

  WeeklyPlanData({
    required this.dayIndex,
    required this.periodIndex,
    this.content = '',
    this.subject = '',
    this.notes = '',
    this.lessonId = '',
    this.date,
    this.isLesson = false,
    this.isFullWeekEvent = false,
    this.subLessons = const [],
    this.lessonColor,
  });

  WeeklyPlanData copyWith({
    int? dayIndex,
    int? periodIndex,
    String? content,
    String? subject,
    String? notes,
    String? lessonId,
    DateTime? date,
    bool? isLesson,
    bool? isFullWeekEvent,
    List<WeeklyPlanData>? subLessons,
    Color? lessonColor,
  }) {
    return WeeklyPlanData(
      dayIndex: dayIndex ?? this.dayIndex,
      periodIndex: periodIndex ?? this.periodIndex,
      content: content ?? this.content,
      subject: subject ?? this.subject,
      notes: notes ?? this.notes,
      lessonId: lessonId ?? this.lessonId,
      date: date ?? this.date,
      isLesson: isLesson ?? this.isLesson,
      isFullWeekEvent: isFullWeekEvent ?? this.isFullWeekEvent,
      subLessons: subLessons ?? this.subLessons,
      lessonColor: lessonColor ?? this.lessonColor,
    );
  }

  // JSON serialization for caching
  Map<String, dynamic> toJson() {
    return {
      'dayIndex': dayIndex,
      'periodIndex': periodIndex,
      'content': content,
      'subject': subject,
      'notes': notes,
      'lessonId': lessonId,
      'date': date?.toIso8601String(),
      'isLesson': isLesson,
      'isFullWeekEvent': isFullWeekEvent,
      'subLessons': subLessons.map((e) => e.toJson()).toList(),
      'lessonColor': lessonColor?.value,
    };
  }

  factory WeeklyPlanData.fromJson(Map<String, dynamic> json) {
    return WeeklyPlanData(
      dayIndex: json['dayIndex'] as int,
      periodIndex: json['periodIndex'] as int,
      content: json['content'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      lessonId: json['lessonId'] as String? ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      isLesson: json['isLesson'] as bool? ?? false,
      isFullWeekEvent: json['isFullWeekEvent'] as bool? ?? false,
      subLessons: (json['subLessons'] as List<dynamic>? ?? [])
          .map((e) => WeeklyPlanData.fromJson(e as Map<String, dynamic>))
          .toList(),
      lessonColor: json['lessonColor'] != null 
          ? Color(json['lessonColor'] as int)
          : null,
    );
  }
} 