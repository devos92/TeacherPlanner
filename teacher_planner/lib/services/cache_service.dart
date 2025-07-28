// lib/services/cache_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/weekly_plan_data.dart';
import '../models/curriculum_models.dart';
import '../models/term_models.dart';
import '../models/long_term_plan_models.dart';

/// Comprehensive cache service with multi-level caching strategy
class CacheService {
  static CacheService? _instance;
  static CacheService get instance => _instance ??= CacheService._();
  
  CacheService._();

  // In-memory caches with LRU eviction
  final Map<String, CacheEntry> _memoryCache = {};
  final Map<String, CacheEntry> _imageCache = {};
  final Map<String, CacheEntry> _curriculumCache = {};
  
  // Cache configuration
  static const int maxMemoryCacheSize = 100;
  static const int maxImageCacheSize = 50;
  static const int maxCurriculumCacheSize = 200;
  static const Duration defaultCacheExpiry = Duration(hours: 24);
  static const Duration imageCacheExpiry = Duration(days: 7);
  static const Duration curriculumCacheExpiry = Duration(days: 30);

  SharedPreferences? _prefs;
  Directory? _cacheDir;

  /// Initialize the cache service
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _cacheDir = await getTemporaryDirectory();
      
      // Clean up expired cache entries on startup
      await _cleanupExpiredEntries();
      
      debugPrint('CacheService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing CacheService: $e');
    }
  }

  /// Generic cache operations
  Future<T?> get<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    try {
      // Check memory cache first
      final memoryEntry = _getFromMemoryCache(key);
      if (memoryEntry != null && !memoryEntry.isExpired) {
        _updateCacheAccess(key);
        return fromJson(memoryEntry.data);
      }

      // Check persistent cache
      final persistentData = await _getFromPersistentCache(key);
      if (persistentData != null) {
        // Store in memory cache for faster access
        _setInMemoryCache(key, persistentData, defaultCacheExpiry);
        return fromJson(persistentData);
      }

      return null;
    } catch (e) {
      debugPrint('Error getting cached data for key $key: $e');
      return null;
    }
  }

  Future<void> set<T>(String key, T data, {Duration? expiry}) async {
    try {
      final jsonData = _toJson(data);
      final cacheExpiry = expiry ?? defaultCacheExpiry;
      
      // Store in memory cache
      _setInMemoryCache(key, jsonData, cacheExpiry);
      
      // Store in persistent cache
      await _setInPersistentCache(key, jsonData, cacheExpiry);
      
    } catch (e) {
      debugPrint('Error setting cache for key $key: $e');
    }
  }

  /// Weekly plan specific caching
  Future<List<WeeklyPlanData>?> getWeeklyPlan(DateTime weekStart) async {
    final key = 'weekly_plan_${_getWeekKey(weekStart)}';
    final data = await get<List<WeeklyPlanData>>(
      key, 
      (json) => (json['data'] as List).map((item) => WeeklyPlanData.fromJson(item)).toList(),
    );
    return data;
  }

  Future<void> setWeeklyPlan(DateTime weekStart, List<WeeklyPlanData> planData) async {
    final key = 'weekly_plan_${_getWeekKey(weekStart)}';
    await set(key, {'data': planData.map((e) => e.toJson()).toList()});
  }

  /// Enhanced events caching
  Future<List<EnhancedEventBlock>?> getDayEvents(String day, int dayIndex) async {
    final key = 'day_events_${day.toLowerCase()}_$dayIndex';
    final data = await get<List<EnhancedEventBlock>>(
      key,
      (json) => (json['events'] as List).map((item) => EnhancedEventBlock.fromJson(item)).toList(),
    );
    return data;
  }

  Future<void> setDayEvents(String day, int dayIndex, List<EnhancedEventBlock> events) async {
    final key = 'day_events_${day.toLowerCase()}_$dayIndex';
    await set(key, {'events': events.map((e) => e.toJson()).toList()});
  }

  /// Curriculum data caching with specialized handling
  Future<List<CurriculumData>?> getCurriculumData(String subject, String yearLevel) async {
    final key = 'curriculum_${subject}_$yearLevel';
    
    // Check specialized curriculum cache first
    final entry = _curriculumCache[key];
    if (entry != null && !entry.isExpired) {
      _updateCurriculumCacheAccess(key);
      return (entry.data['curriculum'] as List)
          .map((item) => CurriculumData.fromJson(item))
          .toList();
    }

    // Fallback to persistent cache
    final data = await get<List<CurriculumData>>(
      key,
      (json) => (json['curriculum'] as List).map((item) => CurriculumData.fromJson(item)).toList(),
    );

    if (data != null) {
      _setCurriculumCache(key, {'curriculum': data.map((e) => e.toJson()).toList()});
    }

    return data;
  }

  Future<void> setCurriculumData(String subject, String yearLevel, List<CurriculumData> data) async {
    final key = 'curriculum_${subject}_$yearLevel';
    final jsonData = {'curriculum': data.map((e) => e.toJson()).toList()};
    
    // Store in specialized curriculum cache
    _setCurriculumCache(key, jsonData);
    
    // Store in persistent cache with longer expiry
    await set(key, jsonData, expiry: curriculumCacheExpiry);
  }

  /// Term events caching
  Future<List<TermEvent>?> getTermEvents(String termId) async {
    final key = 'term_events_$termId';
    return await get<List<TermEvent>>(
      key,
      (json) => (json['events'] as List).map((item) => TermEvent.fromJson(item)).toList(),
    );
  }

  Future<void> setTermEvents(String termId, List<TermEvent> events) async {
    final key = 'term_events_$termId';
    await set(key, {'events': events.map((e) => e.toJson()).toList()});
  }

  /// Long-term plans caching
  Future<List<LongTermPlan>?> getLongTermPlans() async {
    const key = 'long_term_plans';
    return await get<List<LongTermPlan>>(
      key,
      (json) => (json['plans'] as List).map((item) => LongTermPlan.fromJson(item)).toList(),
    );
  }

  Future<void> setLongTermPlans(List<LongTermPlan> plans) async {
    const key = 'long_term_plans';
    await set(key, {'plans': plans.map((e) => e.toJson()).toList()});
  }

  /// Image caching with file system storage
  Future<String?> getCachedImagePath(String imageUrl) async {
    final key = 'image_${_hashString(imageUrl)}';
    
    // Check memory cache
    final entry = _imageCache[key];
    if (entry != null && !entry.isExpired) {
      final filePath = entry.data['path'] as String;
      if (await File(filePath).exists()) {
        _updateImageCacheAccess(key);
        return filePath;
      }
    }

    return null;
  }

  Future<void> cacheImage(String imageUrl, String localPath) async {
    final key = 'image_${_hashString(imageUrl)}';
    _setImageCache(key, {'path': localPath, 'url': imageUrl});
  }

  /// Cache invalidation
  Future<void> invalidateWeeklyPlan(DateTime weekStart) async {
    final key = 'weekly_plan_${_getWeekKey(weekStart)}';
    await _removeFromCache(key);
  }

  Future<void> invalidateDayEvents(String day, int dayIndex) async {
    final key = 'day_events_${day.toLowerCase()}_$dayIndex';
    await _removeFromCache(key);
  }

  Future<void> invalidateCurriculumData(String subject, String yearLevel) async {
    final key = 'curriculum_${subject}_$yearLevel';
    await _removeFromCache(key);
    _curriculumCache.remove(key);
  }

  Future<void> invalidateTermEvents(String termId) async {
    final key = 'term_events_$termId';
    await _removeFromCache(key);
  }

  Future<void> invalidateAll() async {
    _memoryCache.clear();
    _imageCache.clear();
    _curriculumCache.clear();
    await _prefs?.clear();
  }

  /// Cache statistics for debugging
  Map<String, dynamic> getCacheStats() {
    return {
      'memory_cache_size': _memoryCache.length,
      'image_cache_size': _imageCache.length,
      'curriculum_cache_size': _curriculumCache.length,
      'memory_cache_hit_ratio': _calculateHitRatio(_memoryCache),
      'image_cache_hit_ratio': _calculateHitRatio(_imageCache),
      'curriculum_cache_hit_ratio': _calculateHitRatio(_curriculumCache),
    };
  }

  /// Private helper methods
  CacheEntry? _getFromMemoryCache(String key) {
    return _memoryCache[key];
  }

  void _setInMemoryCache(String key, Map<String, dynamic> data, Duration expiry) {
    // Implement LRU eviction
    if (_memoryCache.length >= maxMemoryCacheSize) {
      _evictLRU(_memoryCache);
    }
    
    _memoryCache[key] = CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(expiry),
      accessCount: 1,
      lastAccessed: DateTime.now(),
    );
  }

  void _setCurriculumCache(String key, Map<String, dynamic> data) {
    if (_curriculumCache.length >= maxCurriculumCacheSize) {
      _evictLRU(_curriculumCache);
    }
    
    _curriculumCache[key] = CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(curriculumCacheExpiry),
      accessCount: 1,
      lastAccessed: DateTime.now(),
    );
  }

  void _setImageCache(String key, Map<String, dynamic> data) {
    if (_imageCache.length >= maxImageCacheSize) {
      _evictLRU(_imageCache);
    }
    
    _imageCache[key] = CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(imageCacheExpiry),
      accessCount: 1,
      lastAccessed: DateTime.now(),
    );
  }

  void _updateCacheAccess(String key) {
    final entry = _memoryCache[key];
    if (entry != null) {
      entry.accessCount++;
      entry.lastAccessed = DateTime.now();
    }
  }

  void _updateImageCacheAccess(String key) {
    final entry = _imageCache[key];
    if (entry != null) {
      entry.accessCount++;
      entry.lastAccessed = DateTime.now();
    }
  }

  void _updateCurriculumCacheAccess(String key) {
    final entry = _curriculumCache[key];
    if (entry != null) {
      entry.accessCount++;
      entry.lastAccessed = DateTime.now();
    }
  }

  Future<Map<String, dynamic>?> _getFromPersistentCache(String key) async {
    try {
      final jsonString = _prefs?.getString('cache_$key');
      if (jsonString != null) {
        final cacheData = json.decode(jsonString) as Map<String, dynamic>;
        final expiresAt = DateTime.parse(cacheData['expiresAt']);
        
        if (DateTime.now().isBefore(expiresAt)) {
          return cacheData['data'] as Map<String, dynamic>;
        } else {
          // Remove expired entry
          await _prefs?.remove('cache_$key');
        }
      }
    } catch (e) {
      debugPrint('Error reading persistent cache for key $key: $e');
    }
    return null;
  }

  Future<void> _setInPersistentCache(String key, Map<String, dynamic> data, Duration expiry) async {
    try {
      final cacheData = {
        'data': data,
        'expiresAt': DateTime.now().add(expiry).toIso8601String(),
      };
      await _prefs?.setString('cache_$key', json.encode(cacheData));
    } catch (e) {
      debugPrint('Error writing persistent cache for key $key: $e');
    }
  }

  Future<void> _removeFromCache(String key) async {
    _memoryCache.remove(key);
    _imageCache.remove(key);
    _curriculumCache.remove(key);
    await _prefs?.remove('cache_$key');
  }

  void _evictLRU(Map<String, CacheEntry> cache) {
    if (cache.isEmpty) return;
    
    String? lruKey;
    DateTime? oldestAccess;
    
    cache.forEach((key, entry) {
      if (oldestAccess == null || entry.lastAccessed.isBefore(oldestAccess!)) {
        oldestAccess = entry.lastAccessed;
        lruKey = key;
      }
    });
    
    if (lruKey != null) {
      cache.remove(lruKey);
    }
  }

  Future<void> _cleanupExpiredEntries() async {
    try {
      final keys = _prefs?.getKeys() ?? <String>{};
      final expiredKeys = <String>[];
      
      for (final key in keys) {
        if (key.startsWith('cache_')) {
          final jsonString = _prefs?.getString(key);
          if (jsonString != null) {
            try {
              final cacheData = json.decode(jsonString) as Map<String, dynamic>;
              final expiresAt = DateTime.parse(cacheData['expiresAt']);
              
              if (DateTime.now().isAfter(expiresAt)) {
                expiredKeys.add(key);
              }
            } catch (e) {
              // Invalid cache entry, mark for deletion
              expiredKeys.add(key);
            }
          }
        }
      }
      
      // Remove expired entries
      for (final key in expiredKeys) {
        await _prefs?.remove(key);
      }
      
      debugPrint('Cleaned up ${expiredKeys.length} expired cache entries');
    } catch (e) {
      debugPrint('Error during cache cleanup: $e');
    }
  }

  Map<String, dynamic> _toJson(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is List) {
      return {'list': data};
    } else {
      return {'value': data};
    }
  }

  String _getWeekKey(DateTime weekStart) {
    return '${weekStart.year}_${weekStart.month}_${weekStart.day}';
  }

  String _hashString(String input) {
    return input.hashCode.abs().toString();
  }

  double _calculateHitRatio(Map<String, CacheEntry> cache) {
    if (cache.isEmpty) return 0.0;
    
    final totalAccesses = cache.values.fold<int>(0, (sum, entry) => sum + entry.accessCount);
    final totalEntries = cache.length;
    
    return totalEntries > 0 ? totalAccesses / totalEntries : 0.0;
  }
}

/// Cache entry with metadata for LRU eviction
class CacheEntry {
  final Map<String, dynamic> data;
  final DateTime expiresAt;
  int accessCount;
  DateTime lastAccessed;

  CacheEntry({
    required this.data,
    required this.expiresAt,
    required this.accessCount,
    required this.lastAccessed,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Cache configuration for different data types
class CacheConfig {
  static const Map<String, Duration> expiries = {
    'weekly_plans': Duration(hours: 12),
    'day_events': Duration(hours: 6),
    'curriculum': Duration(days: 30),
    'term_events': Duration(days: 7),
    'long_term_plans': Duration(hours: 24),
    'images': Duration(days: 7),
    'user_preferences': Duration(days: 365),
  };

  static Duration getExpiry(String dataType) {
    return expiries[dataType] ?? Duration(hours: 24);
  }
} 