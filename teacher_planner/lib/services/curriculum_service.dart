// lib/services/curriculum_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/curriculum_models.dart';

class CurriculumService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all distinct year levels from the level table
  static Future<List<CurriculumData>> getYears() async {
    try {
      print('CurriculumService: Fetching years...');
      final response = await _supabase
        .from('level')
        .select('id, name')
        .order('name');

      final years = (response as List)
        .map((e) => CurriculumData(
          id: e['id'].toString(),
          name: e['name'],
          description: e['name'],
          yearLevel: e['name'],
        ))
        .toList();
      
      print('CurriculumService: Found ${years.length} years: ${years.map((y) => y.name).join(', ')}');
      return years;
    } catch (e) {
      print('CurriculumService: Error fetching years: $e');
      return [];
    }
  }

  /// Fetch subjects for a given year level
  static Future<List<CurriculumData>> getSubjectsForYear(String yearLevel) async {
    try {
      print('CurriculumService: Fetching subjects for year: $yearLevel');
      final levelId = await _getLevelIdByName(yearLevel);
      print('CurriculumService: Level ID for "$yearLevel": $levelId');
      
      final response = await _supabase
        .from('curriculum')
        .select('''
          subject_id,
          subject:subject(name)
        ''')
        .eq('level_id', levelId)
        .not('subject_id', 'is', null);

      print('CurriculumService: Raw response length: ${response.length}');
      
      final subjects = (response as List)
        .map((e) => e['subject'] as Map<String, dynamic>)
        .toSet()
        .toList();

      final result = subjects.map((s) => CurriculumData(
        id: s['id'].toString(),
        name: s['name'],
        description: s['name'],
        subjectCode: s['name'],
        yearLevel: yearLevel,
      )).toList();
      
      print('CurriculumService: Found ${result.length} subjects for $yearLevel: ${result.map((s) => s.name).join(', ')}');
      return result;
    } catch (e) {
      print('CurriculumService: Error fetching subjects for year $yearLevel: $e');
      return [];
    }
  }

  /// Fetch strands for a given subject and year
  static Future<List<CurriculumData>> getStrandsForSubjectAndYear(String subjectId, String yearLevel) async {
    try {
      print('CurriculumService: Fetching strands for subject $subjectId, year $yearLevel');
      final response = await _supabase
        .from('curriculum')
        .select('''
          strand_id,
          strand:strand(name)
        ''')
        .eq('subject_id', int.parse(subjectId))
        .eq('level_id', await _getLevelIdByName(yearLevel))
        .not('strand_id', 'is', null);

      final strands = (response as List)
        .map((e) => e['strand'] as Map<String, dynamic>)
        .toSet()
        .toList();

      final result = strands.map((s) => CurriculumData(
        id: s['id'].toString(),
        name: s['name'],
        description: s['name'],
        strandId: s['id'].toString(),
        yearLevel: yearLevel,
      )).toList();
      
      print('CurriculumService: Found ${result.length} strands for subject $subjectId: ${result.map((s) => s.name).join(', ')}');
      return result;
    } catch (e) {
      print('CurriculumService: Error fetching strands for subject $subjectId: $e');
      return [];
    }
  }

  /// Fetch sub-strands for a given strand and year
  static Future<List<CurriculumData>> getSubStrandsForStrandAndYear(String strandId, String yearLevel) async {
    try {
      print('CurriculumService: Fetching sub-strands for strand $strandId, year $yearLevel');
      final response = await _supabase
        .from('curriculum')
        .select('''
          sub_strand_id,
          sub_strand:sub_strand(name)
        ''')
        .eq('strand_id', int.parse(strandId))
        .eq('level_id', await _getLevelIdByName(yearLevel))
        .not('sub_strand_id', 'is', null);

      final subStrands = (response as List)
        .map((e) => e['sub_strand'] as Map<String, dynamic>)
        .toSet()
        .toList();

      final result = subStrands.map((s) => CurriculumData(
        id: s['id'].toString(),
        name: s['name'],
        description: s['name'],
        subStrand: s['name'],
        yearLevel: yearLevel,
      )).toList();
      
      print('CurriculumService: Found ${result.length} sub-strands for strand $strandId: ${result.map((s) => s.name).join(', ')}');
      return result;
    } catch (e) {
      print('CurriculumService: Error fetching sub-strands for strand $strandId: $e');
      return [];
    }
  }

  /// Fetch outcomes for a given strand and year
  static Future<List<CurriculumData>> getOutcomesForStrandAndYear(String strandId, String yearLevel) async {
    try {
      print('CurriculumService: Fetching outcomes for strand $strandId, year $yearLevel');
      final response = await _supabase
        .from('curriculum')
        .select('''
          code,
          content_description,
          elaboration,
          subject:subject(name),
          strand:strand(name),
          sub_strand:sub_strand(name)
        ''')
        .eq('strand_id', int.parse(strandId))
        .eq('level_id', await _getLevelIdByName(yearLevel))
        .order('code');

      final outcomes = (response as List)
        .map((e) => CurriculumData(
          id: e['code'],
          name: _getDisplayName(e),
          code: e['code'],
          description: e['content_description'],
          elaboration: e['elaboration'],
          yearLevel: yearLevel,
          subjectCode: e['subject']?['name'],
          strandId: e['strand']?['name'],
          subStrand: e['sub_strand']?['name'],
        ))
        .toList();
      
      print('CurriculumService: Found ${outcomes.length} outcomes for strand $strandId');
      return outcomes;
    } catch (e) {
      print('CurriculumService: Error fetching outcomes for strand $strandId: $e');
      return [];
    }
  }

  /// Fetch outcomes for a given sub-strand and year
  static Future<List<CurriculumData>> getOutcomesForSubStrandAndYear(String strandId, String subStrandId, String yearLevel) async {
    try {
      print('CurriculumService: Fetching outcomes for sub-strand $subStrandId, year $yearLevel');
      final response = await _supabase
        .from('curriculum')
        .select('''
          code,
          content_description,
          elaboration,
          subject:subject(name),
          strand:strand(name),
          sub_strand:sub_strand(name)
        ''')
        .eq('strand_id', int.parse(strandId))
        .eq('sub_strand_id', int.parse(subStrandId))
        .eq('level_id', await _getLevelIdByName(yearLevel))
        .order('code');

      final outcomes = (response as List)
        .map((e) => CurriculumData(
          id: e['code'],
          name: _getDisplayName(e),
          code: e['code'],
          description: e['content_description'],
          elaboration: e['elaboration'],
          yearLevel: yearLevel,
          subjectCode: e['subject']?['name'],
          strandId: e['strand']?['name'],
          subStrand: e['sub_strand']?['name'],
        ))
        .toList();
      
      print('CurriculumService: Found ${outcomes.length} outcomes for sub-strand $subStrandId');
      return outcomes;
    } catch (e) {
      print('CurriculumService: Error fetching outcomes for sub-strand $subStrandId: $e');
      return [];
    }
  }

  /// Fetch outcomes by list of IDs (codes)
  static Future<List<CurriculumData>> getOutcomesByIds(List<String> codes) async {
    if (codes.isEmpty) return [];
    
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
      .map((e) => CurriculumData(
        id: e['code'],
        name: e['content_description'] ?? '',
        code: e['code'],
        description: e['content_description'],
        elaboration: e['elaboration'],
        yearLevel: e['level']?['name'],
        subjectCode: e['subject']?['name'],
        strandId: e['strand']?['name'],
      ))
      .toList();
  }

  /// Helper method to get a display name from curriculum data
  static String _getDisplayName(Map<String, dynamic> data) {
    // Prefer content_description, then elaboration, then code
    if (data['content_description'] != null && data['content_description'].toString().isNotEmpty) {
      return data['content_description'];
    } else if (data['elaboration'] != null && data['elaboration'].toString().isNotEmpty) {
      return data['elaboration'];
    } else {
      return data['code'] ?? 'No description';
    }
  }

   /// Fetch all outcomes for a given subject & year
  static Future<List<CurriculumData>> getOutcomesBySubjectAndYear(
    String subjectCode,
    String yearLevel,
  ) async {
    final response = await _supabase
      .from('curriculum_content_descriptions')
      .select('*')
      .eq('subject_code', subjectCode)
      .eq('year_level', yearLevel)
      .order('code');
    return (response as List)
      .map((e) => CurriculumData.fromJson(e))
      .toList();
  }

  /// Helper method to get level ID by name
  static Future<int> _getLevelIdByName(String levelName) async {
    try {
      print('CurriculumService: Looking for level: "$levelName"');
      final response = await _supabase
        .from('level')
        .select('id')
        .eq('name', levelName)
        .single();
      
      final levelId = response['id'] as int;
      print('CurriculumService: Found level ID: $levelId for "$levelName"');
      return levelId;
    } catch (e) {
      print('CurriculumService: Error finding level "$levelName": $e');
      // Try to get all levels to see what's available
      try {
        final allLevels = await _supabase
          .from('level')
          .select('id, name')
          .order('name');
        print('CurriculumService: Available levels: ${(allLevels as List).map((l) => '${l['id']}:${l['name']}').join(', ')}');
      } catch (e2) {
        print('CurriculumService: Error getting all levels: $e2');
      }
      rethrow;
    }
  }
}
