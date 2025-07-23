// lib/services/curriculum_service.dart

import 'package:flutter/material.dart';
import '../models/curriculum_models.dart';
import 'supabase_curriculum_service.dart';

class CurriculumService extends ChangeNotifier {
  // Data storage
  Map<String, CurriculumYear> _curriculumData = {};
  bool _isLoading = false;
  String? _error;
  bool _useSupabase = true; // Default to Supabase

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get useSupabase => _useSupabase;
  Map<String, CurriculumYear> get curriculumData => _curriculumData;

  /// Initialize the curriculum service
  Future<void> initialize() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_useSupabase) {
        await _initializeSupabase();
      } else {
        await _initializeLocalData();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      print('Error initializing curriculum service: $e');
    }
  }

  /// Initialize Supabase curriculum database
  Future<void> _initializeSupabase() async {
    try {
      print('Initializing Supabase curriculum service...');
      
      // Test connection by fetching years
      final years = await SupabaseCurriculumService.getYears();
      print('Supabase curriculum service initialized successfully. Found ${years.length} years.');
    } catch (e) {
      print('Error initializing Supabase: $e');
      // Fallback to local data if Supabase fails
      await _initializeLocalData();
    }
  }

  /// Initialize local curriculum data
  Future<void> _initializeLocalData() async {
    print('Using local curriculum data...');
    // Local data is already loaded in the models
  }

  /// Toggle between Supabase and local data
  Future<void> toggleDataSource() async {
    _useSupabase = !_useSupabase;
    await initialize();
  }

  /// Fetch curriculum data for a specific year level
  Future<CurriculumYear?> fetchYearLevelData(String yearLevel) async {
    try {
      // Check cache first
      if (_curriculumData.containsKey(yearLevel)) {
        return _curriculumData[yearLevel];
      }

      _isLoading = true;
      notifyListeners();

      CurriculumYear? yearData;

      if (_useSupabase) {
        yearData = await _fetchSupabaseYearData(yearLevel);
      } else {
        yearData = _getLocalYearData(yearLevel);
      }

      if (yearData != null) {
        _curriculumData[yearLevel] = yearData;
      }

      _isLoading = false;
      notifyListeners();

      return yearData;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      print('Error fetching year level data: $e');
      return null;
    }
  }

  /// Fetch year data from Supabase
  Future<CurriculumYear?> _fetchSupabaseYearData(String yearLevel) async {
    try {
      // Get the year info
      final years = await SupabaseCurriculumService.getYears();
      final yearInfo = years.firstWhere((y) => y.id == yearLevel);
      
      // Get subjects for this specific year
      final subjects = await SupabaseCurriculumService.getSubjectsForYear(yearInfo.name);
      
      // Convert to CurriculumYear format
      return CurriculumYear(
        id: yearInfo.id,
        name: yearInfo.name,
        description: yearInfo.description ?? '',
        subjects: subjects.map((s) => CurriculumSubject(
          id: s.id,
          name: s.name,
          code: s.code ?? '',
          description: s.description ?? '',
          strands: [], // Will be populated separately if needed
        )).toList(),
      );
    } catch (e) {
      print('Error fetching Supabase year data: $e');
      return null;
    }
  }

  /// Fetch all year levels
  Future<List<CurriculumYear>> fetchAllYearLevels() async {
    try {
      if (_useSupabase) {
        final years = await SupabaseCurriculumService.getYears();
        return years.map((y) => CurriculumYear(
          id: y.id,
          name: y.name,
          description: y.description ?? '',
          subjects: [],
        )).toList();
      } else {
        return _getLocalYearLevels();
      }
    } catch (e) {
      print('Error fetching year levels: $e');
      return [];
    }
  }

  /// Fetch all subjects
  Future<List<CurriculumSubject>> fetchAllSubjects() async {
    try {
      if (_useSupabase) {
        // Get subjects for the default year level (Foundation to Year 10)
        final subjects = await SupabaseCurriculumService.getSubjectsForYear('Foundation to Year 10');
        return subjects.map((s) => CurriculumSubject(
          id: s.id,
          name: s.name,
          code: s.code ?? '',
          description: s.description ?? '',
          strands: [],
        )).toList();
      } else {
        return _getLocalSubjects();
      }
    } catch (e) {
      print('Error fetching subjects: $e');
      return [];
    }
  }

  /// Search outcomes by keyword
  Future<List<CurriculumOutcome>> searchOutcomes(String keyword) async {
    try {
      if (_useSupabase) {
        final outcomes = await SupabaseCurriculumService.searchOutcomes(keyword);
        return outcomes.map((o) => CurriculumOutcome(
          id: o.id,
          code: o.code ?? '',
          description: o.description ?? '',
          elaboration: o.elaboration ?? '',
          yearLevel: o.yearLevel ?? '',
        )).toList();
      } else {
        return _searchLocalOutcomes(keyword);
      }
    } catch (e) {
      print('Error searching outcomes: $e');
      return [];
    }
  }

  /// Test connectivity
  Future<Map<String, dynamic>> testConnection() async {
    try {
      if (_useSupabase) {
        final years = await SupabaseCurriculumService.getYears();
        final subjects = await SupabaseCurriculumService.getSubjectsForYear('Foundation to Year 10');
        return {
          'supabase_connected': true,
          'data_source': 'Supabase',
          'years_count': years.length,
          'subjects_count': subjects.length,
          'message': 'Successfully connected to Supabase',
        };
      } else {
        return {
          'local_data': true,
          'data_source': 'Local',
          'message': 'Using local curriculum data',
        };
      }
    } catch (e) {
      return {
        'error': e.toString(),
        'data_source': _useSupabase ? 'Supabase' : 'Local',
      };
    }
  }

  /// Clear cache
  void clearCache() {
    _curriculumData.clear();
    notifyListeners();
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'entries': _curriculumData.length,
      'keys': _curriculumData.keys.toList(),
      'data_source': _useSupabase ? 'Supabase' : 'Local',
    };
  }

  /// Get all available curriculum years
  List<CurriculumYear> getCurriculumYears() {
    return [
      CurriculumYear(id: 'foundation', name: 'Foundation Year', description: 'Foundation Year curriculum', subjects: []),
      CurriculumYear(id: 'year1', name: 'Year 1', description: 'Year 1 curriculum', subjects: []),
      CurriculumYear(id: 'year2', name: 'Year 2', description: 'Year 2 curriculum', subjects: []),
      CurriculumYear(id: 'year3', name: 'Year 3', description: 'Year 3 curriculum', subjects: []),
      CurriculumYear(id: 'year4', name: 'Year 4', description: 'Year 4 curriculum', subjects: []),
      CurriculumYear(id: 'year5', name: 'Year 5', description: 'Year 5 curriculum', subjects: []),
      CurriculumYear(id: 'year6', name: 'Year 6', description: 'Year 6 curriculum', subjects: []),
      CurriculumYear(id: 'year7', name: 'Year 7', description: 'Year 7 curriculum', subjects: []),
      CurriculumYear(id: 'year8', name: 'Year 8', description: 'Year 8 curriculum', subjects: []),
      CurriculumYear(id: 'year9', name: 'Year 9', description: 'Year 9 curriculum', subjects: []),
      CurriculumYear(id: 'year10', name: 'Year 10', description: 'Year 10 curriculum', subjects: []),
    ];
  }

  /// Get curriculum data for a specific year level
  Future<CurriculumYear> getCurriculumYear(String yearId) async {
    return await fetchYearLevelData(yearId) ?? _getLocalYearData(yearId) ?? CurriculumYear(
      id: yearId,
      name: _getYearName(yearId),
      description: '${_getYearName(yearId)} curriculum',
      subjects: [],
    );
  }

  /// Get selected outcomes by their IDs
  List<CurriculumOutcome> getSelectedOutcomes(List<String> outcomeIds) {
    final outcomes = <CurriculumOutcome>[];
    
    // Search through all cached years
    for (var year in _curriculumData.values) {
      for (var subject in year.subjects) {
        for (var strand in subject.strands) {
          for (var outcome in strand.outcomes) {
            if (outcomeIds.contains(outcome.id)) {
              outcomes.add(outcome);
            }
          }
        }
      }
    }

    // If not found in cache, search in local data
    if (outcomes.length != outcomeIds.length) {
      final localOutcomes = _getLocalOutcomes(outcomeIds);
      for (var outcome in localOutcomes) {
        if (!outcomes.any((o) => o.id == outcome.id)) {
          outcomes.add(outcome);
        }
      }
    }

    return outcomes;
  }

  // Local data methods
  CurriculumYear? _getLocalYearData(String yearLevel) {
    // This would return local curriculum data
    // For now, return a basic structure
    return CurriculumYear(
      id: yearLevel,
      name: _getYearName(yearLevel),
      description: '${_getYearName(yearLevel)} curriculum (Local)',
      subjects: _getLocalSubjects(),
    );
  }

  List<CurriculumYear> _getLocalYearLevels() {
    return [
      'foundation', 'year1', 'year2', 'year3', 'year4', 'year5',
      'year6', 'year7', 'year8', 'year9', 'year10'
    ].map((level) => CurriculumYear(
      id: level,
      name: _getYearName(level),
      description: '${_getYearName(level)} curriculum (Local)',
      subjects: [],
    )).toList();
  }

  List<CurriculumSubject> _getLocalSubjects() {
    return [
      CurriculumSubject(
        id: 'english',
        name: 'English',
        code: 'ACELY1646',
        description: 'English learning area',
        strands: [
          CurriculumStrand(
            id: 'english_language',
            name: 'Language',
            description: 'Language strand',
            outcomes: [
              CurriculumOutcome(
                id: 'ACELA1428',
                code: 'ACELA1428',
                description: 'Recognise that texts are made up of words and groups of words that make meaning',
                elaboration: 'Exploring spoken, written and multimodal texts and identifying words, word groups and sentences',
                yearLevel: 'foundation',
              ),
              CurriculumOutcome(
                id: 'ACELA1429',
                code: 'ACELA1429',
                description: 'Understand that punctuation is a feature of written text different from letters',
                elaboration: 'Recognising how full stops and capital letters are used to separate and mark sentences',
                yearLevel: 'foundation',
              ),
            ],
          ),
          CurriculumStrand(
            id: 'english_literature',
            name: 'Literature',
            description: 'Literature strand',
            outcomes: [
              CurriculumOutcome(
                id: 'ACELT1575',
                code: 'ACELT1575',
                description: 'Recognise that texts are created by authors who tell stories and share experiences',
                elaboration: 'Recognising that there are storytellers in all cultures',
                yearLevel: 'foundation',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubject(
        id: 'mathematics',
        name: 'Mathematics',
        code: 'ACMNA001',
        description: 'Mathematics learning area',
        strands: [
          CurriculumStrand(
            id: 'math_number',
            name: 'Number and Algebra',
            description: 'Number and algebra strand',
            outcomes: [
              CurriculumOutcome(
                id: 'ACMNA001',
                code: 'ACMNA001',
                description: 'Establish understanding of the language and processes of counting by naming numbers in sequences',
                elaboration: 'Developing fluency with forwards and backwards counting in meaningful contexts',
                yearLevel: 'foundation',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubject(
        id: 'science',
        name: 'Science',
        code: 'ACSSU001',
        description: 'Science learning area',
        strands: [
          CurriculumStrand(
            id: 'science_understanding',
            name: 'Science Understanding',
            description: 'Science understanding strand',
            outcomes: [
              CurriculumOutcome(
                id: 'ACSSU001',
                code: 'ACSSU001',
                description: 'Living things have basic needs, including food and water',
                elaboration: 'Identifying the needs of humans such as warmth, food and water, using students\' own experiences',
                yearLevel: 'foundation',
              ),
            ],
          ),
        ],
      ),
    ];
  }

  List<CurriculumOutcome> _searchLocalOutcomes(String keyword) {
    final allOutcomes = <CurriculumOutcome>[];
    
    for (var subject in _getLocalSubjects()) {
      for (var strand in subject.strands) {
        allOutcomes.addAll(strand.outcomes);
      }
    }

    return allOutcomes.where((outcome) {
      final searchText = keyword.toLowerCase();
      return outcome.description.toLowerCase().contains(searchText) ||
             outcome.code.toLowerCase().contains(searchText) ||
             outcome.elaboration.toLowerCase().contains(searchText);
    }).toList();
  }

  List<CurriculumOutcome> _getLocalOutcomes(List<String> outcomeIds) {
    final outcomes = <CurriculumOutcome>[];
    
    // Search through local curriculum data
    for (var subject in _getLocalSubjects()) {
      for (var strand in subject.strands) {
        for (var outcome in strand.outcomes) {
          if (outcomeIds.contains(outcome.id)) {
            outcomes.add(outcome);
          }
        }
      }
    }
    
    return outcomes;
  }

  String _getYearName(String yearLevel) {
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
} 