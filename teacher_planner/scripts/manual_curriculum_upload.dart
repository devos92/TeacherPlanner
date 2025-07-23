// teacher_planner/scripts/manual_curriculum_upload.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// Supabase configuration
const String supabaseUrl = 'https://mwfsytnixlcpterxqqnf.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im13ZnN5dG5peGxjcHRlcnhxcW5mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMwNjc4OTgsImV4cCI6MjA2ODY0Mzg5OH0.UdMFlGMfBm_MiUDBB8f7bEAK57MVPaZ1vwXruhhXcq4';

// MANUAL CURRICULUM DATA LINKS - ADD YOUR LINKS HERE
final List<Map<String, String>> curriculumLinks = [
  // Example format - replace with your actual links
  {
    'name': 'Foundation English',
    'url': 'https://your-link-here.com/foundation-english.json',
    'year': 'foundation',
    'subject': 'english',
  },
  {
    'name': 'Year 1 English', 
    'url': 'https://your-link-here.com/year1-english.json',
    'year': 'year1',
    'subject': 'english',
  },
  // Add more links here...
];

void main() async {
  print('🚀 Starting manual curriculum data upload...');
  
  try {
    // Test database connection
    await _testConnection();
    
    // Clear existing data
    await _clearExistingData();
    
    // Process each curriculum link
    for (var link in curriculumLinks) {
      print('📥 Processing: ${link['name']}');
      await _processCurriculumLink(link);
    }
    
    print('✅ All curriculum data uploaded successfully!');
    
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

Future<void> _processCurriculumLink(Map<String, String> link) async {
  try {
    // Download the curriculum data
    print('  📥 Downloading from: ${link['url']}');
    final response = await http.get(Uri.parse(link['url']));
    
    if (response.statusCode != 200) {
      throw Exception('Failed to download: ${response.statusCode}');
    }
    
    // Parse the JSON data
    final data = json.decode(response.body);
    
    // Upload to database based on data structure
    await _uploadCurriculumData(data, link);
    
    print('  ✅ Uploaded: ${link['name']}');
    
  } catch (e) {
    print('  ❌ Failed to process ${link['name']}: $e');
  }
}

Future<void> _uploadCurriculumData(dynamic data, Map<String, String> link) async {
  // This function will handle different data formats
  // You can modify this based on your actual data structure
  
  if (data is Map<String, dynamic>) {
    // Handle structured data
    await _uploadStructuredData(data, link);
  } else if (data is List) {
    // Handle array data
    await _uploadArrayData(data, link);
  } else {
    throw Exception('Unknown data format');
  }
}

Future<void> _uploadStructuredData(Map<String, dynamic> data, Map<String, String> link) async {
  // Upload years if present
  if (data['years'] != null) {
    for (var year in data['years']) {
      await _makeRequest('POST', '/rest/v1/curriculum_years', body: json.encode(year));
    }
  }
  
  // Upload subjects if present
  if (data['subjects'] != null) {
    for (var subject in data['subjects']) {
      await _makeRequest('POST', '/rest/v1/curriculum_subjects', body: json.encode(subject));
    }
  }
  
  // Upload strands if present
  if (data['strands'] != null) {
    for (var strand in data['strands']) {
      await _makeRequest('POST', '/rest/v1/curriculum_strands', body: json.encode(strand));
    }
  }
  
  // Upload outcomes if present
  if (data['outcomes'] != null) {
    for (var outcome in data['outcomes']) {
      await _makeRequest('POST', '/rest/v1/curriculum_outcomes', body: json.encode(outcome));
    }
  }
}

Future<void> _uploadArrayData(List data, Map<String, String> link) async {
  // Handle array format - assume it's outcomes
  for (var item in data) {
    if (item is Map<String, dynamic>) {
      // Add year and subject info if not present
      if (link['year'] != null && !item.containsKey('year_level')) {
        item['year_level'] = link['year'];
      }
      if (link['subject'] != null && !item.containsKey('subject_id')) {
        item['subject_id'] = link['subject'];
      }
      
      // Determine table based on item structure
      if (item.containsKey('code') && item.containsKey('description')) {
        // This looks like an outcome
        await _makeRequest('POST', '/rest/v1/curriculum_outcomes', body: json.encode(item));
      } else if (item.containsKey('name') && item.containsKey('subject_id')) {
        // This looks like a strand
        await _makeRequest('POST', '/rest/v1/curriculum_strands', body: json.encode(item));
      } else if (item.containsKey('name') && !item.containsKey('subject_id')) {
        // This looks like a subject or year
        if (item.containsKey('code')) {
          await _makeRequest('POST', '/rest/v1/curriculum_subjects', body: json.encode(item));
        } else {
          await _makeRequest('POST', '/rest/v1/curriculum_years', body: json.encode(item));
        }
      }
    }
  }
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

// HELPER: Add your curriculum links here
void addCurriculumLinks() {
  print('📝 INSTRUCTIONS:');
  print('1. Add your curriculum data links to the curriculumLinks list above');
  print('2. Each link should have: name, url, year, subject');
  print('3. Run this script to download and upload all data');
  print('');
  print('📋 Example format:');
  print('''
  {
    'name': 'Foundation English',
    'url': 'https://your-actual-link.com/foundation-english.json',
    'year': 'foundation',
    'subject': 'english',
  },
  ''');
} 