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
    await _makeRequest('DELETE', '/rest/v1/curriculum_outcomes?id=neq.0'); // WHERE clause to delete all
    await _makeRequest('DELETE', '/rest/v1/curriculum_strands?id=neq.0'); // WHERE clause to delete all
    await _makeRequest('DELETE', '/rest/v1/curriculum_subjects?id=neq.0'); // WHERE clause to delete all
    await _makeRequest('DELETE', '/rest/v1/curriculum_years?id=neq.0'); // WHERE clause to delete all
    
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
    
    // Handle MRAC JSON-LD format where the first item contains @graph
    if (data.isNotEmpty && data.first is Map<String, dynamic>) {
      final firstItem = data.first as Map<String, dynamic>;
      if (firstItem.containsKey('@graph')) {
        print('   - Found @graph with ${firstItem['@graph'].length} items');
        await _uploadArrayData(firstItem['@graph']);
        return;
      }
    }
    
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
  int errorCount = 0;
  
  for (int i = 0; i < data.length; i++) {
    final item = data[i];
    if (item is Map<String, dynamic>) {
      try {
        // Debug: Print the first few items to see their structure
        if (yearsCount + subjectsCount + strandsCount + outcomesCount == 0) {
          print('🔍 First item structure: ${item.keys.toList()}');
          print('🔍 First item sample: ${item.toString().substring(0, 200)}...');
        }
        
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
        } else {
          // Try to process as curriculum data with different field names
          final processedItem = _processCurriculumItem(item);
          if (processedItem != null) {
            if (processedItem['type'] == 'year') {
              await _makeRequest('POST', '/rest/v1/curriculum_years', body: json.encode(processedItem['data']));
              yearsCount++;
            } else if (processedItem['type'] == 'subject') {
              await _makeRequest('POST', '/rest/v1/curriculum_subjects', body: json.encode(processedItem['data']));
              subjectsCount++;
            } else if (processedItem['type'] == 'strand') {
              await _makeRequest('POST', '/rest/v1/curriculum_strands', body: json.encode(processedItem['data']));
              strandsCount++;
            } else if (processedItem['type'] == 'outcome') {
              await _makeRequest('POST', '/rest/v1/curriculum_outcomes', body: json.encode(processedItem['data']));
              outcomesCount++;
            }
          } else {
            // Log items that couldn't be processed
            if (errorCount < 5) { // Only log first 5 errors to avoid spam
              print('⚠️ Could not process item $i: ${item.keys.toList()}');
            }
            errorCount++;
          }
        }
        
        // Progress indicator
        if ((i + 1) % 100 == 0) {
          print('📊 Processed ${i + 1}/${data.length} items...');
        }
        
      } catch (e) {
        errorCount++;
        if (errorCount <= 10) { // Only log first 10 errors
          print('⚠️ Warning: Could not upload item $i: $e');
          if (errorCount == 10) {
            print('⚠️ Suppressing further error messages...');
          }
        }
      }
    }
  }
  
  print('✅ Uploaded: $yearsCount years, $subjectsCount subjects, $strandsCount strands, $outcomesCount outcomes');
  if (errorCount > 0) {
    print('⚠️ Errors: $errorCount items could not be processed');
  }
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

Map<String, dynamic>? _processCurriculumItem(Map<String, dynamic> item) {
  // Handle JSON-LD format with @id, @type, etc.
  
  // Check for year data
  if (item.containsKey('@id') && 
      (item['@id'].toString().contains('year') || item['@id'].toString().contains('foundation'))) {
    return {
      'type': 'year',
      'data': {
        'id': _extractIdFromUrl(item['@id']),
        'name': _extractName(item),
        'description': _extractDescription(item),
      }
    };
  }
  
  // Check for subject data
  if (item.containsKey('@id') && 
      !item['@id'].toString().contains('year') && 
      !item['@id'].toString().contains('foundation') &&
      _hasName(item)) {
    return {
      'type': 'subject',
      'data': {
        'id': _extractIdFromUrl(item['@id']),
        'name': _extractName(item),
        'code': _extractCode(item),
        'description': _extractDescription(item),
      }
    };
  }
  
  // Check for strand data
  if (item.containsKey('@id') && 
      _hasName(item) &&
      _hasSubjectReference(item)) {
    return {
      'type': 'strand',
      'data': {
        'id': _extractIdFromUrl(item['@id']),
        'subject_id': _extractSubjectId(item),
        'name': _extractName(item),
        'description': _extractDescription(item),
      }
    };
  }
  
  // Check for outcome data
  if (item.containsKey('@id') && 
      _hasOutcomeCode(item) &&
      _hasDescription(item)) {
    return {
      'type': 'outcome',
      'data': {
        'id': _extractIdFromUrl(item['@id']),
        'strand_id': _extractStrandId(item),
        'code': _extractOutcomeCode(item),
        'description': _extractDescription(item),
        'elaboration': _extractElaboration(item),
        'year_level': _extractYearLevel(item),
      }
    };
  }
  
  return null;
}

String _extractIdFromUrl(String url) {
  // Extract the last part of the URL as ID, but handle long URLs better
  final parts = url.split('/');
  final lastPart = parts.last;
  
  // If the last part is too long, use a hash of the full URL
  if (lastPart.length > 200) {
    // Create a shorter hash-based ID
    return 'id_${url.hashCode.abs()}';
  }
  
  return lastPart;
}

String _extractName(Map<String, dynamic> item) {
  // Try multiple possible fields for name/title
  final name = item['name'] ?? 
               item['title'] ?? 
               item['label'] ?? 
               item['http://purl.org/dc/terms/title']?.first?['@value'] ??
               item['http://purl.org/dc/terms/title']?['@value'] ??
               '';
  
  // Truncate if too long
  if (name.length > 250) {
    return name.substring(0, 250);
  }
  
  return name;
}

String _extractDescription(Map<String, dynamic> item) {
  final description = item['description'] ?? 
                     item['http://purl.org/dc/terms/description']?.first?['@value'] ??
                     item['http://purl.org/dc/terms/description']?['@value'] ??
                     '';
  
  // Truncate if too long (TEXT field can handle long content, but let's be reasonable)
  if (description.length > 10000) {
    return description.substring(0, 10000);
  }
  
  return description;
}

String _extractCode(Map<String, dynamic> item) {
  final code = item['code'] ?? 
               item['http://purl.org/ASN/schema/core/statementLabel']?.first?['@value'] ??
               item['http://purl.org/ASN/schema/core/statementLabel']?['@value'] ??
               '';
  
  // Truncate if too long
  if (code.length > 95) {
    return code.substring(0, 95);
  }
  
  return code;
}

String _extractOutcomeCode(Map<String, dynamic> item) {
  final code = item['code'] ?? 
               item['outcome_code'] ?? 
               item['outcomeCode'] ?? 
               item['http://purl.org/ASN/schema/core/statementLabel']?.first?['@value'] ??
               item['http://purl.org/ASN/schema/core/statementLabel']?['@value'] ??
               item['http://purl.org/ASN/schema/core/statementNotation']?.first?['@value'] ??
               item['http://purl.org/ASN/schema/core/statementNotation']?['@value'] ??
               '';
  
  // Truncate if too long
  if (code.length > 95) {
    return code.substring(0, 95);
  }
  
  return code;
}

String _extractElaboration(Map<String, dynamic> item) {
  final elaboration = item['elaboration'] ?? 
                     item['http://purl.org/ASN/schema/core/elaboration']?.first?['@value'] ??
                     item['http://purl.org/ASN/schema/core/elaboration']?['@value'] ??
                     '';
  
  // Truncate if too long
  if (elaboration.length > 10000) {
    return elaboration.substring(0, 10000);
  }
  
  return elaboration;
}

String _extractYearLevel(Map<String, dynamic> item) {
  // Try to extract year level from various fields
  final educationLevel = item['http://purl.org/ASN/schema/core/educationLevel']?.first?['@id'] ??
                        item['http://purl.org/ASN/schema/core/educationLevel']?['@id'] ??
                        '';
  
  if (educationLevel.isNotEmpty) {
    if (educationLevel.contains('foundation')) return 'foundation';
    if (educationLevel.contains('year1')) return 'year1';
    if (educationLevel.contains('year2')) return 'year2';
    if (educationLevel.contains('year3')) return 'year3';
    if (educationLevel.contains('year4')) return 'year4';
    if (educationLevel.contains('year5')) return 'year5';
    if (educationLevel.contains('year6')) return 'year6';
    if (educationLevel.contains('year7')) return 'year7';
    if (educationLevel.contains('year8')) return 'year8';
    if (educationLevel.contains('year9')) return 'year9';
    if (educationLevel.contains('year10')) return 'year10';
    if (educationLevel.contains('year11')) return 'year11';
    if (educationLevel.contains('year12')) return 'year12';
  }
  
  // Try to extract from other fields
  final notation = item['http://purl.org/ASN/schema/core/statementNotation']?.first?['@value'] ??
                  item['http://purl.org/ASN/schema/core/statementNotation']?['@value'] ??
                  '';
  
  if (notation.isNotEmpty) {
    // Look for year patterns in the notation
    final yearMatch = RegExp(r'year\s*(\d+)', caseSensitive: false).firstMatch(notation);
    if (yearMatch != null) {
      return 'year${yearMatch.group(1)}';
    }
  }
  
  return 'unknown';
}

String _extractSubjectId(Map<String, dynamic> item) {
  // Try to extract subject ID from various references
  final subjectRef = item['http://purl.org/ASN/schema/core/subject']?.first?['@id'] ??
                    item['http://purl.org/ASN/schema/core/subject']?['@id'] ??
                    '';
  
  if (subjectRef.isNotEmpty) {
    return _extractIdFromUrl(subjectRef);
  }
  
  return '';
}

String _extractStrandId(Map<String, dynamic> item) {
  // Try to extract strand ID from various references
  final strandRef = item['http://purl.org/ASN/schema/core/statementNotation']?.first?['@value'] ??
                   item['http://purl.org/ASN/schema/core/statementNotation']?['@value'] ??
                   '';
  
  if (strandRef.isNotEmpty) {
    return _extractIdFromUrl(strandRef);
  }
  
  // Try to extract from @id if it looks like a strand
  final id = item['@id'] ?? '';
  if (id.isNotEmpty && id.contains('strand')) {
    return _extractIdFromUrl(id);
  }
  
  return '';
}

bool _hasName(Map<String, dynamic> item) {
  return item.containsKey('name') || 
         item.containsKey('title') || 
         item.containsKey('label') ||
         item.containsKey('http://purl.org/dc/terms/title');
}

bool _hasDescription(Map<String, dynamic> item) {
  return item.containsKey('description') || 
         item.containsKey('http://purl.org/dc/terms/description');
}

bool _hasOutcomeCode(Map<String, dynamic> item) {
  return item.containsKey('code') || 
         item.containsKey('outcome_code') || 
         item.containsKey('outcomeCode') ||
         item.containsKey('http://purl.org/ASN/schema/core/statementLabel');
}

bool _hasSubjectReference(Map<String, dynamic> item) {
  return item.containsKey('subject_id') || 
         item.containsKey('subjectId') ||
         item.containsKey('http://purl.org/ASN/schema/core/subject');
}

Future<void> _makeRequest(String method, String endpoint, {String? body}) async {
  final uri = Uri.parse('$supabaseUrl$endpoint');
  
  http.Response response;
  
  switch (method.toUpperCase()) {
    case 'GET':
      response = await http.get(
        uri,
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': 'application/json',
        },
      );
      break;
    case 'POST':
      response = await http.post(
        uri,
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        body: body,
      );
      break;
    case 'DELETE':
      response = await http.delete(
        uri,
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': 'application/json',
        },
      );
      break;
    default:
      throw Exception('Unsupported HTTP method: $method');
  }
  
  if (response.statusCode >= 400) {
    throw Exception('HTTP $method failed: ${response.statusCode} - ${response.body}');
  }
} 