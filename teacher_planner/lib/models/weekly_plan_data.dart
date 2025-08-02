// lib/models/weekly_plan_data.dart

import 'package:flutter/material.dart';

/// Simple data model for weekly planning
/// This will be deprecated in favor of EnhancedEventBlock
class WeeklyPlanData {
  final int dayIndex; // 0-4 (Monday-Friday)
  final int periodIndex; // 0-based period index
  final String content;
  final String subject;
  final String notes;
  final String lessonId;
  final DateTime? date;
  final bool isLesson;
  final bool isFullWeekEvent;
  final Color? lessonColor;
  final List<WeeklyPlanData> subLessons;

  const WeeklyPlanData({
    required this.dayIndex,
    required this.periodIndex,
    this.content = '',
    this.subject = '',
    this.notes = '',
    this.lessonId = '',
    this.date,
    this.isLesson = false,
    this.isFullWeekEvent = false,
    this.lessonColor,
    this.subLessons = const [],
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
    Color? lessonColor,
    List<WeeklyPlanData>? subLessons,
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
      lessonColor: lessonColor ?? this.lessonColor,
      subLessons: subLessons ?? this.subLessons,
    );
  }

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
      'lessonColor': lessonColor != null ? {
        'r': lessonColor!.red,
        'g': lessonColor!.green,
        'b': lessonColor!.blue,
        'a': lessonColor!.alpha,
      } : null,
      'subLessons': subLessons.map((e) => e.toJson()).toList(),
    };
  }

  factory WeeklyPlanData.fromJson(Map<String, dynamic> json) {
    Color? color;
    if (json['lessonColor'] != null) {
      final colorData = json['lessonColor'] as Map<String, dynamic>;
      color = Color.fromARGB(
        colorData['a'] ?? 255,
        colorData['r'] ?? 0,
        colorData['g'] ?? 0,
        colorData['b'] ?? 0,
      );
    }

    return WeeklyPlanData(
      dayIndex: json['dayIndex'] ?? 0,
      periodIndex: json['periodIndex'] ?? 0,
      content: json['content'] ?? '',
      subject: json['subject'] ?? '',
      notes: json['notes'] ?? '',
      lessonId: json['lessonId'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      isLesson: json['isLesson'] ?? false,
      isFullWeekEvent: json['isFullWeekEvent'] ?? false,
      lessonColor: color,
      subLessons: (json['subLessons'] as List<dynamic>? ?? [])
          .map((e) => WeeklyPlanData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}