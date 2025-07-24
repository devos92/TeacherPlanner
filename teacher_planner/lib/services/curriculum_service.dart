/// lib/services/curriculum_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/curriculum_models.dart';

class CurriculumService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all distinct year levels from the level table
  static Future<List<CurriculumData>> getYears() async {
    try {
      final response = await _supabase
        .from('level')
        .select('id, name')
        .order('name');

      return (response as List)
        .map((e) => CurriculumData(
          id: e['id'].toString(),
          name: e['name'],
          description: e['name'],
          yearLevel: e['name'],
        ))
        .toList();
    } catch (e) {
      print('Error fetching years: $e');
      return [];
    }
  }

  /// Fetch subjects for a given year level
  static Future<List<CurriculumData>> getSubjectsForYear(String yearLevel) async {
    try {
      final levelId = await _getLevelIdByName(yearLevel);
      final response = await _supabase
        .from('curriculum')
        .select('subject_id, subject:subject(name)')
        .eq('level_id', levelId)
        .not('subject_id', 'is', null);

      final subjects = (response as List)
        .map((e) => e['subject'] as Map<String, dynamic>)
        .toSet()
        .toList();

      return subjects.map((s) => CurriculumData(
        id: s['id'].toString(),
        name: s['name'],
        description: s['name'],
        subjectCode: s['name'],
        yearLevel: yearLevel,
      )).toList();
    } catch (e) {
      print('Error fetching subjects for $yearLevel: $e');
      return [];
    }
  }

  /// Fetch strands for a given subject and year
  static Future<List<CurriculumData>> getStrandsForSubjectAndYear(String subjectId, String yearLevel) async {
    try {
      final levelId = await _getLevelIdByName(yearLevel);
      final response = await _supabase
        .from('curriculum')
        .select('strand_id, strand:strand(name)')
        .eq('subject_id', int.parse(subjectId))
        .eq('level_id', levelId)
        .not('strand_id', 'is', null);

      final strands = (response as List)
        .map((e) => e['strand'] as Map<String, dynamic>)
        .toSet()
        .toList();

      return strands.map((s) => CurriculumData(
        id: s['id'].toString(),
        name: s['name'],
        description: s['name'],
        strandId: s['id'].toString(),
        yearLevel: yearLevel,
      )).toList();
    } catch (e) {
      print('Error fetching strands for $subjectId: $e');
      return [];
    }
  }

  /// Fetch sub-strands for a given strand and year
  static Future<List<CurriculumData>> getSubStrandsForStrandAndYear(String strandId, String yearLevel) async {
    try {
      final levelId = await _getLevelIdByName(yearLevel);
      final response = await _supabase
        .from('curriculum')
        .select('sub_strand_id, sub_strand:sub_strand(name)')
        .eq('strand_id', int.parse(strandId))
        .eq('level_id', levelId)
        .not('sub_strand_id', 'is', null);

      final subs = (response as List)
        .map((e) => e['sub_strand'] as Map<String, dynamic>)
        .toSet()
        .toList();

      return subs.map((s) => CurriculumData(
        id: s['id'].toString(),
        name: s['name'],
        description: s['name'],
        subStrand: s['name'],
        yearLevel: yearLevel,
      )).toList();
    } catch (e) {
      print('Error fetching sub-strands for $strandId: $e');
      return [];
    }
  }

  /// Fetch outcomes for a given strand and year
  static Future<List<CurriculumData>> getOutcomesForStrandAndYear(String strandId, String yearLevel) async {
    try {
      final levelId = await _getLevelIdByName(yearLevel);
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
        .eq('level_id', levelId)
        .order('code');

      return (response as List)
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
    } catch (e) {
      print('Error fetching outcomes for strand $strandId: $e');
      return [];
    }
  }

  /// Fetch outcomes for a given sub-strand and year
  static Future<List<CurriculumData>> getOutcomesForSubStrandAndYear(
      String strandId, String subStrandId, String yearLevel) async {
    try {
      final levelId = await _getLevelIdByName(yearLevel);
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
        .eq('level_id', levelId)
        .order('code');

      return (response as List)
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
    } catch (e) {
      print('Error fetching outcomes for sub-strand $subStrandId: $e');
      return [];
    }
  }

  /// Fetch outcomes by list of codes
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

  /// Build full nested tree: year -> subject -> strand -> sub-strand -> outcomes
  static Future<Map<String,Map<String,Map<String,Map<String,List<CurriculumData>>>>>> getCurriculumTree() async {
    final rows = await _supabase
      .from('curriculum')
      .select('''
        level(name),
        subject(name),
        strand(name),
        sub_strand(name),
        code,
        content_description,
        elaboration
      ''')
      .order('level,name,subject,name,strand,name,sub_strand,name,code');

    final tree = <String,Map<String,Map<String,Map<String,List<CurriculumData>>>>>{};
    for (final r in rows as List) {
      final year = r['level']['name'] as String;
      final subj = r['subject']['name'] as String;
      final str  = r['strand']['name'] as String;
      final sub  = (r['sub_strand']?['name'] as String?) ?? '';
      final outcome = CurriculumData(
        id: r['code'],
        name: r['content_description'] ?? r['elaboration'] ?? r['code'],
        code: r['code'],
        description: r['content_description'],
        elaboration: r['elaboration'],
        yearLevel: year,
        subjectCode: subj,
        strandId: str,
        subStrand: sub,
      );

      tree
        .putIfAbsent(year, () => {})
        .putIfAbsent(subj, () => {})
        .putIfAbsent(str, () => {})
        .putIfAbsent(sub, () => [])
        .add(outcome);
    }
    return tree;
  }

  /// Prefer description over elaboration
  static String _getDisplayName(Map<String, dynamic> data) {
    if ((data['content_description'] as String?)?.isNotEmpty == true) return data['content_description'];
    if ((data['elaboration'] as String?)?.isNotEmpty == true) return data['elaboration'];
    return data['code'] ?? 'No description';
  }

  /// Helper: look up level ID by name
  static Future<int> _getLevelIdByName(String levelName) async {
    final row = await _supabase
      .from('level')
      .select('id')
      .eq('name', levelName)
      .single();
    return row['id'] as int;
  }
}
