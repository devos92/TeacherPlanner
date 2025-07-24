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

  /// Fetch outcomes by list of IDs (codes) - for selected outcomes
  static Future<List<CurriculumData>> getOutcomesByIds(List<String> codes) async {
    if (codes.isEmpty) return [];
    
    try {
      final response = await _supabase
        .from('curriculum')
        .select('''
          code,
          content_description,
          elaboration,
          subject:subject(name),
          strand:strand(name),
          level:level(name)
        ''')
        .inFilter('code', codes);

      return (response as List)
        .map((e) {
          final description = e['content_description']?.toString() ?? '';
          return CurriculumData(
            id: e['code'],
            name: description.isNotEmpty ? description : (e['code'] ?? 'No description'),
            code: e['code'],
            description: description.isNotEmpty ? description : null,
            elaboration: e['elaboration'],
            yearLevel: e['level']?['name'],
            subjectCode: e['subject']?['name'],
            strandId: e['strand']?['name'],
          );
        })
        .toList();
    } catch (e) {
      print('CurriculumService: Error fetching outcomes by IDs: $e');
      return [];
    }
  }

  /// Helper method to get a display name from curriculum data
  static String _getDisplayName(Map<String, dynamic> data) {
    // Since content_description and elaboration are null, create readable descriptions from codes
    if (data['code'] != null && data['code'].toString().isNotEmpty) {
      final code = data['code'].toString();
      
      // Parse Australian Curriculum codes to create readable descriptions
      if (code.startsWith('AC')) {
        // Australian Curriculum code format: AC9EFLA01
        // AC = Australian Curriculum
        // 9 = Version 9
        // EF = English Foundation
        // LA = Language
        // 01 = Outcome number
        
        if (code.length >= 8) {
          final subjectCode = code.substring(4, 6); // EF, MA, SC, etc.
          final strandCode = code.substring(6, 8); // LA, LI, NU, etc.
          final outcomeNum = code.substring(8); // 01, 02, etc.
          
          // Map subject codes to readable names
          final subjectNames = {
            'EF': 'English Foundation',
            'E1': 'English Year 1',
            'E2': 'English Year 2',
            'E3': 'English Year 3',
            'E4': 'English Year 4',
            'E5': 'English Year 5',
            'E6': 'English Year 6',
            'MF': 'Mathematics Foundation',
            'M1': 'Mathematics Year 1',
            'M2': 'Mathematics Year 2',
            'M3': 'Mathematics Year 3',
            'M4': 'Mathematics Year 4',
            'M5': 'Mathematics Year 5',
            'M6': 'Mathematics Year 6',
            'SF': 'Science Foundation',
            'S1': 'Science Year 1',
            'S2': 'Science Year 2',
            'S3': 'Science Year 3',
            'S4': 'Science Year 4',
            'S5': 'Science Year 5',
            'S6': 'Science Year 6',
          };
          
          // Map strand codes to readable names
          final strandNames = {
            'LA': 'Language',
            'LI': 'Literature',
            'NU': 'Number',
            'AL': 'Algebra',
            'ME': 'Measurement',
            'SP': 'Space',
            'ST': 'Statistics',
            'PR': 'Probability',
            'SU': 'Science Understanding',
            'SI': 'Science Inquiry',
            'SH': 'Science as Human Endeavour',
          };
          
          final subjectName = subjectNames[subjectCode] ?? subjectCode;
          final strandName = strandNames[strandCode] ?? strandCode;
          
          return '$subjectName - $strandName Outcome $outcomeNum';
        } else {
          return 'Australian Curriculum: $code';
        }
      } else if (code.startsWith('ENGENGFY')) {
        // English Foundation Year codes
        return 'English Foundation - Language Outcome';
      } else if (code.startsWith('ENGENGFYLANG')) {
        // English Foundation Language codes
        return 'English Foundation - Language Development';
      } else {
        // Generic curriculum code
        return 'Curriculum Outcome: $code';
      }
    } else {
      return 'No description available';
    }
  }
}
