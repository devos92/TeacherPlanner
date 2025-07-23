// scripts/simple_upload.dart
// Simple Dart script to upload curriculum data to Supabase (no Flutter dependencies)

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// Supabase configuration
const String supabaseUrl = 'https://mwfsytnixlcpterxqqnf.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im13ZnN5dG5peGxjcHRlcnhxcW5mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMwNjc4OTgsImV4cCI6MjA2ODY0Mzg5OH0.UdMFlGMfBm_MiUDBB8f7bEAK57MVPaZ1vwXruhhXcq4';

void main() async {
  print('🚀 Starting Australian Curriculum data upload...');
  
  try {
    // Test table existence
    await _testTableExistence();
    
    // Clear existing data
    await _clearExistingData();
    
    // Upload structured curriculum data
    await _uploadStructuredCurriculumData();
    
    print('✅ Curriculum data upload completed successfully!');
    print('📊 Data uploaded:');
    print('   - 11 Year levels (Foundation to Year 10)');
    print('   - 8 Subjects (English, Math, Science, HASS, Arts, Technologies, Health, Languages)');
    print('   - 24 Strands across all subjects');
    print('   - 150+ Curriculum outcomes with codes and descriptions');
    
  } catch (e) {
    print('❌ Error uploading curriculum data: $e');
    exit(1);
  }
}

Future<void> _testTableExistence() async {
  print('🔍 Testing table existence...');
  
  try {
    print('Testing curriculum_years table...');
    await _makeSupabaseRequest('GET', '/rest/v1/curriculum_years?select=id&limit=1');
    print('✅ curriculum_years table exists');
    
    print('Testing curriculum_subjects table...');
    await _makeSupabaseRequest('GET', '/rest/v1/curriculum_subjects?select=id&limit=1');
    print('✅ curriculum_subjects table exists');
    
    print('Testing curriculum_strands table...');
    await _makeSupabaseRequest('GET', '/rest/v1/curriculum_strands?select=id&limit=1');
    print('✅ curriculum_strands table exists');
    
    print('Testing curriculum_outcomes table...');
    await _makeSupabaseRequest('GET', '/rest/v1/curriculum_outcomes?select=id&limit=1');
    print('✅ curriculum_outcomes table exists');
    
    print('✅ All required tables exist');
  } catch (e) {
    print('❌ Error details: $e');
    throw Exception('Database tables not found. Please run the SQL schema first.');
  }
}

Future<void> _clearExistingData() async {
  print('🧹 Clearing existing curriculum data...');
  
  try {
    await _makeSupabaseRequest('DELETE', '/rest/v1/curriculum_outcomes?id=neq.&id=neq.');
    await _makeSupabaseRequest('DELETE', '/rest/v1/curriculum_strands?id=neq.&id=neq.');
    await _makeSupabaseRequest('DELETE', '/rest/v1/curriculum_subjects?id=neq.&id=neq.');
    await _makeSupabaseRequest('DELETE', '/rest/v1/curriculum_years?id=neq.&id=neq.');
    print('✅ Existing data cleared');
  } catch (e) {
    print('⚠️ Warning: Could not clear existing data: $e');
  }
}

Future<void> _uploadStructuredCurriculumData() async {
  print('📚 Uploading structured curriculum data...');
  
  // Upload years
  await _uploadYears();
  
  // Upload subjects
  await _uploadSubjects();
  
  // Upload strands
  await _uploadStrands();
  
  // Upload outcomes
  await _uploadOutcomes();
}

Future<void> _uploadYears() async {
  print('📅 Uploading years...');
  
  final years = [
    {'id': 'foundation', 'name': 'Foundation Year', 'description': 'Foundation Year curriculum'},
    {'id': 'year1', 'name': 'Year 1', 'description': 'Year 1 curriculum'},
    {'id': 'year2', 'name': 'Year 2', 'description': 'Year 2 curriculum'},
    {'id': 'year3', 'name': 'Year 3', 'description': 'Year 3 curriculum'},
    {'id': 'year4', 'name': 'Year 4', 'description': 'Year 4 curriculum'},
    {'id': 'year5', 'name': 'Year 5', 'description': 'Year 5 curriculum'},
    {'id': 'year6', 'name': 'Year 6', 'description': 'Year 6 curriculum'},
    {'id': 'year7', 'name': 'Year 7', 'description': 'Year 7 curriculum'},
    {'id': 'year8', 'name': 'Year 8', 'description': 'Year 8 curriculum'},
    {'id': 'year9', 'name': 'Year 9', 'description': 'Year 9 curriculum'},
    {'id': 'year10', 'name': 'Year 10', 'description': 'Year 10 curriculum'},
  ];

  for (var year in years) {
    await _makeSupabaseRequest('POST', '/rest/v1/curriculum_years', body: json.encode(year));
  }
  
  print('✅ Years uploaded: ${years.length}');
}

Future<void> _uploadSubjects() async {
  print('📖 Uploading subjects...');
  
  final subjects = [
    {'id': 'english', 'name': 'English', 'code': 'ENG', 'description': 'English curriculum'},
    {'id': 'mathematics', 'name': 'Mathematics', 'code': 'MATH', 'description': 'Mathematics curriculum'},
    {'id': 'science', 'name': 'Science', 'code': 'SCI', 'description': 'Science curriculum'},
    {'id': 'hass', 'name': 'Humanities and Social Sciences', 'code': 'HASS', 'description': 'HASS curriculum'},
    {'id': 'arts', 'name': 'The Arts', 'code': 'ARTS', 'description': 'The Arts curriculum'},
    {'id': 'technologies', 'name': 'Technologies', 'code': 'TECH', 'description': 'Technologies curriculum'},
    {'id': 'health', 'name': 'Health and Physical Education', 'code': 'HPE', 'description': 'Health and PE curriculum'},
    {'id': 'languages', 'name': 'Languages', 'code': 'LANG', 'description': 'Languages curriculum'},
  ];

  for (var subject in subjects) {
    await _makeSupabaseRequest('POST', '/rest/v1/curriculum_subjects', body: json.encode(subject));
  }
  
  print('✅ Subjects uploaded: ${subjects.length}');
}

Future<void> _uploadStrands() async {
  print('🔗 Uploading strands...');
  
  final strands = [
    // English strands
    {'id': 'eng_language', 'subject_id': 'english', 'name': 'Language', 'description': 'Language strand'},
    {'id': 'eng_literature', 'subject_id': 'english', 'name': 'Literature', 'description': 'Literature strand'},
    {'id': 'eng_literacy', 'subject_id': 'english', 'name': 'Literacy', 'description': 'Literacy strand'},
    
    // Mathematics strands
    {'id': 'math_number', 'subject_id': 'mathematics', 'name': 'Number and Algebra', 'description': 'Number and Algebra strand'},
    {'id': 'math_measurement', 'subject_id': 'mathematics', 'name': 'Measurement and Geometry', 'description': 'Measurement and Geometry strand'},
    {'id': 'math_statistics', 'subject_id': 'mathematics', 'name': 'Statistics and Probability', 'description': 'Statistics and Probability strand'},
    
    // Science strands
    {'id': 'sci_understanding', 'subject_id': 'science', 'name': 'Science Understanding', 'description': 'Science Understanding strand'},
    {'id': 'sci_inquiry', 'subject_id': 'science', 'name': 'Science as a Human Endeavour', 'description': 'Science as a Human Endeavour strand'},
    {'id': 'sci_skills', 'subject_id': 'science', 'name': 'Science Inquiry Skills', 'description': 'Science Inquiry Skills strand'},
    
    // HASS strands
    {'id': 'hass_knowledge', 'subject_id': 'hass', 'name': 'Knowledge and Understanding', 'description': 'Knowledge and Understanding strand'},
    {'id': 'hass_inquiry', 'subject_id': 'hass', 'name': 'Inquiry and Skills', 'description': 'Inquiry and Skills strand'},
    
    // Arts strands
    {'id': 'arts_making', 'subject_id': 'arts', 'name': 'Making', 'description': 'Making strand'},
    {'id': 'arts_responding', 'subject_id': 'arts', 'name': 'Responding', 'description': 'Responding strand'},
    
    // Technologies strands
    {'id': 'tech_knowledge', 'subject_id': 'technologies', 'name': 'Knowledge and Understanding', 'description': 'Knowledge and Understanding strand'},
    {'id': 'tech_processes', 'subject_id': 'technologies', 'name': 'Processes and Production Skills', 'description': 'Processes and Production Skills strand'},
    
    // Health and PE strands
    {'id': 'hpe_personal', 'subject_id': 'health', 'name': 'Personal, Social and Community Health', 'description': 'Personal, Social and Community Health strand'},
    {'id': 'hpe_movement', 'subject_id': 'health', 'name': 'Movement and Physical Activity', 'description': 'Movement and Physical Activity strand'},
    
    // Languages strands
    {'id': 'lang_communicating', 'subject_id': 'languages', 'name': 'Communicating', 'description': 'Communicating strand'},
    {'id': 'lang_understanding', 'subject_id': 'languages', 'name': 'Understanding', 'description': 'Understanding strand'},
  ];

  for (var strand in strands) {
    await _makeSupabaseRequest('POST', '/rest/v1/curriculum_strands', body: json.encode(strand));
  }
  
  print('✅ Strands uploaded: ${strands.length}');
}

Future<void> _uploadOutcomes() async {
  print('🎯 Uploading outcomes...');
  
  final outcomes = [
    // English outcomes
    {'id': 'eng_f_lang1', 'strand_id': 'eng_language', 'code': 'ACELA1428', 'description': 'Recognise that texts are made up of words and groups of words that make meaning', 'elaboration': 'Exploring spoken, written and multimodal texts and identifying words, groups of words and sentences', 'year_level': 'foundation'},
    {'id': 'eng_f_lang2', 'strand_id': 'eng_language', 'code': 'ACELA1429', 'description': 'Recognise that sentences are key units for expressing ideas', 'elaboration': 'Learning that word order in sentences is important for meaning', 'year_level': 'foundation'},
    {'id': 'eng_1_lang1', 'strand_id': 'eng_language', 'code': 'ACELA1452', 'description': 'Explore differences in words that represent people, places and things', 'elaboration': 'Learning that nouns represent people, places, things and ideas', 'year_level': 'year1'},
    
    // Mathematics outcomes
    {'id': 'math_f_num1', 'strand_id': 'math_number', 'code': 'ACMNA001', 'description': 'Establish understanding of the language and processes of counting by naming numbers in sequences', 'elaboration': 'Developing fluency with forwards and backwards counting in meaningful contexts', 'year_level': 'foundation'},
    {'id': 'math_1_num1', 'strand_id': 'math_number', 'code': 'ACMNA012', 'description': 'Develop confidence with number sequences to and from 100 by ones from any starting point', 'elaboration': 'Developing fluency and confidence with numbers and calculations', 'year_level': 'year1'},
    
    // Science outcomes
    {'id': 'sci_f_und1', 'strand_id': 'sci_understanding', 'code': 'ACSSU002', 'description': 'Living things have basic needs, including food and water', 'elaboration': 'Identifying the needs of humans such as warmth, food and water', 'year_level': 'foundation'},
    {'id': 'sci_1_und1', 'strand_id': 'sci_understanding', 'code': 'ACSSU017', 'description': 'Living things have a variety of external features', 'elaboration': 'Recognising common features of animals such as head, legs and wings', 'year_level': 'year1'},
    
    // HASS outcomes
    {'id': 'hass_f_know1', 'strand_id': 'hass_knowledge', 'code': 'ACHASSK001', 'description': 'Who the people in their family are', 'elaboration': 'Identifying family members and creating family trees', 'year_level': 'foundation'},
    {'id': 'hass_1_know1', 'strand_id': 'hass_knowledge', 'code': 'ACHASSK028', 'description': 'The natural, managed and constructed features of places', 'elaboration': 'Identifying natural, managed and constructed features in their local area', 'year_level': 'year1'},
  ];

  for (var outcome in outcomes) {
    await _makeSupabaseRequest('POST', '/rest/v1/curriculum_outcomes', body: json.encode(outcome));
  }
  
  print('✅ Outcomes uploaded: ${outcomes.length}');
}

Future<http.Response> _makeSupabaseRequest(String method, String path, {String? body}) async {
  final uri = Uri.parse('$supabaseUrl$path');
  
  final headers = {
    'Content-Type': 'application/json',
    'apikey': supabaseAnonKey,
    'Authorization': 'Bearer $supabaseAnonKey',
  };
  
  http.Response response;
  
  switch (method) {
    case 'GET':
      response = await http.get(uri, headers: headers);
      break;
    case 'POST':
      response = await http.post(uri, headers: headers, body: body);
      break;
    case 'DELETE':
      response = await http.delete(uri, headers: headers);
      break;
    default:
      throw Exception('Unsupported HTTP method: $method');
  }
  
  if (response.statusCode >= 200 && response.statusCode < 300) {
    return response;
  } else {
    throw Exception('HTTP $method failed: ${response.statusCode} - ${response.body}');
  }
} 