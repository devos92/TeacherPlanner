// lib/services/curriculum_service.dart

import '../models/curriculum_models.dart';
import 'curriculum_api_service.dart';

class CurriculumService {
  static final CurriculumService _instance = CurriculumService._internal();
  factory CurriculumService() => _instance;
  CurriculumService._internal();

  // Cache for curriculum data
  Map<String, CurriculumYear> _yearCache = {};
  bool _useApiData = true; // Toggle between API and local data

  /// Get all available curriculum years
  List<CurriculumYear> getCurriculumYears() {
    if (_useApiData) {
      // Return year levels that can be fetched from API
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
    } else {
      return _getLocalCurriculumYears();
    }
  }

  /// Get curriculum data for a specific year level
  Future<CurriculumYear> getCurriculumYear(String yearId) async {
    if (_useApiData) {
      // Check cache first
      if (_yearCache.containsKey(yearId)) {
        return _yearCache[yearId]!;
      }

      try {
        // Fetch from API
        final yearData = await CurriculumApiService.fetchYearLevelData(yearId);
        _yearCache[yearId] = yearData;
        return yearData;
      } catch (e) {
        print('Error fetching curriculum data from API: $e');
        // Fallback to local data
        return _getLocalCurriculumYear(yearId);
      }
    } else {
      return _getLocalCurriculumYear(yearId);
    }
  }

  /// Get selected outcomes by their IDs
  List<CurriculumOutcome> getSelectedOutcomes(List<String> outcomeIds) {
    final outcomes = <CurriculumOutcome>[];
    
    // Search through all cached years
    for (var year in _yearCache.values) {
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

  /// Toggle between API and local data
  void setUseApiData(bool useApi) {
    _useApiData = useApi;
    if (!useApi) {
      _yearCache.clear(); // Clear API cache when switching to local data
    }
  }

  /// Clear the cache
  void clearCache() {
    _yearCache.clear();
    if (_useApiData) {
      CurriculumApiService.clearCache();
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'useApiData': _useApiData,
      'cachedYears': _yearCache.keys.toList(),
      'apiCacheStats': _useApiData ? CurriculumApiService.getCacheStats() : null,
    };
  }

  // Local curriculum data (fallback)
  CurriculumYear _getLocalCurriculumYear(String yearId) {
    switch (yearId) {
      case 'foundation':
        return CurriculumYear(
          id: 'foundation',
          name: 'Foundation Year',
          description: 'Foundation Year curriculum',
          subjects: [
            CurriculumSubject(
              id: 'english',
              name: 'English',
              code: 'ACELY1646',
              description: 'English learning area',
              strands: [
                CurriculumStrand(
                  id: 'language',
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
                  id: 'literature',
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
                  id: 'number',
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
          ],
        );
      case 'year1':
        return CurriculumYear(
          id: 'year1',
          name: 'Year 1',
          description: 'Year 1 curriculum',
          subjects: [
            CurriculumSubject(
              id: 'english',
              name: 'English',
              code: 'ACELY1656',
              description: 'English learning area',
              strands: [
                CurriculumStrand(
                  id: 'language',
                  name: 'Language',
                  description: 'Language strand',
                  outcomes: [
                    CurriculumOutcome(
                      id: 'ACELA1452',
                      code: 'ACELA1452',
                      description: 'Explore differences in words that represent people, places and things',
                      elaboration: 'Learning that nouns represent people, places, things and ideas',
                      yearLevel: 'year1',
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      default:
        return CurriculumYear(
          id: yearId,
          name: _getYearName(yearId),
          description: '${_getYearName(yearId)} curriculum',
          subjects: [],
        );
    }
  }

  List<CurriculumYear> _getLocalCurriculumYears() {
    return [
      _getLocalCurriculumYear('foundation'),
      _getLocalCurriculumYear('year1'),
      // Add more years as needed
    ];
  }

  List<CurriculumOutcome> _getLocalOutcomes(List<String> outcomeIds) {
    final outcomes = <CurriculumOutcome>[];
    
    // Search through local curriculum data
    for (var year in _getLocalCurriculumYears()) {
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
    
    return outcomes;
  }

  String _getYearName(String yearId) {
    switch (yearId) {
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
        return yearId;
    }
  }
} 