// lib/services/week_cache_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/weekly_plan_data.dart';
import 'lesson_database_service.dart';
import 'lazy_loading_service.dart';

/// High-performance caching service for weekly plan data
/// Provides instant loading with background refresh and prefetching
class WeekCacheService {
  static final WeekCacheService _instance = WeekCacheService._internal();
  static WeekCacheService get instance => _instance;
  WeekCacheService._internal();

  // Cache storage
  final Map<String, List<WeeklyPlanData>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, Completer<List<WeeklyPlanData>>> _loadingCompleters = {};
  
  // Cache configuration
  static const Duration _cacheExpiry = Duration(minutes: 5);
  static const int _maxCacheSize = 10; // Cache 10 weeks max
  
  /// Get cache key for a week
  String _getCacheKey(DateTime weekStart, String userId) {
    final dateStr = weekStart.toIso8601String().split('T')[0];
    return '${userId}_$dateStr';
  }
  
  /// Check if cached data is still valid
  bool _isCacheValid(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }
  
  /// Clean old cache entries
  void _cleanCache() {
    if (_cache.length <= _maxCacheSize) return;
    
    // Remove oldest entries
    final sortedEntries = _cacheTimestamps.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    
    final toRemove = sortedEntries.length - _maxCacheSize;
    for (int i = 0; i < toRemove; i++) {
      final key = sortedEntries[i].key;
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }
  
  /// Load week data with caching, lazy loading, and prefetching
  Future<List<WeeklyPlanData>> loadWeekData(
    DateTime weekStart,
    String userId, {
    bool forceFresh = false,
    bool useLazyLoading = true,
  }) async {
    final key = _getCacheKey(weekStart, userId);
    
          // Return cached data if valid and not forcing fresh
      if (!forceFresh && _isCacheValid(key)) {
        debugPrint('⚡ INSTANT Cache HIT for week: $weekStart');
        final cached = _cache[key]!;
        
        // Temporarily disable prefetching to prevent infinite loops
        // _prefetchAdjacentWeeks(weekStart, userId);
        
        return List.from(cached); // Return copy to prevent mutation
      }
    
    // Check if already loading this week
    if (_loadingCompleters.containsKey(key)) {
      debugPrint('⏳ Waiting for existing load: $weekStart');
      return await _loadingCompleters[key]!.future;
    }
    
    // Start new load
    debugPrint('🚀 Smart loading week: $weekStart');
    final completer = Completer<List<WeeklyPlanData>>();
    _loadingCompleters[key] = completer;
    
    try {
      List<WeeklyPlanData> data;
      
      if (useLazyLoading) {
        // Use lazy loading service for intelligent batching
        final lazyResult = await LazyLoadingService.instance.loadWeeklyPlans(
          startWeek: weekStart,
          weeksToLoad: 1,
          forceRefresh: forceFresh,
        );
        
        if (!lazyResult.isError && !lazyResult.isLoading) {
          data = lazyResult.data ?? [];
        } else {
          // Fallback to direct database load
          data = await LessonDatabaseService.loadCompleteWeeklyPlan(weekStart);
        }
      } else {
        // Direct database load
        data = await LessonDatabaseService.loadCompleteWeeklyPlan(weekStart);
      }
      
      // Cache the result
      _cache[key] = List.from(data);
      _cacheTimestamps[key] = DateTime.now();
      _cleanCache();
      
      if (data.isNotEmpty) {
        debugPrint('✅ Loaded ${data.length} items for week: $weekStart');
      }
      
      // Complete the future
      completer.complete(data);
      
      // Temporarily disable prefetching to prevent infinite loops
      // _prefetchAdjacentWeeks(weekStart, userId);
      
      return data;
    } catch (e) {
      debugPrint('❌ Error loading week data: $e');
      completer.completeError(e);
      rethrow;
    } finally {
      _loadingCompleters.remove(key);
    }
  }
  
  /// Prefetch adjacent weeks for instant navigation
  void _prefetchAdjacentWeeks(DateTime weekStart, String userId) {
    final previousWeek = weekStart.subtract(Duration(days: 7));
    final nextWeek = weekStart.add(Duration(days: 7));
    
    // Prefetch previous week
    final prevKey = _getCacheKey(previousWeek, userId);
    if (!_isCacheValid(prevKey) && !_loadingCompleters.containsKey(prevKey)) {
      Timer(Duration(milliseconds: 100), () {
        loadWeekData(previousWeek, userId).catchError((e) {
          debugPrint('🔮 Prefetch failed for previous week: $e');
        });
      });
    }
    
    // Prefetch next week
    final nextKey = _getCacheKey(nextWeek, userId);
    if (!_isCacheValid(nextKey) && !_loadingCompleters.containsKey(nextKey)) {
      Timer(Duration(milliseconds: 200), () {
        loadWeekData(nextWeek, userId).catchError((e) {
          debugPrint('🔮 Prefetch failed for next week: $e');
        });
      });
    }
  }
  
  /// Update cache when data is saved
  void updateCache(DateTime weekStart, String userId, List<WeeklyPlanData> data) {
    final key = _getCacheKey(weekStart, userId);
    _cache[key] = List.from(data);
    _cacheTimestamps[key] = DateTime.now();
    debugPrint('💾 Updated cache for week: $weekStart');
  }
  
  /// Clear cache for a specific week
  void clearWeekCache(DateTime weekStart, String userId) {
    final key = _getCacheKey(weekStart, userId);
    _cache.remove(key);
    _cacheTimestamps.remove(key);
    debugPrint('🗑️ Cleared cache for week: $weekStart');
  }
  
  /// Clear all cache
  void clearAllCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    _loadingCompleters.clear();
    debugPrint('🗑️ Cleared all cache');
  }
  
  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cached_weeks': _cache.length,
      'loading_weeks': _loadingCompleters.length,
      'cache_keys': _cache.keys.toList(),
    };
  }
}