// lib/services/auto_save_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'database_service.dart';
import 'auth_service.dart'; // Added import for AuthService

/// Auto-save service that automatically saves changes and provides manual save functionality
class AutoSaveService {
  static AutoSaveService? _instance;
  static AutoSaveService get instance => _instance ??= AutoSaveService._();
  
  AutoSaveService._();

  final DatabaseService _databaseService = DatabaseService.instance;
  final Map<String, Timer> _saveTimers = {};
  final Map<String, Map<String, dynamic>> _pendingChanges = {};
  
  // Auto-save delay (2 seconds)
  static const Duration _autoSaveDelay = Duration(seconds: 2);
  
  // Maximum pending changes to store in memory
  static const int _maxPendingChanges = 100;

  /// Auto-save data with debouncing
  Future<void> autoSave<T>({
    required String key,
    required Map<String, dynamic> data,
    required String userId,
    String? tableName,
  }) async {
    try {
      // Store pending changes
      _pendingChanges[key] = {
        'data': data,
        'userId': userId,
        'tableName': tableName,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Cancel existing timer for this key
      _saveTimers[key]?.cancel();

      // Create new timer for auto-save
      _saveTimers[key] = Timer(_autoSaveDelay, () async {
        await _performSave(key);
      });

      debugPrint('🔄 Auto-save scheduled for key: $key');
    } catch (e) {
      debugPrint('❌ Auto-save error: $e');
    }
  }

  /// Manual save (immediate)
  Future<bool> manualSave<T>({
    required String key,
    required Map<String, dynamic> data,
    required String userId,
    String? tableName,
  }) async {
    try {
      // Cancel any pending auto-save
      _saveTimers[key]?.cancel();

      // Store the data immediately
      _pendingChanges[key] = {
        'data': data,
        'userId': userId,
        'tableName': tableName,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Perform immediate save
      final success = await _performSave(key);
      
      if (success) {
        debugPrint('✅ Manual save successful for key: $key');
      } else {
        debugPrint('❌ Manual save failed for key: $key');
      }

      return success;
    } catch (e) {
      debugPrint('❌ Manual save error: $e');
      return false;
    }
  }

  /// Perform the actual save operation
  Future<bool> _performSave(String key) async {
    try {
      final change = _pendingChanges[key];
      if (change == null) return false;

      final data = change['data'] as Map<String, dynamic>;
      final userId = change['userId'] as String;
      final tableName = change['tableName'] as String?;

      bool success = false;

      // Save to database if table name is provided
      if (tableName != null) {
        success = await _saveToDatabase(tableName, data, userId);
      }

      // Always save to local storage as backup
      await _saveToLocalStorage(key, data);

      // Remove from pending changes if successful
      if (success) {
        _pendingChanges.remove(key);
      }

      return success;
    } catch (e) {
      debugPrint('❌ Save operation error: $e');
      return false;
    }
  }

  /// Save to database
  Future<bool> _saveToDatabase(String tableName, Map<String, dynamic> data, String userId) async {
    try {
      // Ensure user is authenticated
      final isAuthenticated = await AuthService.instance.ensureAuthenticated();
      if (!isAuthenticated) {
        debugPrint('❌ User not authenticated, cannot save to database');
        return false;
      }

      // Add user ID to data
      final dataWithUserId = {...data, 'user_id': userId};

      // Use Supabase instance directly
      final supabase = Supabase.instance.client;

      // Check if record exists (update) or create new
      if (data['id'] != null) {
        // Update existing record
        await supabase
            .from(tableName)
            .update(dataWithUserId)
            .eq('id', data['id']);
      } else {
        // Insert new record
        await supabase
            .from(tableName)
            .insert(dataWithUserId);
      }

      debugPrint('✅ Database save successful for table: $tableName');
      return true;
    } catch (e) {
      debugPrint('❌ Database save error: $e');
      return false;
    }
  }

  /// Save to local storage as backup
  Future<void> _saveToLocalStorage(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auto_save_$key', jsonEncode(data));
      debugPrint('💾 Local backup saved for key: $key');
    } catch (e) {
      debugPrint('❌ Local storage save error: $e');
    }
  }

  /// Load from local storage
  Future<Map<String, dynamic>?> loadFromLocalStorage(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('auto_save_$key');
      if (data != null) {
        return jsonDecode(data) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Local storage load error: $e');
      return null;
    }
  }

  /// Get save status for a key
  bool hasPendingChanges(String key) {
    return _pendingChanges.containsKey(key);
  }

  /// Get all pending changes
  Map<String, Map<String, dynamic>> getPendingChanges() {
    return Map.from(_pendingChanges);
  }

  /// Clear pending changes for a key
  void clearPendingChanges(String key) {
    _saveTimers[key]?.cancel();
    _pendingChanges.remove(key);
  }

  /// Clear all pending changes
  void clearAllPendingChanges() {
    for (final timer in _saveTimers.values) {
      timer.cancel();
    }
    _saveTimers.clear();
    _pendingChanges.clear();
  }

  /// Save weekly plan with auto-save
  Future<void> saveWeeklyPlan({
    required Map<String, dynamic> planData,
    required String userId,
  }) async {
    await autoSave(
      key: 'weekly_plan_${planData['id'] ?? DateTime.now().millisecondsSinceEpoch}',
      data: planData,
      userId: userId,
      tableName: 'weekly_plans',
    );
  }

  /// Save daily detail with auto-save
  Future<void> saveDailyDetail({
    required Map<String, dynamic> detailData,
    required String userId,
  }) async {
    await autoSave(
      key: 'daily_detail_${detailData['id'] ?? DateTime.now().millisecondsSinceEpoch}',
      data: detailData,
      userId: userId,
      tableName: 'daily_details',
    );
  }

  /// Save curriculum with auto-save
  Future<void> saveCurriculum({
    required Map<String, dynamic> curriculumData,
    required String userId,
  }) async {
    await autoSave(
      key: 'curriculum_${curriculumData['id'] ?? DateTime.now().millisecondsSinceEpoch}',
      data: curriculumData,
      userId: userId,
      tableName: 'curriculum',
    );
  }

  /// Dispose resources
  void dispose() {
    clearAllPendingChanges();
  }
} 