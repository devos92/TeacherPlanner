// lib/services/supabase_curriculum_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class CurriculumData {
  final String id;
  final String name;
  final String? code;
  final String? description;
  final String? yearLevel;
  final String? subjectId;
  final String? strandId;
  final String? elaboration;

  CurriculumData({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.yearLevel,
    this.subjectId,
    this.strandId,
    this.elaboration,
  });

  factory CurriculumData.fromJson(Map<String, dynamic> json) {
    return CurriculumData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'],
      description: json['description'],
      yearLevel: json['year_level'],
      subjectId: json['subject_id'],
      strandId: json['strand_id'],
      elaboration: json['elaboration'],
    );
  }
}

class SupabaseCurriculumService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Get all years
  static Future<List<CurriculumData>> getYears() async {
    try {
      final response = await _supabase
          .from('curriculum_years')
          .select()
          .order('id');
      
      return (response as List)
          .map((json) => CurriculumData.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching years: $e');
      return [];
    }
  }

  // Get all subjects
  static Future<List<CurriculumData>> getSubjects() async {
    try {
      final response = await _supabase
          .from('curriculum_subjects')
          .select()
          .order('name');
      
      return (response as List)
          .map((json) => CurriculumData.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching subjects: $e');
      return [];
    }
  }

  // Get strands for a specific subject
  static Future<List<CurriculumData>> getStrandsForSubject(String subjectId) async {
    try {
      final response = await _supabase
          .from('curriculum_strands')
          .select()
          .eq('subject_id', subjectId)
          .order('name');
      
      return (response as List)
          .map((json) => CurriculumData.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching strands for subject $subjectId: $e');
      return [];
    }
  }

  // Get outcomes for a specific strand and year level
  static Future<List<CurriculumData>> getOutcomesForStrandAndYear(
    String strandId, 
    String yearLevel
  ) async {
    try {
      final response = await _supabase
          .from('curriculum_outcomes')
          .select()
          .eq('strand_id', strandId)
          .eq('year_level', yearLevel)
          .order('code');
      
      return (response as List)
          .map((json) => CurriculumData.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching outcomes for strand $strandId and year $yearLevel: $e');
      return [];
    }
  }

  // Get all outcomes for a specific year level
  static Future<List<CurriculumData>> getOutcomesForYear(String yearLevel) async {
    try {
      final response = await _supabase
          .from('curriculum_outcomes')
          .select()
          .eq('year_level', yearLevel)
          .order('code');
      
      return (response as List)
          .map((json) => CurriculumData.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching outcomes for year $yearLevel: $e');
      return [];
    }
  }

  // Search outcomes by keyword
  static Future<List<CurriculumData>> searchOutcomes(String keyword) async {
    try {
      final response = await _supabase
          .from('curriculum_outcomes')
          .select()
          .or('description.ilike.%$keyword%,code.ilike.%$keyword%')
          .order('code');
      
      return (response as List)
          .map((json) => CurriculumData.fromJson(json))
          .toList();
    } catch (e) {
      print('Error searching outcomes: $e');
      return [];
    }
  }

  // Get complete curriculum structure
  static Future<Map<String, dynamic>> getCurriculumStructure() async {
    try {
      final years = await getYears();
      final subjects = await getSubjects();
      
      Map<String, dynamic> structure = {
        'years': years,
        'subjects': subjects,
        'strands': <String, List<CurriculumData>>{},
        'outcomes': <String, List<CurriculumData>>{},
      };

      // Get strands for each subject
      for (var subject in subjects) {
        final strands = await getStrandsForSubject(subject.id);
        structure['strands'][subject.id] = strands;
      }

      // Get outcomes for each year
      for (var year in years) {
        final outcomes = await getOutcomesForYear(year.id);
        structure['outcomes'][year.id] = outcomes;
      }

      return structure;
    } catch (e) {
      print('Error fetching curriculum structure: $e');
      return {
        'years': <CurriculumData>[],
        'subjects': <CurriculumData>[],
        'strands': <String, List<CurriculumData>>{},
        'outcomes': <String, List<CurriculumData>>{},
      };
    }
  }

  // Test Supabase connectivity
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      print('Testing Supabase curriculum database connectivity...');
      
      // Test basic connectivity
      final years = await getYears();
      final subjects = await getSubjects();
      
      return {
        'supabase_connected': true,
        'years_count': years.length,
        'subjects_count': subjects.length,
        'message': 'Successfully connected to Supabase',
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'supabase_connected': false,
      };
    }
  }
}