// teacher_planner/scripts/download_and_upload_mrac.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

// Supabase configuration
const String supabaseUrl = 'https://mwfsytnixlcpterxqqnf.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im13ZnN5dG5peGxjcHRlcnhxcW5mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMwNjc4OTgsImV4cCI6MjA2ODY0Mzg5OH0.UdMFlGMfBm_MiUDBB8f7bEAK57MVPaZ1vwXruhhXcq4';

// ADD YOUR MRAC URL HERE
const String mracUrl = 'https://vocabulary.curriculum.edu.au/MRAC/2024/04/LA/ART/export/MRAC/2024/04/LA/ART.jsonld';

void main() async {
  print('🚀 MRAC Download and Upload Tool');
  print('================================');
  print('📥 Downloading from: $mracUrl');
  print('');
  
  try {
    // Test database connection
    await _testConnection();
    
    // Clear existing data
    await _clearExistingData();
    
    // Download and upload the MRAC data
    await _downloadAndUploadMRAC();
    
    print('✅ MRAC data downloaded and uploaded successfully!');
    
  } catch (e) {
    print('❌ Error: $e');
  }
}

Future<void> _testConnection() async {
  print('🔍 Testing database connection...');
  
  try {
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/curriculum_years?select=id&limit=1'),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
      },
    );
    
    if (response.statusCode == 200) {
      print('✅ Database connection successful');
    } else {
      throw Exception('Database connection failed: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Database connection failed: $e');
  }
}

Future<void> _clearExistingData() async {
  print('🧹 Clearing existing curriculum data...');
  
  try {
    // Clear outcomes first (due to foreign key constraints)
    await _makeRequest('DELETE', '/rest/v1/curriculum_outcomes');
    await _makeRequest('DELETE', '/rest/v1/curriculum_strands');
    await _makeRequest('DELETE', '/rest/v1/curriculum_subjects');
    await _makeRequest('DELETE', '/rest/v1/curriculum_years');
    
    print('✅ Existing data cleared');
  } catch (e) {
    print('⚠️ Warning: Could not clear existing data: $e');
  }
}

Future<void> _downloadAndUploadMRAC() async {
  print('📥 Downloading MRAC data...');
  
  try {
    final response = await http.get(Uri.parse(mracUrl));
    
    if (response.statusCode != 200) {
      throw Exception('Failed to download MRAC data: ${response.statusCode}');
    }
    
    print('📖 Parsing MRAC data...');
    final data = json.decode(response.body);
    
    print('🔍 Analyzing document structure...');
    await _analyzeAndUpload(data);
    
  } catch (e) {
    print('❌ Error downloading MRAC data: $e');
    print('');
    print('💡 Make sure the URL is correct and accessible.');
    print('💡 You can update the mracUrl constant at the top of this file.');
  }
}

Future<void> _analyzeAndUpload(dynamic data) async {
  print('📊 Document structure:');
  
  if (data is List) {
    print('   - Array format with ${data.length} items');
    await _uploadArrayData(data);
  } else if (data is Map<String, dynamic>) {
    print('   - Object format with keys: ${data.keys.toList()}');
    await _uploadObjectData(data);
  } else {
    throw Exception('Unknown data format');
  }
}

Future<void> _uploadArrayData(List data) async {
  print('📤 Uploading array data...');
  
  int yearsCount = 0;
  int subjectsCount = 0;
  int strandsCount = 0;
  int outcomesCount = 0;
  
  for (var item in data) {
    if (item is Map<String, dynamic>) {
      try {
        if (_isYearData(item)) {
          await _makeRequest('POST', '/rest/v1/curriculum_years', body: json.encode(item));
          yearsCount++;
        } else if (_isSubjectData(item)) {
          await _makeRequest('POST', '/rest/v1/curriculum_subjects', body: json.encode(item));
          subjectsCount++;
        } else if (_isStrandData(item)) {
          await _makeRequest('POST', '/rest/v1/curriculum_strands', body: json.encode(item));
          strandsCount++;
        } else if (_isOutcomeData(item)) {
          await _makeRequest('POST', '/rest/v1/curriculum_outcomes', body: json.encode(item));
          outcomesCount++;
        }
      } catch (e) {
        print('⚠️ Warning: Could not upload item: $e');
      }
    }
  }
  
  print('✅ Uploaded: $yearsCount years, $subjectsCount subjects, $strandsCount strands, $outcomesCount outcomes');
}

Future<void> _uploadObjectData(Map<String, dynamic> data) async {
  print('📤 Uploading object data...');
  
  // Handle different possible structures
  if (data.containsKey('@graph')) {
    // JSON-LD format
    await _uploadArrayData(data['@graph']);
  } else if (data.containsKey('curriculum')) {
    // Nested curriculum structure
    await _uploadArrayData(data['curriculum']);
  } else if (data.containsKey('years') || data.containsKey('subjects') || data.containsKey('outcomes')) {
    // Structured format
    if (data['years'] != null) {
      for (var year in data['years']) {
        await _makeRequest('POST', '/rest/v1/curriculum_years', body: json.encode(year));
      }
    }
    if (data['subjects'] != null) {
      for (var subject in data['subjects']) {
        await _makeRequest('POST', '/rest/v1/curriculum_subjects', body: json.encode(subject));
      }
    }
    if (data['strands'] != null) {
      for (var strand in data['strands']) {
        await _makeRequest('POST', '/rest/v1/curriculum_strands', body: json.encode(strand));
      }
    }
    if (data['outcomes'] != null) {
      for (var outcome in data['outcomes']) {
        await _makeRequest('POST', '/rest/v1/curriculum_outcomes', body: json.encode(outcome));
      }
    }
  } else {
    // Try to process as individual items
    await _uploadArrayData([data]);
  }
}

bool _isYearData(Map<String, dynamic> item) {
  return item.containsKey('id') && 
         (item.containsKey('name') || item.containsKey('title')) &&
         (item['id'].toString().contains('year') || item['id'].toString().contains('foundation'));
}

bool _isSubjectData(Map<String, dynamic> item) {
  return item.containsKey('id') && 
         (item.containsKey('name') || item.containsKey('title')) &&
         !item['id'].toString().contains('year') &&
         !item['id'].toString().contains('foundation');
}

bool _isStrandData(Map<String, dynamic> item) {
  return item.containsKey('id') && 
         (item.containsKey('name') || item.containsKey('title')) &&
         item.containsKey('subject_id');
}

bool _isOutcomeData(Map<String, dynamic> item) {
  return item.containsKey('id') && 
         (item.containsKey('code') || item.containsKey('outcome_code')) &&
         (item.containsKey('description') || item.containsKey('outcome_description'));
}

Future<void> _makeRequest(String method, String endpoint, {String? body}) async {
  final uri = Uri.parse('$supabaseUrl$endpoint');
  
  final response = await http.request(
    uri,
    method: method,
    headers: {
      'apikey': supabaseAnonKey,
      'Authorization': 'Bearer $supabaseAnonKey',
      'Content-Type': 'application/json',
      'Prefer': 'return=minimal',
    },
    body: body,
  );
  
  if (response.statusCode >= 400) {
    throw Exception('HTTP $method failed: ${response.statusCode} - ${response.body}');
  }
}