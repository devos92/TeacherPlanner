// lib/services/lesson_database_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/weekly_plan_data.dart';
import '../models/event_block.dart';
import '../models/curriculum_models.dart';

class LessonDatabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Save complete weekly plan (upsert by user_id + week_start_date)
  static Future<bool> saveCompleteWeeklyPlan(
    List<WeeklyPlanData> planData,
    DateTime weekStartDate,
    int periods,
  ) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('User not authenticated');
        return false;
      }

      // Format dates
      final startDateStr = weekStartDate.toIso8601String().split('T')[0];
      final endDate = weekStartDate.add(Duration(days: 4));
      final endDateStr = endDate.toIso8601String().split('T')[0];

      // Prepare plan_data JSON
      final planJson = planData.map((data) {
        return {
          'dayIndex': data.dayIndex,
          'periodIndex': data.periodIndex,
          'content': data.content,
          'subject': data.subject,
          'notes': data.notes,
          'lessonId': data.lessonId,
          'date': data.date?.toIso8601String(),
          'isLesson': data.isLesson,
          'isFullWeekEvent': data.isFullWeekEvent,
          'lessonColor': data.lessonColor != null
              ? {
                  'r': data.lessonColor!.red,
                  'g': data.lessonColor!.green,
                  'b': data.lessonColor!.blue,
                  'a': data.lessonColor!.alpha,
                }
              : null,
        };
      }).toList();

      // Upsert weekly_plans record
      await _supabase
          .from('weekly_plans')
          .upsert(
            {
              'user_id': user.id,
              'title': 'Weekly Plan - $startDateStr',
              'start_date': startDateStr,
              'end_date': endDateStr,
              'week_start_date': startDateStr,
              'periods': periods,
              'is_vertical_layout': true,
              'plan_data': planJson,
            },
            onConflict: ['user_id', 'week_start_date'],
          );

      // Save individual lessons
      final lessons = planData.where((d) {
        return d.isLesson && (d.subject.isNotEmpty || d.content.isNotEmpty);
      }).toList();

      for (final lesson in lessons) {
        final lessonDate = lesson.date ??
            weekStartDate.add(Duration(days: lesson.dayIndex));
        final lessonDateStr = lessonDate.toIso8601String().split('T')[0];

        final lessonData = {
          'teacher_id': user.id,
          'date': lessonDateStr,
          'start_time': '${8 + lesson.periodIndex}:00:00',
          'end_time': '${9 + lesson.periodIndex}:00:00',
          'subject': lesson.subject,
          'subtitle': 'Period ${lesson.periodIndex + 1}',
          'body': lesson.content,
          'notes': lesson.notes,
          'status': 'planned',
          'priority': 1,
          'day_index': lesson.dayIndex,
          'period_index': lesson.periodIndex,
          'lesson_id': lesson.lessonId,
          'is_full_week_event': lesson.isFullWeekEvent,
          'lesson_color': lesson.lessonColor != null
              ? {
                  'r': lesson.lessonColor!.red,
                  'g': lesson.lessonColor!.green,
                  'b': lesson.lessonColor!.blue,
                  'a': lesson.lessonColor!.alpha,
                }
              : null,
        };

        // Check existing lesson by lesson_id
        final existing = await _supabase
            .from('lessons')
            .select('id')
            .eq('teacher_id', user.id)
            .eq('lesson_id', lesson.lessonId)
            .maybeSingle();

        if (existing != null && existing['id'] != null) {
          await _supabase
              .from('lessons')
              .update(lessonData)
              .eq('id', existing['id']);
        } else {
          await _supabase.from('lessons').insert(lessonData);
        }
      }

      debugPrint('Successfully saved weekly plan and ${lessons.length} lessons');
      return true;
    } catch (e) {
      debugPrint('Error saving weekly plan: \$e');
      return false;
    }
  }

  /// Load complete weekly plan from weekly_plans or fallback to lessons
  static Future<List<WeeklyPlanData>> loadCompleteWeeklyPlan(
    DateTime weekStartDate,
  ) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final startDateStr = weekStartDate.toIso8601String().split('T')[0];

      // Try weekly_plans first
      final weekPlan = await _supabase
          .from('weekly_plans')
          .select('plan_data')
          .eq('user_id', user.id)
          .eq('week_start_date', startDateStr)
          .maybeSingle();

      if (weekPlan != null && weekPlan['plan_data'] != null) {
        final List<dynamic> raw = weekPlan['plan_data'] as List<dynamic>;
        return raw.map((data) {
          Color? color;
          if (data['lessonColor'] != null) {
            final d = data['lessonColor'] as Map<String, dynamic>;
            color = Color.fromARGB(
              d['a'] ?? 255,
              d['r'] ?? 0,
              d['g'] ?? 0,
              d['b'] ?? 0,
            );
          }
          return WeeklyPlanData(
            dayIndex: data['dayIndex'] ?? 0,
            periodIndex: data['periodIndex'] ?? 0,
            content: data['content'] ?? '',
            subject: data['subject'] ?? '',
            notes: data['notes'] ?? '',
            lessonId: data['lessonId'] ?? '',
            date: data['date'] != null ? DateTime.parse(data['date']) : null,
            isLesson: data['isLesson'] ?? false,
            isFullWeekEvent: data['isFullWeekEvent'] ?? false,
            lessonColor: color,
          );
        }).toList();
      }

      // Fallback to lessons table
      final weekEnd = weekStartDate.add(Duration(days: 4));
      final response = await _supabase
          .from('lessons')
          .select('*')
          .eq('teacher_id', user.id)
          .gte('date', startDateStr)
          .lte('date', weekEnd.toIso8601String().split('T')[0]);

      final List<WeeklyPlanData> list = [];
      for (final e in response) {
        Color? color;
        if (e['lesson_color'] != null) {
          final d = e['lesson_color'] as Map<String, dynamic>;
          color = Color.fromARGB(
            d['a'] ?? 255,
            d['r'] ?? 0,
            d['g'] ?? 0,
            d['b'] ?? 0,
          );
        }
        list.add(WeeklyPlanData(
          dayIndex: e['day_index'] ?? 0,
          periodIndex: e['period_index'] ?? 0,
          content: e['body'] ?? '',
          subject: e['subject'] ?? '',
          notes: e['notes'] ?? '',
          lessonId: e['lesson_id'] ?? e['id'].toString(),
          date: DateTime.parse(e['date']),
          isLesson: true,
          isFullWeekEvent: e['is_full_week_event'] ?? false,
          lessonColor: color,
        ));
      }
      return list;
    } catch (e) {
      debugPrint('Error loading weekly plan: \$e');
      return [];
    }
  }
}
