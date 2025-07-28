// lib/services/curriculum_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/curriculum_models.dart';

class CurriculumService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  
  // Cache for frequently accessed data
  static Map<String, List<CurriculumData>> _yearCache = {};
  static Map<String, List<CurriculumData>> _subjectCache = {};
  static Map<String, List<CurriculumData>> _strandCache = {};
  static Map<String, List<CurriculumData>> _outcomeCache = {};

  /// Fast fetch years with caching - using IDs directly
  static Future<List<CurriculumData>> getYears() async {
    const cacheKey = 'years';
    
    // Return cached data if available
    if (_yearCache.containsKey(cacheKey)) {
      print('CurriculumService: Returning cached years (${_yearCache[cacheKey]!.length} items)');
      return _yearCache[cacheKey]!;
    }

    try {
      print('CurriculumService: Fetching years from database...');
      final response = await _supabase
        .from('level')
        .select('id, name')
        .order('id')
        .limit(20);

      final years = (response as List)
        .map((e) => CurriculumData(
          id: e['id'].toString(),
          name: e['name'],
          description: e['name'],
          yearLevel: e['name'],
        ))
        .toList();
      
      // Cache the result
      _yearCache[cacheKey] = years;
      
      print('CurriculumService: Cached ${years.length} years');
      return years;
    } catch (e) {
      print('CurriculumService: Error fetching years: $e');
      return [];
    }
  }

  /// Fast subject loading with smart caching - using level ID directly
  static Future<List<CurriculumData>> getSubjectsForYear(String levelId) async {
    final cacheKey = 'subjects_$levelId';
    
    // Return cached data if available
    if (_subjectCache.containsKey(cacheKey)) {
      print('CurriculumService: Returning cached subjects for level $levelId (${_subjectCache[cacheKey]!.length} items)');
      return _subjectCache[cacheKey]!;
    }

    try {
      print('CurriculumService: Fetching subjects for level ID: $levelId');
      
      // Simpler query approach - get distinct subject IDs for this level
      final response = await _supabase
        .from('curriculum')
        .select('subject_id')
        .eq('level_id', int.parse(levelId))
        .not('subject_id', 'is', null);
     
      // Get unique subject IDs
      final subjectIds = (response as List)
        .map((e) => e['subject_id'] as int)
        .toSet()
        .toList();

      print('CurriculumService: Found ${subjectIds.length} unique subject IDs: $subjectIds');

      // Now get the subject details for these IDs
      if (subjectIds.isNotEmpty) {
        final subjectResponse = await _supabase
          .from('subject')
          .select('id, name')
          .inFilter('id', subjectIds)
          .order('name');

        final result = (subjectResponse as List).map((s) => CurriculumData(
          id: s['id'].toString(),
          name: s['name'],
          description: s['name'],
          subjectCode: s['name'],
          yearLevel: levelId,
        )).toList();
        
        // Cache the result
        _subjectCache[cacheKey] = result;
        
        print('CurriculumService: Cached ${result.length} subjects for level $levelId: ${result.map((s) => s.name).join(', ')}');
        return result;
      } else {
        print('CurriculumService: No subjects found for level $levelId');
        return [];
      }
    } catch (e) {
      print('CurriculumService: Error fetching subjects for level $levelId: $e');
      return [];
    }
  }

  /// Fast strand loading with pagination - using subject ID and level ID directly
  static Future<List<CurriculumData>> getStrandsForSubjectAndYear(String subjectId, String levelId) async {
    final cacheKey = 'strands_${subjectId}_$levelId';
    
    // Return cached data if available
    if (_strandCache.containsKey(cacheKey)) {
      print('CurriculumService: Returning cached strands (${_strandCache[cacheKey]!.length} items)');
      return _strandCache[cacheKey]!;
    }

    try {
      print('CurriculumService: Fetching strands for subject $subjectId, level $levelId');
      final response = await _supabase
        .from('curriculum')
        .select('''
          strand_id,
          strand:strand(id, name)
        ''')
        .eq('subject_id', int.parse(subjectId))
        .eq('level_id', int.parse(levelId))
        .not('strand_id', 'is', null)
        .limit(20);
     
      // Create a map to ensure unique strands by ID
      final Map<String, Map<String, dynamic>> uniqueStrands = {};
      
      for (var item in response as List) {
        final strand = item['strand'] as Map<String, dynamic>;
        final strandId = strand['id'].toString();
        
        // Only add if we haven't seen this strand ID before
        if (!uniqueStrands.containsKey(strandId)) {
          uniqueStrands[strandId] = strand;
        }
      }

      final result = uniqueStrands.values.map((s) => CurriculumData(
        id: s['id'].toString(),
        name: s['name'],
        description: s['name'],
        strandId: s['id'].toString(),
        yearLevel: levelId,
      )).toList();
      
      // Cache the result
      _strandCache[cacheKey] = result;
      
      print('CurriculumService: Cached ${result.length} unique strands');
      return result;
    } catch (e) {
      print('CurriculumService: Error fetching strands for subject $subjectId: $e');
      return [];
    }
  }

  /// Fast outcome loading with virtual scrolling approach - using IDs directly
  static Future<List<CurriculumData>> getOutcomesForStrandAndYear(String strandId, String levelId, {int page = 0, int pageSize = 20}) async {
    final cacheKey = 'outcomes_${strandId}_$levelId';
    
    // For first page, return cached data if available
    if (page == 0 && _outcomeCache.containsKey(cacheKey)) {
      print('CurriculumService: Returning cached outcomes (${_outcomeCache[cacheKey]!.length} items)');
      return _outcomeCache[cacheKey]!;
    }

    try {
      print('CurriculumService: Fetching outcomes page $page for strand $strandId');
      final response = await _supabase
        .from('curriculum')
        .select('''
          code,
          content_description,
          subject:subject(name),
          strand:strand(name),
          sub_strand:sub_strand(name)
        ''')
        .eq('strand_id', int.parse(strandId))
        .eq('level_id', int.parse(levelId))
        .order('code')
        .range(page * pageSize, (page + 1) * pageSize - 1);

      print('CurriculumService: Raw response length: ${response.length}');
      
      final outcomes = (response as List)
        .map((e) {
          final description = e['content_description']?.toString() ?? '';
          final shortDescription = description.isNotEmpty && description.length > 50 
            ? '${description.substring(0, 50)}...' 
            : description;
          print('CurriculumService: Processing outcome - code: ${e['code']}, description: $shortDescription');
          return CurriculumData(
            id: e['code'],
            name: description.isNotEmpty ? description : 'No description available',
            code: e['code'],
            description: description.isNotEmpty ? description : null,
            elaboration: null, // Remove elaborations
            yearLevel: levelId,
            subjectCode: e['subject']?['name'],
            strandId: e['strand']?['name'],
            subStrand: e['sub_strand']?['name'],
          );
        })
        .toList();
      
      // Cache first page
      if (page == 0) {
        _outcomeCache[cacheKey] = outcomes;
        print('CurriculumService: Cached ${outcomes.length} outcomes');
      }
      
      return outcomes;
    } catch (e) {
      print('CurriculumService: Error fetching outcomes for strand $strandId: $e');
      return [];
    }
  }

  /// Clear cache when needed (like Airbnb's cache invalidation)
  static void clearCache() {
    _yearCache.clear();
    _subjectCache.clear();
    _strandCache.clear();
    _outcomeCache.clear();
    print('CurriculumService: All caches cleared');
  }

  /// Clear specific cache for strands to force refresh
  static void clearStrandCache() {
    _strandCache.clear();
    print('CurriculumService: Strand cache cleared');
  }

  /// Fetch sub-strands for a given strand and year (with caching) - using IDs directly
  static Future<List<CurriculumData>> getSubStrandsForStrandAndYear(String strandId, String levelId) async {
    final cacheKey = 'substrands_${strandId}_$levelId';
    
    // Return cached data if available
    if (_strandCache.containsKey(cacheKey)) {
      print('CurriculumService: Returning cached sub-strands (${_strandCache[cacheKey]!.length} items)');
      return _strandCache[cacheKey]!;
    }

    try {
      print('CurriculumService: Fetching sub-strands for strand $strandId, level $levelId');
      final response = await _supabase
        .from('curriculum')
        .select('''
          sub_strand_id,
          sub_strand:sub_strand(id, name)
        ''')
        .eq('strand_id', int.parse(strandId))
        .eq('level_id', int.parse(levelId))
        .not('sub_strand_id', 'is', null)
        .limit(20);
     
      // Create a map to ensure unique sub-strands by ID
      final Map<String, Map<String, dynamic>> uniqueSubStrands = {};
      
      for (var item in response as List) {
        final subStrand = item['sub_strand'] as Map<String, dynamic>;
        final subStrandId = subStrand['id'].toString();
        
        // Only add if we haven't seen this sub-strand ID before
        if (!uniqueSubStrands.containsKey(subStrandId)) {
          uniqueSubStrands[subStrandId] = subStrand;
        }
      }

      final result = uniqueSubStrands.values.map((s) => CurriculumData(
        id: s['id'].toString(),
        name: s['name'],
        description: s['name'],
        subStrand: s['name'],
        yearLevel: levelId,
      )).toList();
      
      // Cache the result
      _strandCache[cacheKey] = result;
      
      print('CurriculumService: Cached ${result.length} unique sub-strands');
      return result;
    } catch (e) {
      print('CurriculumService: Error fetching sub-strands for strand $strandId: $e');
      return [];
    }
  }

  /// Fetch outcomes for a given sub-strand and year (with caching) - using IDs directly
  static Future<List<CurriculumData>> getOutcomesForSubStrandAndYear(String strandId, String subStrandId, String levelId) async {
    final cacheKey = 'outcomes_sub_${strandId}_${subStrandId}_$levelId';
    
    // Return cached data if available
    if (_outcomeCache.containsKey(cacheKey)) {
      print('CurriculumService: Returning cached sub-strand outcomes (${_outcomeCache[cacheKey]!.length} items)');
      return _outcomeCache[cacheKey]!;
    }

    try {
      print('CurriculumService: Fetching outcomes for sub-strand $subStrandId, level $levelId');
      final response = await _supabase
        .from('curriculum')
        .select('''
          code,
          content_description,
          subject:subject(name),
          strand:strand(name),
          sub_strand:sub_strand(name)
        ''')
        .eq('strand_id', int.parse(strandId))
        .eq('sub_strand_id', int.parse(subStrandId))
        .eq('level_id', int.parse(levelId))
        .order('code')
        .limit(50);

      final outcomes = (response as List)
        .map((e) {
          final description = e['content_description']?.toString() ?? '';
          return CurriculumData(
            id: e['code'],
            name: description.isNotEmpty ? description : 'No description available',
            code: e['code'],
            description: description.isNotEmpty ? description : null,
            elaboration: null, // Remove elaborations
            yearLevel: levelId,
            subjectCode: e['subject']?['name'],
            strandId: e['strand']?['name'],
            subStrand: e['sub_strand']?['name'],
          );
        })
        .toList();
      
      // Cache the result
      _outcomeCache[cacheKey] = outcomes;
      
      print('CurriculumService: Cached ${outcomes.length} sub-strand outcomes');
      return outcomes;
    } catch (e) {
      print('CurriculumService: Error fetching outcomes for sub-strand $subStrandId: $e');
      return [];
    }
  }

  /// Search functionality
  static Future<List<CurriculumData>> searchOutcomes(String query) async {
    try {
      print('CurriculumService: Searching outcomes for: $query');
      final response = await _supabase
        .from('curriculum')
        .select('''
          code,
          content_description,
          subject:subject(name),
          strand:strand(name),
          level:level(name)
        ''')
        .ilike('content_description', '%$query%')
        .limit(50);

      return (response as List)
        .map((e) {
          final description = e['content_description']?.toString() ?? '';
          return CurriculumData(
            id: e['code'],
            name: description.isNotEmpty ? description : 'No description available',
            code: e['code'],
            description: description.isNotEmpty ? description : null,
            yearLevel: e['level']?['name'],
            subjectCode: e['subject']?['name'],
            strandId: e['strand']?['name'],
          );
        })
        .toList();
    } catch (e) {
      print('CurriculumService: Error searching outcomes: $e');
      return [];
    }
  }
}
