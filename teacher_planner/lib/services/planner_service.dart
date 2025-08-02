// lib/services/planner_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

/// Service to handle planner creation and settings persistence
class PlannerService {
  static PlannerService? _instance;
  static PlannerService get instance => _instance ??= PlannerService._();
  
  PlannerService._();

  /// Check if user has an existing planner
  Future<bool> hasExistingPlanner(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      
      // Check if user has any weekly plans
      final weeklyPlansResponse = await supabase
          .from('weekly_plans')
          .select('id')
          .eq('user_id', userId)
          .limit(1);
      
      if (weeklyPlansResponse.isNotEmpty) {
        debugPrint('✅ User has existing weekly plans');
        return true;
      }

      // Check if user has any lessons
      final lessonsResponse = await supabase
          .from('lessons')
          .select('id')
          .eq('teacher_id', userId)
          .limit(1);
      
      if (lessonsResponse.isNotEmpty) {
        debugPrint('✅ User has existing lessons');
        return true;
      }

      // Check local storage for planner settings
      final prefs = await SharedPreferences.getInstance();
      final plannerSettings = prefs.getString('planner_settings_$userId');
      
      if (plannerSettings != null) {
        debugPrint('✅ User has existing planner settings in local storage');
        return true;
      }

      debugPrint('❌ User has no existing planner data');
      return false;
    } catch (e) {
      debugPrint('❌ Error checking existing planner: $e');
      return false;
    }
  }

  /// Create a new planner for the user
  Future<bool> createNewPlanner({
    required String userId,
    required int periods,
    required String schoolName,
    required String teacherRole,
    Map<String, dynamic>? additionalSettings,
  }) async {
    try {
      debugPrint('🔄 Creating new planner for user: $userId');
      
      // Save planner settings to local storage
      final prefs = await SharedPreferences.getInstance();
      final settings = {
        'periods': periods,
        'school_name': schoolName,
        'teacher_role': teacherRole,
        'created_at': DateTime.now().toIso8601String(),
        'last_updated': DateTime.now().toIso8601String(),
        ...?additionalSettings,
      };
      
      await prefs.setString('planner_settings_$userId', jsonEncode(settings));
      
      // Create initial weekly plan in database
      final supabase = Supabase.instance.client;
      final currentWeek = _getCurrentWeekStart();
      
             await supabase.from('weekly_plans').insert({
         'user_id': userId,
        'title': 'My First Weekly Plan',
        'week_start_date': currentWeek.toIso8601String().split('T')[0],
        'periods': periods,
        'plan_data': [],
        'metadata': {
          'school_name': schoolName,
          'teacher_role': teacherRole,
          'is_initial_plan': true,
          'created_at': DateTime.now().toIso8601String(),
        }
      });

      debugPrint('✅ New planner created successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating new planner: $e');
      return false;
    }
  }

  /// Load planner settings for the user
  Future<Map<String, dynamic>?> loadPlannerSettings(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('planner_settings_$userId');
      
      if (settingsJson != null) {
        final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
        debugPrint('✅ Loaded planner settings for user: $userId');
        return settings;
      }
      
      debugPrint('❌ No planner settings found for user: $userId');
      return null;
    } catch (e) {
      debugPrint('❌ Error loading planner settings: $e');
      return null;
    }
  }

  /// Update planner settings
  Future<bool> updatePlannerSettings(String userId, Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      settings['last_updated'] = DateTime.now().toIso8601String();
      
      await prefs.setString('planner_settings_$userId', jsonEncode(settings));
      debugPrint('✅ Planner settings updated successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating planner settings: $e');
      return false;
    }
  }

  /// Get current week start (Monday)
  DateTime _getCurrentWeekStart() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  /// Get user's planner statistics
  Future<Map<String, dynamic>> getPlannerStats(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      
             // Get weekly plans count
       final weeklyPlansResponse = await supabase
           .from('weekly_plans')
           .select('id')
           .eq('user_id', userId);
      
      // Get lessons count
      final lessonsResponse = await supabase
          .from('lessons')
          .select('id')
          .eq('teacher_id', userId);
      
      return {
        'weekly_plans_count': weeklyPlansResponse.length,
        'lessons_count': lessonsResponse.length,
        'last_activity': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('❌ Error getting planner stats: $e');
      return {
        'weekly_plans_count': 0,
        'lessons_count': 0,
        'last_activity': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Delete user's planner data (for testing or reset)
  Future<bool> deletePlannerData(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      
             // Delete weekly plans
       await supabase
           .from('weekly_plans')
           .delete()
           .eq('user_id', userId);
      
      // Delete lessons
      await supabase
          .from('lessons')
          .delete()
          .eq('teacher_id', userId);
      
      // Delete local settings
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('planner_settings_$userId');
      
      debugPrint('✅ Planner data deleted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting planner data: $e');
      return false;
    }
  }
} 