// lib/services/lazy_loading_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'cache_service.dart';
import '../models/weekly_plan_data.dart';
import '../models/curriculum_models.dart';
import '../models/term_models.dart';
import '../models/long_term_plan_models.dart';

/// Comprehensive lazy loading service with pagination and virtual scrolling
class LazyLoadingService {
  static LazyLoadingService? _instance;
  static LazyLoadingService get instance => _instance ??= LazyLoadingService._();
  
  LazyLoadingService._();

  final CacheService _cache = CacheService.instance;
  
  // Loading states for different data types
  final Map<String, bool> _loadingStates = {};
  final Map<String, StreamController<bool>> _loadingControllers = {};
  
  // Pagination state
  final Map<String, PaginationState> _paginationStates = {};
  
  // Preloading strategies
  static const int defaultPageSize = 20;
  static const int maxCachePages = 5;
  static const int preloadThreshold = 5; // Items from end to trigger preload

  /// Initialize the lazy loading service
  Future<void> initialize() async {
    await _cache.initialize();
    debugPrint('LazyLoadingService initialized');
  }

  /// Weekly plan lazy loading with week-based pagination
  Future<WeeklyPlanResult> loadWeeklyPlans({
    required DateTime startWeek,
    int weeksToLoad = 4,
    bool forceRefresh = false,
  }) async {
    final key = 'weekly_plans_${_getWeekKey(startWeek)}_$weeksToLoad';
    
    if (_isLoading(key)) {
      return WeeklyPlanResult.loading();
    }

    _setLoading(key, true);

    try {
      final result = <WeeklyPlanData>[];
      final cachedWeeks = <DateTime>[];
      final uncachedWeeks = <DateTime>[];

      // Check cache for each week
      for (int i = 0; i < weeksToLoad; i++) {
        final weekStart = startWeek.add(Duration(days: i * 7));
        
        if (!forceRefresh) {
          final cachedData = await _cache.getWeeklyPlan(weekStart);
          if (cachedData != null) {
            result.addAll(cachedData);
            cachedWeeks.add(weekStart);
            continue;
          }
        }
        
        uncachedWeeks.add(weekStart);
      }

      // Load uncached weeks from database (when integrated)
      if (uncachedWeeks.isNotEmpty) {
        final freshData = await _loadWeeklyPlansFromDatabase(uncachedWeeks);
        result.addAll(freshData);
        
        // Cache the fresh data
        for (final weekStart in uncachedWeeks) {
          final weekData = freshData.where((plan) {
            if (plan.date == null) return false;
            final planWeek = _getWeekStart(plan.date!);
            return planWeek.isAtSameMomentAs(weekStart);
          }).toList();
          
          await _cache.setWeeklyPlan(weekStart, weekData);
        }
      }

      return WeeklyPlanResult.success(
        result,
        fromCache: cachedWeeks.length > 0,
        hasMore: uncachedWeeks.length > 0,
      );

    } catch (e) {
      debugPrint('Error loading weekly plans: $e');
      return WeeklyPlanResult.error(e.toString());
    } finally {
      _setLoading(key, false);
    }
  }

  /// Curriculum data lazy loading with subject-based pagination
  Future<CurriculumResult> loadCurriculumData({
    required String subject,
    required String yearLevel,
    int page = 0,
    int pageSize = defaultPageSize,
    bool forceRefresh = false,
  }) async {
    final key = 'curriculum_${subject}_${yearLevel}_$page';
    
    if (_isLoading(key)) {
      return CurriculumResult.loading();
    }

    _setLoading(key, true);

    try {
      // Check cache first
      if (!forceRefresh) {
        final cachedData = await _cache.getCurriculumData(subject, yearLevel);
        if (cachedData != null) {
          final paginatedData = _paginateData(cachedData, page, pageSize);
          return CurriculumResult.success(
            paginatedData,
            hasMore: (page + 1) * pageSize < cachedData.length,
            fromCache: true,
          );
        }
      }

      // Load from database (when integrated)
      final allData = await _loadCurriculumFromDatabase(subject, yearLevel);
      await _cache.setCurriculumData(subject, yearLevel, allData);
      
      final paginatedData = _paginateData(allData, page, pageSize);
      return CurriculumResult.success(
        paginatedData,
        hasMore: (page + 1) * pageSize < allData.length,
        fromCache: false,
      );

    } catch (e) {
      debugPrint('Error loading curriculum data: $e');
      return CurriculumResult.error(e.toString());
    } finally {
      _setLoading(key, false);
    }
  }

  /// Enhanced events lazy loading with day-based pagination
  Future<EventsResult> loadDayEvents({
    required String day,
    required int dayIndex,
    DateTime? weekStart,
    bool forceRefresh = false,
  }) async {
    final key = 'day_events_${day}_$dayIndex';
    
    if (_isLoading(key)) {
      return EventsResult.loading();
    }

    _setLoading(key, true);

    try {
      // Check cache first
      if (!forceRefresh) {
        final cachedData = await _cache.getDayEvents(day, dayIndex);
        if (cachedData != null) {
          return EventsResult.success(
            cachedData,
            fromCache: true,
          );
        }
      }

      // Load from database (when integrated)
      final freshData = await _loadDayEventsFromDatabase(day, dayIndex, weekStart);
      await _cache.setDayEvents(day, dayIndex, freshData);
      
      return EventsResult.success(
        freshData,
        fromCache: false,
      );

    } catch (e) {
      debugPrint('Error loading day events: $e');
      return EventsResult.error(e.toString());
    } finally {
      _setLoading(key, false);
    }
  }

  /// Term events lazy loading with pagination
  Future<TermEventsResult> loadTermEvents({
    required String termId,
    int page = 0,
    int pageSize = defaultPageSize,
    bool forceRefresh = false,
  }) async {
    final key = 'term_events_${termId}_$page';
    
    if (_isLoading(key)) {
      return TermEventsResult.loading();
    }

    _setLoading(key, true);

    try {
      // Check cache first
      if (!forceRefresh) {
        final cachedData = await _cache.getTermEvents(termId);
        if (cachedData != null) {
          final paginatedData = _paginateData(cachedData, page, pageSize);
          return TermEventsResult.success(
            paginatedData,
            hasMore: (page + 1) * pageSize < cachedData.length,
            fromCache: true,
          );
        }
      }

      // Load from database (when integrated)
      final allData = await _loadTermEventsFromDatabase(termId);
      await _cache.setTermEvents(termId, allData);
      
      final paginatedData = _paginateData(allData, page, pageSize);
      return TermEventsResult.success(
        paginatedData,
        hasMore: (page + 1) * pageSize < allData.length,
        fromCache: false,
      );

    } catch (e) {
      debugPrint('Error loading term events: $e');
      return TermEventsResult.error(e.toString());
    } finally {
      _setLoading(key, false);
    }
  }

  /// Long-term plans lazy loading with pagination
  Future<LongTermPlansResult> loadLongTermPlans({
    int page = 0,
    int pageSize = defaultPageSize,
    String? subject,
    String? yearLevel,
    bool forceRefresh = false,
  }) async {
    final key = 'long_term_plans_${subject ?? 'all'}_${yearLevel ?? 'all'}_$page';
    
    if (_isLoading(key)) {
      return LongTermPlansResult.loading();
    }

    _setLoading(key, true);

    try {
      // Check cache first
      if (!forceRefresh) {
        final cachedData = await _cache.getLongTermPlans();
        if (cachedData != null) {
          final filteredData = _filterLongTermPlans(cachedData, subject, yearLevel);
          final paginatedData = _paginateData(filteredData, page, pageSize);
          
          return LongTermPlansResult.success(
            paginatedData,
            hasMore: (page + 1) * pageSize < filteredData.length,
            fromCache: true,
          );
        }
      }

      // Load from database (when integrated)
      final allData = await _loadLongTermPlansFromDatabase(subject, yearLevel);
      await _cache.setLongTermPlans(allData);
      
      final filteredData = _filterLongTermPlans(allData, subject, yearLevel);
      final paginatedData = _paginateData(filteredData, page, pageSize);
      
      return LongTermPlansResult.success(
        paginatedData,
        hasMore: (page + 1) * pageSize < filteredData.length,
        fromCache: false,
      );

    } catch (e) {
      debugPrint('Error loading long-term plans: $e');
      return LongTermPlansResult.error(e.toString());
    } finally {
      _setLoading(key, false);
    }
  }

  /// Preload next page of data
  Future<void> preloadNextPage<T>({
    required String dataType,
    required Map<String, dynamic> params,
    required int currentPage,
  }) async {
    final nextPage = currentPage + 1;
    final preloadKey = '${dataType}_preload_$nextPage';
    
    // Don't preload if already loading or if we've reached cache limit
    if (_isLoading(preloadKey) || nextPage > maxCachePages) {
      return;
    }

    switch (dataType) {
      case 'curriculum':
        await loadCurriculumData(
          subject: params['subject'],
          yearLevel: params['yearLevel'],
          page: nextPage,
          pageSize: params['pageSize'] ?? defaultPageSize,
        );
        break;
      case 'term_events':
        await loadTermEvents(
          termId: params['termId'],
          page: nextPage,
          pageSize: params['pageSize'] ?? defaultPageSize,
        );
        break;
      case 'long_term_plans':
        await loadLongTermPlans(
          page: nextPage,
          pageSize: params['pageSize'] ?? defaultPageSize,
          subject: params['subject'],
          yearLevel: params['yearLevel'],
        );
        break;
    }
  }

  /// Image lazy loading with caching
  Future<String?> loadImage(String imageUrl, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedPath = await _cache.getCachedImagePath(imageUrl);
      if (cachedPath != null) {
        return cachedPath;
      }
    }

    // Download and cache image (when integrated with network)
    final localPath = await _downloadAndCacheImage(imageUrl);
    return localPath;
  }

  /// Check if data should be preloaded based on scroll position
  bool shouldPreloadNextPage(int currentIndex, int totalLoaded, int threshold) {
    return currentIndex >= totalLoaded - threshold;
  }

  /// Loading state streams
  Stream<bool> getLoadingStream(String key) {
    _loadingControllers[key] ??= StreamController<bool>.broadcast();
    return _loadingControllers[key]!.stream;
  }

  /// Cache invalidation for data updates
  Future<void> invalidateCache({
    String? dataType,
    Map<String, dynamic>? params,
  }) async {
    if (dataType == null) {
      await _cache.invalidateAll();
      return;
    }

    switch (dataType) {
      case 'weekly_plans':
        if (params?['weekStart'] != null) {
          await _cache.invalidateWeeklyPlan(params!['weekStart']);
        }
        break;
      case 'day_events':
        if (params?['day'] != null && params?['dayIndex'] != null) {
          await _cache.invalidateDayEvents(params!['day'], params['dayIndex']);
        }
        break;
      case 'curriculum':
        if (params?['subject'] != null && params?['yearLevel'] != null) {
          await _cache.invalidateCurriculumData(params!['subject'], params['yearLevel']);
        }
        break;
      case 'term_events':
        if (params?['termId'] != null) {
          await _cache.invalidateTermEvents(params!['termId']);
        }
        break;
    }
  }

  /// Private helper methods
  bool _isLoading(String key) {
    return _loadingStates[key] ?? false;
  }

  void _setLoading(String key, bool loading) {
    _loadingStates[key] = loading;
    _loadingControllers[key]?.add(loading);
  }

  List<T> _paginateData<T>(List<T> data, int page, int pageSize) {
    final startIndex = page * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, data.length);
    
    if (startIndex >= data.length) {
      return [];
    }
    
    return data.sublist(startIndex, endIndex);
  }

  List<LongTermPlan> _filterLongTermPlans(
    List<LongTermPlan> plans,
    String? subject,
    String? yearLevel,
  ) {
    return plans.where((plan) {
      if (subject != null && plan.subject != subject) return false;
      if (yearLevel != null && plan.yearLevel != yearLevel) return false;
      return true;
    }).toList();
  }

  String _getWeekKey(DateTime date) {
    final weekStart = _getWeekStart(date);
    return '${weekStart.year}_${weekStart.month}_${weekStart.day}';
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  /// Database integration methods (to be implemented when database is connected)
  Future<List<WeeklyPlanData>> _loadWeeklyPlansFromDatabase(List<DateTime> weeks) async {
    // TODO: Implement actual database loading
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
    
    // For now, return empty list (this will be replaced with actual database calls)
    return [];
  }

  Future<List<CurriculumData>> _loadCurriculumFromDatabase(String subject, String yearLevel) async {
    // TODO: Implement database loading
    await Future.delayed(Duration(milliseconds: 300)); // Simulate network delay
    return []; // Return empty for now
  }

  Future<List<EnhancedEventBlock>> _loadDayEventsFromDatabase(String day, int dayIndex, DateTime? weekStart) async {
    // TODO: Implement database loading
    await Future.delayed(Duration(milliseconds: 200)); // Simulate network delay
    return []; // Return empty for now
  }

  Future<List<TermEvent>> _loadTermEventsFromDatabase(String termId) async {
    // TODO: Implement database loading
    await Future.delayed(Duration(milliseconds: 300)); // Simulate network delay
    return []; // Return empty for now
  }

  Future<List<LongTermPlan>> _loadLongTermPlansFromDatabase(String? subject, String? yearLevel) async {
    // TODO: Implement database loading
    await Future.delayed(Duration(milliseconds: 400)); // Simulate network delay
    return []; // Return empty for now
  }

  Future<String?> _downloadAndCacheImage(String imageUrl) async {
    // TODO: Implement image downloading and caching
    await Future.delayed(Duration(milliseconds: 800)); // Simulate download
    return null; // Return null for now
  }

  /// Dispose resources
  void dispose() {
    for (final controller in _loadingControllers.values) {
      controller.close();
    }
    _loadingControllers.clear();
    _loadingStates.clear();
    _paginationStates.clear();
  }
}

/// Pagination state tracking
class PaginationState {
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final bool hasMore;
  final bool isLoading;

  PaginationState({
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.hasMore,
    required this.isLoading,
  });

  PaginationState copyWith({
    int? currentPage,
    int? pageSize,
    int? totalCount,
    bool? hasMore,
    bool? isLoading,
  }) {
    return PaginationState(
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Result classes for lazy loading operations
abstract class LazyLoadResult<T> {
  final bool isLoading;
  final bool isError;
  final String? error;
  final T? data;
  final bool fromCache;
  final bool hasMore; // Add hasMore property

  const LazyLoadResult({
    required this.isLoading,
    required this.isError,
    this.error,
    this.data,
    required this.fromCache,
    required this.hasMore, // Add to constructor
  });
}

class WeeklyPlanResult extends LazyLoadResult<List<WeeklyPlanData>> {
  const WeeklyPlanResult({
    required super.isLoading,
    required super.isError,
    super.error,
    super.data,
    required super.fromCache,
    required super.hasMore, // Add to constructor
  });

  factory WeeklyPlanResult.loading() => const WeeklyPlanResult(
    isLoading: true,
    isError: false,
    fromCache: false,
    hasMore: false,
  );

  factory WeeklyPlanResult.error(String error) => WeeklyPlanResult(
    isLoading: false,
    isError: true,
    error: error,
    fromCache: false,
    hasMore: false,
  );

  factory WeeklyPlanResult.success(List<WeeklyPlanData> data, {bool fromCache = false, bool hasMore = false}) => WeeklyPlanResult(
    isLoading: false,
    isError: false,
    data: data,
    fromCache: fromCache,
    hasMore: hasMore,
  );
}

class CurriculumResult extends LazyLoadResult<List<CurriculumData>> {
  const CurriculumResult({
    required super.isLoading,
    required super.isError,
    super.error,
    super.data,
    required super.fromCache,
    required super.hasMore, // Add to constructor
  });

  factory CurriculumResult.loading() => const CurriculumResult(
    isLoading: true,
    isError: false,
    fromCache: false,
    hasMore: false,
  );

  factory CurriculumResult.error(String error) => CurriculumResult(
    isLoading: false,
    isError: true,
    error: error,
    fromCache: false,
    hasMore: false,
  );

  factory CurriculumResult.success(List<CurriculumData> data, {bool fromCache = false, bool hasMore = false}) => CurriculumResult(
    isLoading: false,
    isError: false,
    data: data,
    fromCache: fromCache,
    hasMore: hasMore,
  );
}

class EventsResult extends LazyLoadResult<List<EnhancedEventBlock>> {
  const EventsResult({
    required super.isLoading,
    required super.isError,
    super.error,
    super.data,
    required super.fromCache,
    required super.hasMore, // Add to constructor
  });

  factory EventsResult.loading() => const EventsResult(
    isLoading: true,
    isError: false,
    fromCache: false,
    hasMore: false,
  );

  factory EventsResult.error(String error) => EventsResult(
    isLoading: false,
    isError: true,
    error: error,
    fromCache: false,
    hasMore: false,
  );

  factory EventsResult.success(List<EnhancedEventBlock> data, {bool fromCache = false, bool hasMore = false}) => EventsResult(
    isLoading: false,
    isError: false,
    data: data,
    fromCache: fromCache,
    hasMore: hasMore,
  );
}

class TermEventsResult extends LazyLoadResult<List<TermEvent>> {
  const TermEventsResult({
    required super.isLoading,
    required super.isError,
    super.error,
    super.data,
    required super.fromCache,
    required super.hasMore, // Add to constructor
  });

  factory TermEventsResult.loading() => const TermEventsResult(
    isLoading: true,
    isError: false,
    fromCache: false,
    hasMore: false,
  );

  factory TermEventsResult.error(String error) => TermEventsResult(
    isLoading: false,
    isError: true,
    error: error,
    fromCache: false,
    hasMore: false,
  );

  factory TermEventsResult.success(List<TermEvent> data, {bool fromCache = false, bool hasMore = false}) => TermEventsResult(
    isLoading: false,
    isError: false,
    data: data,
    fromCache: fromCache,
    hasMore: hasMore,
  );
}

class LongTermPlansResult extends LazyLoadResult<List<LongTermPlan>> {
  const LongTermPlansResult({
    required super.isLoading,
    required super.isError,
    super.error,
    super.data,
    required super.fromCache,
    required super.hasMore, // Add to constructor
  });

  factory LongTermPlansResult.loading() => const LongTermPlansResult(
    isLoading: true,
    isError: false,
    fromCache: false,
    hasMore: false,
  );

  factory LongTermPlansResult.error(String error) => LongTermPlansResult(
    isLoading: false,
    isError: true,
    error: error,
    fromCache: false,
    hasMore: false,
  );

  factory LongTermPlansResult.success(List<LongTermPlan> data, {bool fromCache = false, bool hasMore = false}) => LongTermPlansResult(
    isLoading: false,
    isError: false,
    data: data,
    fromCache: fromCache,
    hasMore: hasMore,
  );
} 