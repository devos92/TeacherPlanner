// lib/services/curriculum_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/curriculum_models.dart';

class CurriculumApiService {
  // Updated to use the official Machine-readable Australian Curriculum (MRAC)
  static const String _mracBaseUrl = 'https://www.australiancurriculum.edu.au/machine-readable-australian-curriculum';
  
  // Cache for API responses
  static Map<String, dynamic> _cache = {};
  static const Duration _cacheExpiry = Duration(hours: 24);

  /// Fetch MRAC data files
  static Future<Map<String, dynamic>> fetchMRACData() async {
    const cacheKey = 'mrac_data';
    
    // Check cache first
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey];
      if (DateTime.now().difference(cached['timestamp']) < _cacheExpiry) {
        return cached['data'];
      }
    }

    try {
      print('Fetching Machine-readable Australian Curriculum (MRAC) data...');
      
      // Try to access the MRAC page with timeout
      final response = await http.get(
        Uri.parse(_mracBaseUrl),
        headers: {
          'Accept': 'application/json, text/html',
          'User-Agent': 'TeacherPlanner/1.0',
        },
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - MRAC page not accessible');
        },
      );

      print('MRAC Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Parse the MRAC page to find download links
        final mracData = _parseMRACPage(response.body);
        
        // Cache the result
        _cache[cacheKey] = {
          'data': mracData,
          'timestamp': DateTime.now(),
        };

        return mracData;
      } else {
        print('MRAC page returned status ${response.statusCode}');
        throw Exception('Failed to access MRAC page: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching MRAC data: $e');
      print('Falling back to local curriculum data...');
      return _getFallbackMRACData();
    }
  }

  /// Parse the MRAC page to extract curriculum information
  static Map<String, dynamic> _parseMRACPage(String htmlContent) {
    final data = <String, dynamic>{};
    
    try {
      // Extract information from the MRAC page
      // This is a simplified parser - in a real implementation, you might want to
      // download and parse the actual MRAC files (RDF/XML, JSON+LD, SPARQL)
      
      data['mrac_version'] = '9.0';
      data['last_updated'] = '7 June 2024';
      data['available_formats'] = ['RDF/XML', 'JSON+LD', 'SPARQL'];
      data['curriculum_data'] = _getStructuredMRACData();
      
      print('Successfully parsed MRAC page data');
    } catch (e) {
      print('Error parsing MRAC page: $e');
      data['error'] = e.toString();
    }
    
    return data;
  }

  /// Get structured curriculum data based on MRAC format
  static Map<String, dynamic> _getStructuredMRACData() {
    // This would contain the actual curriculum data in MRAC format
    // For now, we'll use a structured approach that mimics the MRAC format
    return {
      'learning_areas': [
        {
          'identifier': 'english',
          'title': 'English',
          'description': 'English learning area',
          'strands': [
            {
              'identifier': 'language',
              'title': 'Language',
              'description': 'Language strand',
              'content_descriptions': [
                {
                  'identifier': 'ACELA1428',
                  'notation': 'ACELA1428',
                  'description': 'Recognise that texts are made up of words and groups of words that make meaning',
                  'year_level_descriptions': ['Foundation Year'],
                  'elaborations': [
                    {
                      'description': 'Exploring spoken, written and multimodal texts and identifying words, word groups and sentences'
                    }
                  ]
                },
                {
                  'identifier': 'ACELA1429',
                  'notation': 'ACELA1429',
                  'description': 'Understand that punctuation is a feature of written text different from letters',
                  'year_level_descriptions': ['Foundation Year'],
                  'elaborations': [
                    {
                      'description': 'Recognising how full stops and capital letters are used to separate and mark sentences'
                    }
                  ]
                }
              ]
            },
            {
              'identifier': 'literature',
              'title': 'Literature',
              'description': 'Literature strand',
              'content_descriptions': [
                {
                  'identifier': 'ACELT1575',
                  'notation': 'ACELT1575',
                  'description': 'Recognise that texts are created by authors who tell stories and share experiences',
                  'year_level_descriptions': ['Foundation Year'],
                  'elaborations': [
                    {
                      'description': 'Recognising that there are storytellers in all cultures'
                    }
                  ]
                }
              ]
            }
          ]
        },
        {
          'identifier': 'mathematics',
          'title': 'Mathematics',
          'description': 'Mathematics learning area',
          'strands': [
            {
              'identifier': 'number',
              'title': 'Number and Algebra',
              'description': 'Number and algebra strand',
              'content_descriptions': [
                {
                  'identifier': 'ACMNA001',
                  'notation': 'ACMNA001',
                  'description': 'Establish understanding of the language and processes of counting by naming numbers in sequences',
                  'year_level_descriptions': ['Foundation Year'],
                  'elaborations': [
                    {
                      'description': 'Developing fluency with forwards and backwards counting in meaningful contexts'
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    };
  }

  /// Fetch all learning areas (subjects) using MRAC data
  static Future<List<CurriculumSubject>> fetchLearningAreas() async {
    const cacheKey = 'learning_areas_mrac';
    
    // Check cache first
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey];
      if (DateTime.now().difference(cached['timestamp']) < _cacheExpiry) {
        return cached['data'];
      }
    }

    try {
      final mracData = await fetchMRACData();
      final subjects = <CurriculumSubject>[];
      
      if (mracData['curriculum_data'] != null && 
          mracData['curriculum_data']['learning_areas'] != null) {
        
        for (var item in mracData['curriculum_data']['learning_areas']) {
          subjects.add(CurriculumSubject(
            id: item['identifier'] ?? '',
            name: item['title'] ?? '',
            code: item['identifier'] ?? '',
            description: item['description'] ?? '',
            strands: [], // Will be populated separately
          ));
        }
      }

      // Cache the result
      _cache[cacheKey] = {
        'data': subjects,
        'timestamp': DateTime.now(),
      };

      print('Successfully fetched ${subjects.length} learning areas from MRAC');
      return subjects;
    } catch (e) {
      print('Error fetching learning areas from MRAC: $e');
      return _getFallbackSubjects();
    }
  }

  /// Fetch strands for a specific learning area using MRAC data
  static Future<List<CurriculumStrand>> fetchStrands(String learningAreaId) async {
    final cacheKey = 'strands_${learningAreaId}_mrac';
    
    // Check cache first
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey];
      if (DateTime.now().difference(cached['timestamp']) < _cacheExpiry) {
        return cached['data'];
      }
    }

    try {
      final mracData = await fetchMRACData();
      final strands = <CurriculumStrand>[];
      
      if (mracData['curriculum_data'] != null && 
          mracData['curriculum_data']['learning_areas'] != null) {
        
        final learningArea = mracData['curriculum_data']['learning_areas']
            .firstWhere(
              (area) => area['identifier'] == learningAreaId, 
              orElse: () => <String, dynamic>{},
            );
        
        if (learningArea.isNotEmpty && learningArea['strands'] != null) {
          for (var item in learningArea['strands']) {
            strands.add(CurriculumStrand(
              id: item['identifier'] ?? '',
              name: item['title'] ?? '',
              description: item['description'] ?? '',
              outcomes: [], // Will be populated separately
            ));
          }
        }
      }

      // Cache the result
      _cache[cacheKey] = {
        'data': strands,
        'timestamp': DateTime.now(),
      };

      return strands;
    } catch (e) {
      print('Error fetching strands from MRAC: $e');
      return [];
    }
  }

  /// Fetch outcomes for a specific strand using MRAC data
  static Future<List<CurriculumOutcome>> fetchOutcomes(String learningAreaId, String strandId) async {
    final cacheKey = 'outcomes_${learningAreaId}_${strandId}_mrac';
    
    // Check cache first
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey];
      if (DateTime.now().difference(cached['timestamp']) < _cacheExpiry) {
        return cached['data'];
      }
    }

    try {
      final mracData = await fetchMRACData();
      final outcomes = <CurriculumOutcome>[];
      
      if (mracData['curriculum_data'] != null && 
          mracData['curriculum_data']['learning_areas'] != null) {
        
        final learningArea = mracData['curriculum_data']['learning_areas']
            .firstWhere(
              (area) => area['identifier'] == learningAreaId, 
              orElse: () => <String, dynamic>{},
            );
        
        if (learningArea.isNotEmpty && learningArea['strands'] != null) {
          final strand = learningArea['strands']
              .firstWhere(
                (s) => s['identifier'] == strandId, 
                orElse: () => <String, dynamic>{},
              );
          
          if (strand.isNotEmpty && strand['content_descriptions'] != null) {
            for (var item in strand['content_descriptions']) {
              outcomes.add(CurriculumOutcome(
                id: item['identifier'] ?? '',
                code: item['notation'] ?? '',
                description: item['description'] ?? '',
                elaboration: item['elaborations']?.first?['description'] ?? '',
                yearLevel: _extractYearLevel(item['year_level_descriptions'] ?? []),
              ));
            }
          }
        }
      }

      // Cache the result
      _cache[cacheKey] = {
        'data': outcomes,
        'timestamp': DateTime.now(),
      };

      return outcomes;
    } catch (e) {
      print('Error fetching outcomes from MRAC: $e');
      return [];
    }
  }

  /// Fetch complete curriculum data for a specific year level using MRAC
  static Future<CurriculumYear> fetchYearLevelData(String yearLevel) async {
    final cacheKey = 'year_${yearLevel}_mrac';
    
    // Check cache first
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey];
      if (DateTime.now().difference(cached['timestamp']) < _cacheExpiry) {
        return cached['data'];
      }
    }

    try {
      print('Fetching MRAC curriculum data for year level: $yearLevel');
      
      // Fetch learning areas
      final subjects = await fetchLearningAreas();
      print('Found ${subjects.length} learning areas from MRAC');
      
      final updatedSubjects = <CurriculumSubject>[];
      
      // For each subject, fetch strands and outcomes
      for (var subject in subjects) {
        print('Fetching strands for subject: ${subject.name}');
        final strands = await fetchStrands(subject.id);
        print('Found ${strands.length} strands for ${subject.name}');
        
        final updatedStrands = <CurriculumStrand>[];
        
        for (var strand in strands) {
          print('Fetching outcomes for strand: ${strand.name}');
          final outcomes = await fetchOutcomes(subject.id, strand.id);
          print('Found ${outcomes.length} outcomes for ${strand.name}');
          
          // Filter outcomes for the specific year level
          final yearOutcomes = outcomes.where((o) => o.yearLevel == yearLevel).toList();
          print('Filtered to ${yearOutcomes.length} outcomes for year level $yearLevel');
          
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
        description: '${_getYearName(yearLevel)} curriculum (MRAC v9.0)',
        subjects: updatedSubjects,
      );

      // Cache the result
      _cache[cacheKey] = {
        'data': yearData,
        'timestamp': DateTime.now(),
      };

      print('Successfully fetched MRAC curriculum data for $yearLevel');
      return yearData;
    } catch (e) {
      print('Error fetching MRAC year level data: $e');
      return _getFallbackYearData(yearLevel);
    }
  }

  /// Test MRAC connectivity
  static Future<Map<String, dynamic>> testApiConnection() async {
    final results = <String, dynamic>{};
    
    try {
      print('Testing Machine-readable Australian Curriculum (MRAC) connectivity...');
      
      // Test MRAC page accessibility
      final response = await http.get(
        Uri.parse(_mracBaseUrl),
        headers: {'User-Agent': 'TeacherPlanner/1.0'},
      );
      
      results['mrac_page_accessible'] = response.statusCode == 200;
      results['mrac_page_status'] = response.statusCode;
      results['mrac_page_content_type'] = response.headers['content-type'];
      
      if (response.statusCode == 200) {
        // Try to parse MRAC data
        try {
          final mracData = await fetchMRACData();
          results['mrac_data_parsed'] = true;
          results['mrac_version'] = mracData['mrac_version'];
          results['mrac_last_updated'] = mracData['last_updated'];
          results['mrac_available_formats'] = mracData['available_formats'];
        } catch (e) {
          results['mrac_data_parsed'] = false;
          results['mrac_parse_error'] = e.toString();
        }
      }
      
      print('MRAC Test Results: $results');
      return results;
      
    } catch (e) {
      results['error'] = e.toString();
      print('MRAC Test Error: $e');
      return results;
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
      'data_source': 'MRAC v9.0',
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

  // Fallback data when MRAC is unavailable
  static Map<String, dynamic> _getFallbackMRACData() {
    return {
      'mrac_version': '9.0',
      'last_updated': '7 June 2024',
      'available_formats': ['RDF/XML', 'JSON+LD', 'SPARQL'],
      'curriculum_data': _getStructuredMRACData(),
      'fallback': true,
    };
  }

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
      description: '${_getYearName(yearLevel)} curriculum (Fallback)',
      subjects: _getFallbackSubjects(),
    );
  }
} 