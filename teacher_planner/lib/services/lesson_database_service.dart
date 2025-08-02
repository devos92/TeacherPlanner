// lib/services/lesson_database_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import '../models/weekly_plan_data.dart';
import '../models/event_block.dart';
import '../models/curriculum_models.dart';

class LessonDatabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Save complete weekly plan
  static Future<bool> saveCompleteWeeklyPlan(List<WeeklyPlanData> planData, DateTime weekStartDate, int periods) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('User not authenticated');
        return false;
      }

      // Save the weekly plan record
      await _supabase
          .from('weekly_plans')
          .upsert({
            'user_id': user.id,
            'title': 'Weekly Plan - ${weekStartDate.toIso8601String().split('T')[0]}',
            'week_start_date': weekStartDate.toIso8601String().split('T')[0],
            'periods': periods,
            'plan_data': planData.map((data) => {
              'dayIndex': data.dayIndex,
              'periodIndex': data.periodIndex,
              'content': data.content,
              'subject': data.subject,
              'notes': data.notes,
              'lessonId': data.lessonId,
              'date': data.date?.toIso8601String(),
              'isLesson': data.isLesson,
              'isFullWeekEvent': data.isFullWeekEvent,
              'lessonColor': data.lessonColor != null ? {
                'r': data.lessonColor!.red,
                'g': data.lessonColor!.green,
                'b': data.lessonColor!.blue,
                'a': data.lessonColor!.alpha,
              } : null,
            }).toList(),
            'metadata': {
              'last_saved': DateTime.now().toIso8601String(),
              'lesson_count': planData.where((d) => d.isLesson).length,
            }
          });

      // Save individual lessons to lessons table
      final lessons = planData.where((data) => 
        data.isLesson && (data.subject.isNotEmpty || data.content.isNotEmpty)
      ).toList();

      for (final lesson in lessons) {
        final lessonData = {
          'teacher_id': user.id,
          'date': lesson.date?.toIso8601String().split('T')[0] ?? 
                  weekStartDate.add(Duration(days: lesson.dayIndex)).toIso8601String().split('T')[0],
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
          'lesson_color': lesson.lessonColor != null ? {
            'r': lesson.lessonColor!.red,
            'g': lesson.lessonColor!.green,
            'b': lesson.lessonColor!.blue,
            'a': lesson.lessonColor!.alpha,
          } : null,
          'metadata': {
            'week_start_date': weekStartDate.toIso8601String().split('T')[0],
            'auto_saved': true,
          },
        };

        // Check if lesson already exists
        final existing = await _supabase
            .from('lessons')
            .select('id')
            .eq('teacher_id', user.id)
            .eq('lesson_id', lesson.lessonId)
            .maybeSingle();

        if (existing != null) {
          // Update existing lesson
          await _supabase
              .from('lessons')
              .update(lessonData)
              .eq('id', existing['id']);
        } else {
          // Insert new lesson
          await _supabase
              .from('lessons')
              .insert(lessonData);
        }
      }

      debugPrint('Successfully saved weekly plan with ${lessons.length} lessons');
      return true;
    } catch (e) {
      debugPrint('Error saving weekly plan: $e');
      return false;
    }
  }

  // Load complete weekly plan
  static Future<List<WeeklyPlanData>> loadCompleteWeeklyPlan(DateTime weekStartDate) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('User not authenticated');
        return [];
      }

      // Try to load from weekly_plans table first
      final weekPlan = await _supabase
          .from('weekly_plans')
          .select('plan_data')
          .eq('user_id', user.id)
          .eq('week_start_date', weekStartDate.toIso8601String().split('T')[0])
          .maybeSingle();

      if (weekPlan != null && weekPlan['plan_data'] != null) {
        final planDataList = weekPlan['plan_data'] as List;
        return planDataList.map((data) {
          Color? lessonColor;
          if (data['lessonColor'] != null) {
            final colorData = data['lessonColor'] as Map<String, dynamic>;
            lessonColor = Color.fromARGB(
              colorData['a'] ?? 255,
              colorData['r'] ?? 0,
              colorData['g'] ?? 0,
              colorData['b'] ?? 0,
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
            lessonColor: lessonColor,
          );
        }).toList();
      }

      // Fallback: load from individual lessons
      final weekEndDate = weekStartDate.add(Duration(days: 4));
      final response = await _supabase
          .from('lessons')
          .select('*')
          .eq('teacher_id', user.id)
          .gte('date', weekStartDate.toIso8601String().split('T')[0])
          .lte('date', weekEndDate.toIso8601String().split('T')[0]);

      final List<WeeklyPlanData> planData = [];
      for (final event in response) {
        Color? lessonColor;
        if (event['lesson_color'] != null) {
          final colorData = event['lesson_color'] as Map<String, dynamic>;
          lessonColor = Color.fromARGB(
            colorData['a'] ?? 255,
            colorData['r'] ?? 0,
            colorData['g'] ?? 0,
            colorData['b'] ?? 0,
          );
        }

        planData.add(WeeklyPlanData(
          dayIndex: event['day_index'] ?? 0,
          periodIndex: event['period_index'] ?? 0,
          content: event['body'] ?? '',
          subject: event['subject'] ?? '',
          notes: event['notes'] ?? '',
          lessonId: event['lesson_id'] ?? event['id'].toString(),
          date: DateTime.parse(event['date']),
          isLesson: true,
          isFullWeekEvent: event['is_full_week_event'] ?? false,
          lessonColor: lessonColor,
        ));
      }

      debugPrint('Successfully loaded ${planData.length} lessons from database');
      return planData;
    } catch (e) {
      debugPrint('Error loading weekly plan: $e');
      return [];
    }
  }
} 
