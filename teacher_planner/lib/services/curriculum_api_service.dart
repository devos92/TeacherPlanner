// lib/services/curriculum_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/curriculum_models.dart';

class CurriculumApiService {
  static const String _baseUrl = 'https://www.australiancurriculum.edu.au/api/v1';
  
  // Cache for API responses
  static Map<String, dynamic> _cache = {};
  static const Duration _cacheExpiry = Duration(hours: 24);

  /// Fetch all learning areas (subjects) from the Australian Curriculum API
  static Future<List<CurriculumSubject>> fetchLearningAreas() async {
    const cacheKey = 'learning_areas';
    
    // Check cache first
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey];
      if (DateTime.now().difference(cached['timestamp']) < _cacheExpiry) {
        return cached['data'];
      }
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/learning-areas'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final subjects = <CurriculumSubject>[];
        
        for (var item in data['data']) {
          subjects.add(CurriculumSubject(
            id: item['identifier'],
            name: item['title'],
            code: item['identifier'],
            description: item['description'] ?? '',
            strands: [], // Will be populated separately
          ));
        }

        // Cache the result
        _cache[cacheKey] = {
          'data': subjects,
          'timestamp': DateTime.now(),
        };

        return subjects;
      } else {
        throw Exception('Failed to load learning areas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching learning areas: $e');
      // Return fallback data
      return _getFallbackSubjects();
    }
  }

  /// Fetch strands for a specific learning area
  static Future<List<CurriculumStrand>> fetchStrands(String learningAreaId) async {
    final cacheKey = 'strands_$learningAreaId';
    
    // Check cache first
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey];
      if (DateTime.now().difference(cached['timestamp']) < _cacheExpiry) {
        return cached['data'];
      }
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/learning-areas/$learningAreaId/strands'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final strands = <CurriculumStrand>[];
        
        for (var item in data['data']) {
          strands.add(CurriculumStrand(
            id: item['identifier'],
            name: item['title'],
            description: item['description'] ?? '',
            outcomes: [], // Will be populated separately
          ));
        }

        // Cache the result
        _cache[cacheKey] = {
          'data': strands,
          'timestamp': DateTime.now(),
        };

        return strands;
      } else {
        throw Exception('Failed to load strands: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching strands: $e');
      return [];
    }
  }

  /// Fetch outcomes for a specific strand
  static Future<List<CurriculumOutcome>> fetchOutcomes(String learningAreaId, String strandId) async {
    final cacheKey = 'outcomes_${learningAreaId}_$strandId';
    
    // Check cache first
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey];
      if (DateTime.now().difference(cached['timestamp']) < _cacheExpiry) {
        return cached['data'];
      }
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/learning-areas/$learningAreaId/strands/$strandId/content-descriptions'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final outcomes = <CurriculumOutcome>[];
        
        for (var item in data['data']) {
          outcomes.add(CurriculumOutcome(
            id: item['identifier'],
            code: item['notation'] ?? '',
            description: item['description'] ?? '',
            elaboration: item['elaborations']?.first?['description'] ?? '',
            yearLevel: _extractYearLevel(item['year-level-descriptions'] ?? []),
          ));
        }

        // Cache the result
        _cache[cacheKey] = {
          'data': outcomes,
          'timestamp': DateTime.now(),
        };

        return outcomes;
      } else {
        throw Exception('Failed to load outcomes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching outcomes: $e');
      return [];
    }
  }

  /// Fetch complete curriculum data for a specific year level
  static Future<CurriculumYear> fetchYearLevelData(String yearLevel) async {
    final cacheKey = 'year_$yearLevel';
    
    // Check cache first
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey];
      if (DateTime.now().difference(cached['timestamp']) < _cacheExpiry) {
        return cached['data'];
      }
    }

    try {
      // Fetch learning areas
      final subjects = await fetchLearningAreas();
      final updatedSubjects = <CurriculumSubject>[];
      
      // For each subject, fetch strands and outcomes
      for (var subject in subjects) {
        final strands = await fetchStrands(subject.id);
        final updatedStrands = <CurriculumStrand>[];
        
        for (var strand in strands) {
          final outcomes = await fetchOutcomes(subject.id, strand.id);
          // Filter outcomes for the specific year level
          final yearOutcomes = outcomes.where((o) => o.yearLevel == yearLevel).toList();
          
          updatedStrands.add(CurriculumStrand(
            id: strand.id,
            name: strand.name,
            description: strand.description,
            outcomes: yearOutcomes,
          ));
        }
        
        updatedSubjects.add(CurriculumSubject(
          id: subject.id,
          name: subject.name,
          code: subject.code,
          description: subject.description,
          strands: updatedStrands,
        ));
      }

      final yearData = CurriculumYear(
        id: yearLevel,
        name: _getYearName(yearLevel),
        description: '${_getYearName(yearLevel)} curriculum',
        subjects: updatedSubjects,
      );

      // Cache the result
      _cache[cacheKey] = {
        'data': yearData,
        'timestamp': DateTime.now(),
      };

      return yearData;
    } catch (e) {
      print('Error fetching year level data: $e');
      return _getFallbackYearData(yearLevel);
    }
  }

  /// Clear the cache
  static void clearCache() {
    _cache.clear();
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'entries': _cache.length,
      'keys': _cache.keys.toList(),
    };
  }

  // Helper methods
  static String _extractYearLevel(List<dynamic> yearLevelDescriptions) {
    if (yearLevelDescriptions.isEmpty) return '';
    
    // Extract year level from the first description
    final description = yearLevelDescriptions.first.toString();
    final match = RegExp(r'Year (\d+)').firstMatch(description);
    if (match != null) {
      return 'year${match.group(1)}';
    }
    
    // Check for Foundation
    if (description.toLowerCase().contains('foundation')) {
      return 'foundation';
    }
    
    return '';
  }

  static String _getYearName(String yearLevel) {
    switch (yearLevel) {
      case 'foundation':
        return 'Foundation Year';
      case 'year1':
        return 'Year 1';
      case 'year2':
        return 'Year 2';
      case 'year3':
        return 'Year 3';
      case 'year4':
        return 'Year 4';
      case 'year5':
        return 'Year 5';
      case 'year6':
        return 'Year 6';
      case 'year7':
        return 'Year 7';
      case 'year8':
        return 'Year 8';
      case 'year9':
        return 'Year 9';
      case 'year10':
        return 'Year 10';
      default:
        return yearLevel;
    }
  }

  // Fallback data when API is unavailable
  static List<CurriculumSubject> _getFallbackSubjects() {
    return [
      CurriculumSubject(
        id: 'english',
        name: 'English',
        code: 'ACELY1646',
        description: 'English learning area',
        strands: [],
      ),
      CurriculumSubject(
        id: 'mathematics',
        name: 'Mathematics',
        code: 'ACMNA001',
        description: 'Mathematics learning area',
        strands: [],
      ),
      CurriculumSubject(
        id: 'science',
        name: 'Science',
        code: 'ACSSU001',
        description: 'Science learning area',
        strands: [],
      ),
    ];
  }

  static CurriculumYear _getFallbackYearData(String yearLevel) {
    return CurriculumYear(
      id: yearLevel,
      name: _getYearName(yearLevel),
      description: '${_getYearName(yearLevel)} curriculum',
      subjects: _getFallbackSubjects(),
    );
  }
} 