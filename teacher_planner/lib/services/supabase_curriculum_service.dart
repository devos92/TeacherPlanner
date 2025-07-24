// // lib/services/supabase_curriculum_service.dart

// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../config/supabase_config.dart';

// class CurriculumData {
//   final String id;
//   final String name;
//   final String? code;
//   final String? description;
//   final String? yearLevel;
//   final String? subjectCode;
//   final String? strandId;
//   final String? strandName;
//   final String? subjectName;
//   final String? contentType;
//   final String? elaboration;

//   CurriculumData({
//     required this.id,
//     required this.name,
//     this.code,
//     this.description,
//     this.yearLevel,
//     this.subjectCode,
//     this.strandId,
//     this.strandName,
//     this.subjectName,
//     this.contentType,
//     this.elaboration,
//   });

//   factory CurriculumData.fromJson(Map<String, dynamic> json) {
//     return CurriculumData(
//       id: json['id'] ?? '',
//       name: json['name'] ?? json['description'] ?? '',
//       code: json['code'],
//       description: json['description'],
//       yearLevel: json['year_level'],
//       subjectCode: json['subject_code'],
//       strandId: json['strand_id'],
//       strandName: json['strand_name'],
//       subjectName: json['subject_name'],
//       contentType: json['content_type'],
//       elaboration: json['elaboration'],
//     );
//   }
// }

// class SupabaseCurriculumService {
//   static final SupabaseClient _supabase = Supabase.instance.client;

//   // Get all year levels from the curriculum data
//   static Future<List<CurriculumData>> getYears() async {
//     try {
//       print('Fetching years from curriculum_content_descriptions...');
      
//       // Extract unique year levels from the curriculum data
//       final response = await _supabase
//           .from('curriculum_content_descriptions')
//           .select('year_level')
//           .not('year_level', 'is', null);
      
//       print('Raw year response: $response');
      
//       final yearLevels = (response as List)
//           .map((json) => json['year_level'] as String)
//           .toSet()
//           .toList()
//         ..sort();
      
//       print('Extracted year levels: $yearLevels');
      
//       // Parse the year levels to get individual years
//       List<CurriculumData> individualYears = [];
      
//       for (String yearLevel in yearLevels) {
//         if (yearLevel.contains('Foundation')) {
//           individualYears.add(CurriculumData(
//             id: 'foundation',
//             name: 'Foundation',
//             description: 'Foundation Year',
//           ));
//         } else if (yearLevel.contains('Year')) {
//           // Extract year numbers from strings like "Year 1", "Year 2", etc.
//           final yearMatch = RegExp(r'Year (\d+)').firstMatch(yearLevel);
//           if (yearMatch != null) {
//             final yearNum = yearMatch.group(1);
//             individualYears.add(CurriculumData(
//               id: 'year_$yearNum',
//               name: 'Year $yearNum',
//               description: 'Year $yearNum',
//             ));
//           }
//         }
//       }
      
//       // Remove duplicates and sort
//       individualYears = individualYears.toSet().toList()
//         ..sort((a, b) => a.id.compareTo(b.id));
      
//       print('Individual years: ${individualYears.map((y) => y.name).toList()}');
      
//       return individualYears;
//     } catch (e) {
//       print('Error fetching years: $e');
//       // Return default year levels
//       return [
//         CurriculumData(id: 'foundation', name: 'Foundation', description: 'Foundation'),
//         CurriculumData(id: 'year_1', name: 'Year 1', description: 'Year 1'),
//         CurriculumData(id: 'year_2', name: 'Year 2', description: 'Year 2'),
//         CurriculumData(id: 'year_3', name: 'Year 3', description: 'Year 3'),
//         CurriculumData(id: 'year_4', name: 'Year 4', description: 'Year 4'),
//         CurriculumData(id: 'year_5', name: 'Year 5', description: 'Year 5'),
//         CurriculumData(id: 'year_6', name: 'Year 6', description: 'Year 6'),
//         CurriculumData(id: 'year_7', name: 'Year 7', description: 'Year 7'),
//         CurriculumData(id: 'year_8', name: 'Year 8', description: 'Year 8'),
//         CurriculumData(id: 'year_9', name: 'Year 9', description: 'Year 9'),
//         CurriculumData(id: 'year_10', name: 'Year 10', description: 'Year 10'),
//       ];
//     }
//   }

//   // Get subjects for a specific year level
//   static Future<List<CurriculumData>> getSubjectsForYear(String yearLevel) async {
//     try {
//       print('Fetching subjects for year: $yearLevel');
      
//       // Convert year level to search pattern for content descriptions
//       String searchPattern;
//       if (yearLevel == 'Foundation') {
//         searchPattern = 'Foundation year';
//       } else if (yearLevel.startsWith('Year ')) {
//         searchPattern = yearLevel; // "Year 1", "Year 2", etc.
//       } else {
//         searchPattern = yearLevel;
//       }
      
//       print('Searching for pattern: $searchPattern');
      
//       // Get unique subjects that have content for this specific year
//       final response = await _supabase
//           .from('curriculum_content_descriptions')
//           .select('subject_code')
//           .ilike('description', '%$searchPattern%')
//           .not('subject_code', 'is', null);
      
//       print('Raw subjects for year response: $response');
      
//       final subjectCodes = (response as List)
//           .map((json) => json['subject_code'] as String)
//           .toSet()
//           .toList()
//         ..sort();
      
//       print('Subject codes for year $yearLevel: $subjectCodes');
      
//       // Map subject codes to full names
//       final subjectMap = {
//         'ART': 'The Arts',
//         'ENG': 'English',
//         'MAT': 'Mathematics',
//         'SCI': 'Science',
//         'HASS': 'Humanities and Social Sciences',
//         'HPE': 'Health and Physical Education',
//         'TEC': 'Technologies',
//         'LAN': 'Languages',
//       };
      
//       final subjects = subjectCodes.map((code) => CurriculumData(
//         id: code,
//         name: subjectMap[code] ?? code,
//         code: code,
//         description: subjectMap[code] ?? code,
//         yearLevel: yearLevel,
//       )).toList();
      
//       print('Returning subjects for year $yearLevel: ${subjects.map((s) => s.name).toList()}');
      
//       return subjects;
//     } catch (e) {
//       print('Error fetching subjects for year $yearLevel: $e');
//       return [];
//     }
//   }

//   // Get strands for a specific subject and year level
//   static Future<List<CurriculumData>> getStrandsForSubjectAndYear(String subjectCode, String yearLevel) async {
//     try {
//       print('Fetching strands for subject: $subjectCode, year: $yearLevel');
      
//       // Convert year level to search pattern for content descriptions
//       String searchPattern;
//       if (yearLevel == 'Foundation') {
//         searchPattern = 'Foundation year';
//       } else if (yearLevel.startsWith('Year ')) {
//         searchPattern = yearLevel; // "Year 1", "Year 2", etc.
//       } else {
//         searchPattern = yearLevel;
//       }
      
//       print('Searching for pattern: $searchPattern');
      
//       // Get unique strands that have content for this subject and specific year
//       final response = await _supabase
//           .from('curriculum_content_descriptions')
//           .select('strand_id')
//           .eq('subject_code', subjectCode)
//           .ilike('description', '%$searchPattern%')
//           .not('strand_id', 'is', null);
      
//       print('Raw strands response: $response');
      
//       final strandIds = (response as List)
//           .map((json) => json['strand_id'] as String)
//           .toSet()
//           .toList();
      
//       print('Strand IDs for subject $subjectCode and year $yearLevel: $strandIds');
      
//       // Get strand details from strands table
//       if (strandIds.isNotEmpty) {
//         final strandResponse = await _supabase
//             .from('curriculum_strands')
//             .select('*')
//             .inFilter('id', strandIds)
//             .order('name');
        
//         print('Strand details response: $strandResponse');
        
//         final strands = (strandResponse as List)
//             .map((json) => CurriculumData(
//               id: json['id'] ?? '',
//               name: json['name'] ?? '',
//               description: json['description'] ?? '',
//               subjectCode: json['subject_id'],
//               yearLevel: yearLevel,
//             ))
//             .toList();
        
//         print('Returning strands: ${strands.map((s) => '${s.id}: ${s.name}').toList()}');
        
//         return strands;
//       }
      
//       return [];
//     } catch (e) {
//       print('Error fetching strands for subject $subjectCode and year $yearLevel: $e');
//       return [];
//     }
//   }

//   // Helper method to clean curriculum text
//   static String _cleanCurriculumText(String text) {
//     return text
//         .replaceAll('Â', '')
//         .replaceAll('â"', '"')
//         .replaceAll('â', '"')
//         .replaceAll('â', '"')
//         .trim();
//   }

//   // Get outcomes for a specific strand and year level
//   static Future<List<CurriculumData>> getOutcomesForStrandAndYear(
//     String strandId, 
//     String yearLevel
//   ) async {
//     try {
//       print('Fetching outcomes for strand: $strandId, year: $yearLevel');
      
//       // Convert year level to search pattern for content descriptions
//       String searchPattern;
//       if (yearLevel == 'Foundation') {
//         searchPattern = 'Foundation year';
//       } else if (yearLevel.startsWith('Year ')) {
//         searchPattern = yearLevel; // "Year 1", "Year 2", etc.
//       } else {
//         searchPattern = yearLevel;
//       }
      
//       print('Searching for pattern: $searchPattern');
      
//       // Get content descriptions for this strand and specific year
//       final response = await _supabase
//           .from('curriculum_content_descriptions')
//           .select('*')
//           .eq('strand_id', strandId)
//           .ilike('description', '%$searchPattern%')
//           .order('code');
      
//       print('Raw outcomes response: ${response.length} items');
      
//       final outcomes = (response as List)
//           .map((json) => CurriculumData(
//             id: json['id'] ?? '',
//             name: _cleanCurriculumText(json['description'] ?? ''),
//             code: json['code'],
//             description: _cleanCurriculumText(json['description'] ?? ''),
//             yearLevel: json['year_level'],
//             subjectCode: json['subject_code'],
//             strandId: json['strand_id'],
//           ))
//           .toList();
      
//       print('Returning outcomes: ${outcomes.length} items');
      
//       return outcomes;
//     } catch (e) {
//       print('Error fetching outcomes for strand $strandId and year $yearLevel: $e');
//       return [];
//     }
//   }

//   // Get all outcomes for a specific year level
//   static Future<List<CurriculumData>> getOutcomesForYear(String yearLevel) async {
//     try {
//       final response = await _supabase
//           .from('curriculum_content_descriptions')
//           .select('*')
//           .eq('year_level', yearLevel)
//           .order('code');
      
//       return (response as List)
//           .map((json) => CurriculumData.fromJson(json))
//           .toList();
//     } catch (e) {
//       print('Error fetching outcomes for year $yearLevel: $e');
//       return [];
//     }
//   }

//   // Search outcomes by keyword
//   static Future<List<CurriculumData>> searchOutcomes(String keyword) async {
//     try {
//       final response = await _supabase
//           .from('curriculum_content_descriptions')
//           .select('*')
//           .or('description.ilike.%$keyword%,code.ilike.%$keyword%')
//           .order('code');
      
//       return (response as List)
//           .map((json) => CurriculumData.fromJson(json))
//           .toList();
//     } catch (e) {
//       print('Error searching outcomes: $e');
//       return [];
//     }
//   }

//   // Get outcomes by subject and year level
//   static Future<List<CurriculumData>> getOutcomesBySubjectAndYear(
//     String subjectCode, 
//     String yearLevel
//   ) async {
//     try {
//       final response = await _supabase
//           .from('curriculum_content_descriptions')
//           .select('*')
//           .eq('subject_code', subjectCode)
//           .eq('year_level', yearLevel)
//           .order('code');
      
//       return (response as List)
//           .map((json) => CurriculumData.fromJson(json))
//           .toList();
//     } catch (e) {
//       print('Error fetching outcomes for subject $subjectCode and year $yearLevel: $e');
//       return [];
//     }
//   }

//   // Get complete curriculum structure
//   static Future<Map<String, dynamic>> getCurriculumStructure() async {
//     try {
//       final years = await getYears();
//       final subjects = await getSubjectsForYear('Foundation to Year 10'); // Use default year
      
//       Map<String, dynamic> structure = {
//         'years': years,
//         'subjects': subjects,
//         'strands': <String, List<CurriculumData>>{},
//         'outcomes': <String, List<CurriculumData>>{},
//       };

//       // Get strands for each subject
//       for (var subject in subjects) {
//         final strands = await getStrandsForSubjectAndYear(subject.id, subject.yearLevel ?? 'Foundation to Year 10');
//         structure['strands'][subject.id] = strands;
//       }

//       // Get outcomes for each year
//       for (var year in years) {
//         final outcomes = await getOutcomesForYear(year.name);
//         structure['outcomes'][year.id] = outcomes;
//       }

//       return structure;
//     } catch (e) {
//       print('Error fetching curriculum structure: $e');
//       return {
//         'years': <CurriculumData>[],
//         'subjects': <CurriculumData>[],
//         'strands': <String, List<CurriculumData>>{},
//         'outcomes': <String, List<CurriculumData>>{},
//       };
//     }
//   }

//   // Test Supabase connectivity
//   static Future<Map<String, dynamic>> testConnection() async {
//     try {
//       print('Testing Supabase curriculum database connectivity...');
      
//       // Test basic connectivity
//       final years = await getYears();
//       final subjects = await getSubjectsForYear('Foundation to Year 10'); // Use default year
      
//       return {
//         'supabase_connected': true,
//         'years_count': years.length,
//         'subjects_count': subjects.length,
//         'message': 'Successfully connected to Supabase',
//       };
//     } catch (e) {
//       return {
//         'error': e.toString(),
//         'supabase_connected': false,
//       };
//     }
//   }

//   // Helper method to get default strands for subjects
//   static List<CurriculumData> _getDefaultStrandsForSubject(String subjectCode) {
//     switch (subjectCode) {
//       case 'ART':
//         return [
//           CurriculumData(id: 'the_arts_dance', name: 'Dance', subjectCode: subjectCode),
//           CurriculumData(id: 'the_arts_drama', name: 'Drama', subjectCode: subjectCode),
//           CurriculumData(id: 'the_arts_media_arts', name: 'Media Arts', subjectCode: subjectCode),
//           CurriculumData(id: 'the_arts_music', name: 'Music', subjectCode: subjectCode),
//           CurriculumData(id: 'the_arts_visual_arts', name: 'Visual Arts', subjectCode: subjectCode),
//         ];
//       case 'ENG':
//         return [
//           CurriculumData(id: 'english_language', name: 'Language', subjectCode: subjectCode),
//           CurriculumData(id: 'english_literature', name: 'Literature', subjectCode: subjectCode),
//           CurriculumData(id: 'english_literacy', name: 'Literacy', subjectCode: subjectCode),
//         ];
//       case 'MAT':
//         return [
//           CurriculumData(id: 'math_number_and_algebra', name: 'Number and Algebra', subjectCode: subjectCode),
//           CurriculumData(id: 'math_measurement_and_geometry', name: 'Measurement and Geometry', subjectCode: subjectCode),
//           CurriculumData(id: 'math_statistics_and_probability', name: 'Statistics and Probability', subjectCode: subjectCode),
//         ];
//       case 'SCI':
//         return [
//           CurriculumData(id: 'science_science_understanding', name: 'Science Understanding', subjectCode: subjectCode),
//           CurriculumData(id: 'science_science_as_a_human_endeavour', name: 'Science as a Human Endeavour', subjectCode: subjectCode),
//           CurriculumData(id: 'science_science_inquiry_skills', name: 'Science Inquiry Skills', subjectCode: subjectCode),
//         ];
//       default:
//         return [
//           CurriculumData(id: '${subjectCode.toLowerCase()}_strand', name: 'Main Strand', subjectCode: subjectCode),
//         ];
//     }
//   }
// }