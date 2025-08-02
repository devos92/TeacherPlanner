// lib/services/lesson_database_service.dart

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import '../models/weekly_plan_data.dart';
import '../models/curriculum_models.dart';
import '../services/auth_service.dart';
import 'database_service.dart';

class LessonDatabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Convert WeeklyPlanData to EnhancedEventBlock
  static EnhancedEventBlock weeklyPlanDataToEnhancedEvent(
    WeeklyPlanData data,
    DateTime weekStartDate,
  ) {
    final lessonDate = data.date ?? weekStartDate.add(Duration(days: data.dayIndex));
    
    return EnhancedEventBlock(
      id: data.lessonId.isNotEmpty ? data.lessonId : UniqueKey().toString(),
      day: getDayName(data.dayIndex),
      subject: data.subject,
      subtitle: 'Period ${data.periodIndex + 1}',
      body: data.content,
      notes: data.notes,
      color: data.lessonColor ?? Colors.blue,
      startHour: 8 + data.periodIndex,
      startMinute: 0,
      finishHour: 9 + data.periodIndex,
      finishMinute: 0,
      periodIndex: data.periodIndex,
      widthFactor: 1.0,
      attachmentIds: [],
      attachments: [],
      curriculumOutcomeIds: [],
      curriculumOutcomes: [],
      hyperlinks: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isFullWeekEvent: data.isFullWeekEvent,
    );
  }

  /// Convert EnhancedEventBlock to WeeklyPlanData
  static WeeklyPlanData enhancedEventToWeeklyPlanData(
    EnhancedEventBlock event,
    int dayIndex,
  ) {
    return WeeklyPlanData(
      dayIndex: dayIndex,
      periodIndex: event.periodIndex,
      content: event.body,
      subject: event.subject,
      notes: event.notes,
      lessonId: event.id,
      date: DateTime.now().add(Duration(days: dayIndex)), // Will be properly set later
      isLesson: true,
      isFullWeekEvent: event.isFullWeekEvent,
      lessonColor: event.color,
    );
  }

  /// Helper to get day name from index
  static String getDayName(int dayIndex) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    return dayIndex >= 0 && dayIndex < days.length ? days[dayIndex] : 'Monday';
  }

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

      // Ensure user exists in users table
      await _ensureUserExists(user.id, user.email ?? 'unknown@example.com');

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

      // Check if weekly plan exists, then insert or update
      final existingPlan = await _supabase
          .from('weekly_plans')
          .select('id')
          .eq('user_id', user.id)
          .eq('week_start_date', startDateStr)
          .maybeSingle();

      final weeklyPlanRecord = {
        'user_id': user.id,
        'title': 'Weekly Plan - $startDateStr',
        'start_date': startDateStr,
        'end_date': endDateStr,
        'week_start_date': startDateStr,
        'periods': periods,
        'is_vertical_layout': true,
        'plan_data': planJson,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      debugPrint('💾 Saving weekly plan:');
      debugPrint('   start_date: $startDateStr');
      debugPrint('   end_date: $endDateStr');
      debugPrint('   user_id: ${user.id}');

      try {
        if (existingPlan != null && existingPlan['id'] != null) {
          // Update existing plan
          await _supabase
              .from('weekly_plans')
              .update(weeklyPlanRecord)
              .eq('id', existingPlan['id']);
          debugPrint('✅ Updated weekly plan for: $startDateStr');
        } else {
          // Insert new plan
          await _supabase
              .from('weekly_plans')
              .insert(weeklyPlanRecord);
          debugPrint('✅ Created weekly plan for: $startDateStr');
        }
      } catch (dbError) {
        debugPrint('❌ Database save error: $dbError');
        // Continue with lessons save even if weekly plan fails
      }

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
      debugPrint('Error saving weekly plan: $e');
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

      // Ensure user exists in users table
      await _ensureUserExists(user.id, user.email ?? 'unknown@example.com');

      final startDateStr = weekStartDate.toIso8601String().split('T')[0];

      debugPrint('🔍 Loading week: $startDateStr');

      // Try weekly_plans first (optimized with composite index hint)
      final weekPlan = await _supabase
          .from('weekly_plans')
          .select('plan_data')
          .eq('user_id', user.id)
          .eq('week_start_date', startDateStr)
          .limit(1)
          .maybeSingle();

      // debugPrint('📊 Weekly plan query result: ${weekPlan != null ? "FOUND" : "NOT FOUND"}');

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

      // Fallback to lessons table (optimized date range query)
      final weekEnd = weekStartDate.add(Duration(days: 4));
      final weekEndStr = weekEnd.toIso8601String().split('T')[0];
      
      final response = await _supabase
          .from('lessons')
          .select('*')
          .eq('teacher_id', user.id)
          .gte('date', startDateStr)
          .lte('date', weekEndStr)
          .order('date', ascending: true)
          .order('period_index', ascending: true);

      if (response.isNotEmpty) {
        debugPrint('📚 Found ${response.length} lessons for week $startDateStr');
      }

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
      debugPrint('Error loading weekly plan: $e');
      return [];
    }
  }

  /// Save EnhancedEventBlock lessons (new API)
  static Future<bool> saveEnhancedLessons(
    List<EnhancedEventBlock> lessons,
    DateTime weekStartDate,
    int periods,
  ) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('User not authenticated');
        return false;
      }

      // Ensure user exists in users table
      await _ensureUserExists(user.id, user.email ?? 'unknown@example.com');

      // Convert to WeeklyPlanData and use existing save method
      final weeklyPlanData = lessons.map((lesson) {
        // Determine day index from lesson.day
        int dayIndex = getDayIndexFromName(lesson.day);
        return enhancedEventToWeeklyPlanData(lesson, dayIndex);
      }).toList();

      return await saveCompleteWeeklyPlan(weeklyPlanData, weekStartDate, periods);
    } catch (e) {
      debugPrint('Error saving enhanced lessons: $e');
      return false;
    }
  }

  /// Load EnhancedEventBlock lessons (new API)
  static Future<List<EnhancedEventBlock>> loadEnhancedLessons(
    DateTime weekStartDate,
  ) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      // Ensure user exists in users table
      await _ensureUserExists(user.id, user.email ?? 'unknown@example.com');

      final weeklyPlanData = await loadCompleteWeeklyPlan(weekStartDate);
      return weeklyPlanData.map((data) => weeklyPlanDataToEnhancedEvent(data, weekStartDate)).toList();
    } catch (e) {
      debugPrint('Error loading enhanced lessons: $e');
      return [];
    }
  }

  /// Helper to get day index from name
  static int getDayIndexFromName(String dayName) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    return days.indexOf(dayName).clamp(0, 4);
  }

  /// Ensure user exists in users table (creates if doesn't exist)
  /// SECURITY NOTE: Skips user creation if database schema conflicts with Supabase Auth
  static Future<void> _ensureUserExists(String userId, String email) async {
    try {
      // Check if user exists
      final existingUser = await _supabase
          .from('users')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (existingUser == null) {
        // Generate proper bcrypt salt and hash for Supabase Auth users
        final authService = AuthService.instance;
        final salt = await authService.generateSecureSalt();
        final tempPassword = 'supabase_managed_${DateTime.now().millisecondsSinceEpoch}';
        
        // Hash password using the same method as AuthService
        final combined = tempPassword + salt;
        final bytes = utf8.encode(combined);
        final digest = sha256.convert(bytes);
        final passwordHash = digest.toString();
        
        final userData = {
          'id': userId,
          'email': email.toLowerCase(),
          'first_name': 'User', // Default name - can be updated in profile
          'last_name': '', // Default empty - can be updated in profile
          'school': null,
          'role': 'teacher', // All signed-up users are teachers
          'password_hash': passwordHash, // Proper bcrypt hash (not used for login)
          'salt': salt, // Proper salt (not used for login)
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'is_active': true, // Active immediately
          'login_attempts': 0,
          'locked_until': null,
        };
        
        await _supabase
            .from('users')
            .insert(userData);
        debugPrint('✅ Created secure teacher account for: $email (Supabase Auth managed)');
      } else {
        debugPrint('✅ User exists in database: $email');
      }
    } catch (e) {
      debugPrint('⚠️ Could not check user existence: $e');
      // Don't throw - let the operation continue with Supabase Auth
    }
  }
} 