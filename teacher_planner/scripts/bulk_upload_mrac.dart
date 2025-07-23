// teacher_planner/scripts/bulk_upload_mrac.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

// Supabase configuration
const String supabaseUrl = 'https://mwfsytnixlcpterxqqnf.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im13ZnN5dG5peGxjcHRlcnhxcW5mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMwNjc4OTgsImV4cCI6MjA2ODY0Mzg5OH0.UdMFlGMfBm_MiUDBB8f7bEAK57MVPaZ1vwXruhhXcq4';

// ADD YOUR MRAC URL HERE
const String mracUrl = 'https://vocabulary.curriculum.edu.au/MRAC/2024/04/LA/ART/export/MRAC/2024/04/LA/ART.jsonld';

// Batch size for bulk uploads
const int batchSize = 100;

void main() async {
  print('🚀 MRAC Bulk Upload Tool');
  print('========================');
  print('📥 Downloading from: $mracUrl');
  print('📦 Using batch size: $batchSize');
  print('');
  
  try {
    // Test database connection
    await _testConnection();
    
    // Clear existing data
    await _clearExistingData();
    
    // Download and bulk upload the MRAC data
    await _downloadAndBulkUploadMRAC();
    
    print('✅ MRAC data downloaded and bulk uploaded successfully!');
    
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
    await _makeRequest('DELETE', '/rest/v1/curriculum_outcomes?id=neq.0');
    await _makeRequest('DELETE', '/rest/v1/curriculum_strands?id=neq.0');
    await _makeRequest('DELETE', '/rest/v1/curriculum_subjects?id=neq.0');
    await _makeRequest('DELETE', '/rest/v1/curriculum_years?id=neq.0');
    
    print('✅ Existing data cleared');
  } catch (e) {
    print('⚠️ Warning: Could not clear existing data: $e');
  }
}

Future<void> _downloadAndBulkUploadMRAC() async {
  print('📥 Downloading MRAC data...');
  
  try {
    final response = await http.get(Uri.parse(mracUrl));
    
    if (response.statusCode != 200) {
      throw Exception('Failed to download MRAC data: ${response.statusCode}');
    }
    
    print('📖 Parsing MRAC data...');
    final data = json.decode(response.body);
    
    print('🔍 Analyzing document structure...');
    await _analyzeAndBulkUpload(data);
    
  } catch (e) {
    print('❌ Error downloading MRAC data: $e');
    print('');
    print('💡 Make sure the URL is correct and accessible.');
    print('💡 You can update the mracUrl constant at the top of this file.');
  }
}

Future<void> _analyzeAndBulkUpload(dynamic data) async {
  print('📊 Document structure:');
  
  if (data is List) {
    print('   - Array format with ${data.length} items');
    
    // Handle MRAC JSON-LD format where the first item contains @graph
    if (data.isNotEmpty && data.first is Map<String, dynamic>) {
      final firstItem = data.first as Map<String, dynamic>;
      if (firstItem.containsKey('@graph')) {
        print('   - Found @graph with ${firstItem['@graph'].length} items');
        await _bulkUploadArrayData(firstItem['@graph']);
        return;
      }
    }
    
    await _bulkUploadArrayData(data);
  } else if (data is Map<String, dynamic>) {
    print('   - Object format with keys: ${data.keys.toList()}');
    await _bulkUploadObjectData(data);
  } else {
    throw Exception('Unknown data format');
  }
}

Future<void> _bulkUploadArrayData(List data) async {
  print('📤 Processing ${data.length} items for bulk upload...');
  
  // Separate data by type
  List<Map<String, dynamic>> years = [];
  List<Map<String, dynamic>> subjects = [];
  List<Map<String, dynamic>> strands = [];
  List<Map<String, dynamic>> outcomes = [];
  
  int processedCount = 0;
  int errorCount = 0;
  
  for (int i = 0; i < data.length; i++) {
    final item = data[i];
    if (item is Map<String, dynamic>) {
      try {
        // Debug: Print the first item to see its structure
        if (processedCount == 0) {
          print('🔍 First item structure: ${item.keys.toList()}');
          print('🔍 First item sample: ${item.toString().substring(0, 200)}...');
        }
        
        if (_isYearData(item)) {
          years.add(item);
        } else if (_isSubjectData(item)) {
          subjects.add(item);
        } else if (_isStrandData(item)) {
          strands.add(item);
        } else if (_isOutcomeData(item)) {
          outcomes.add(item);
        } else {
          // Try to process as curriculum data with different field names
          final processedItem = _processCurriculumItem(item);
          if (processedItem != null) {
            if (processedItem['type'] == 'year') {
              years.add(processedItem['data']);
            } else if (processedItem['type'] == 'subject') {
              subjects.add(processedItem['data']);
            } else if (processedItem['type'] == 'strand') {
              strands.add(processedItem['data']);
            } else if (processedItem['type'] == 'outcome') {
              outcomes.add(processedItem['data']);
            }
          } else {
            errorCount++;
            if (errorCount <= 5) {
              print('⚠️ Could not process item $i: ${item.keys.toList()}');
            }
          }
        }
        
        processedCount++;
        
        // Progress indicator
        if ((i + 1) % 500 == 0) {
          print('📊 Processed ${i + 1}/${data.length} items...');
        }
        
      } catch (e) {
        errorCount++;
        if (errorCount <= 10) {
          print('⚠️ Error processing item $i: $e');
        }
      }
    }
  }
  
  print('📊 Data categorization complete:');
  print('   - Years: ${years.length}');
  print('   - Subjects: ${subjects.length}');
  print('   - Strands: ${strands.length}');
  print('   - Outcomes: ${outcomes.length}');
  print('   - Errors: $errorCount');
  print('');
  
  // Bulk upload in dependency order
  print('📤 Bulk uploading years...');
  await _bulkUploadTable('curriculum_years', years);
  
  print('📤 Bulk uploading subjects...');
  await _bulkUploadTable('curriculum_subjects', subjects);
  
  print('📤 Bulk uploading strands...');
  await _bulkUploadTable('curriculum_strands', strands);
  
  print('📤 Bulk uploading outcomes...');
  await _bulkUploadTable('curriculum_outcomes', outcomes);
  
  print('✅ Bulk upload completed successfully!');
}

Future<void> _bulkUploadTable(String tableName, List<Map<String, dynamic>> data) async {
  if (data.isEmpty) {
    print('   - No data to upload for $tableName');
    return;
  }
  
  print('   - Uploading ${data.length} records to $tableName...');
  
  // Upload in batches
  for (int i = 0; i < data.length; i += batchSize) {
    final end = (i + batchSize < data.length) ? i + batchSize : data.length;
    final batch = data.sublist(i, end);
    
    try {
      await _makeBulkRequest('POST', '/rest/v1/$tableName', body: json.encode(batch));
      print('   - Uploaded batch ${(i ~/ batchSize) + 1}/${(data.length / batchSize).ceil()} (${end - i} records)');
    } catch (e) {
      print('   - Error uploading batch ${(i ~/ batchSize) + 1}: $e');
      // Try individual uploads for this batch
      for (int j = 0; j < batch.length; j++) {
        try {
          await _makeRequest('POST', '/rest/v1/$tableName', body: json.encode(batch[j]));
        } catch (e2) {
          print('   - Failed to upload individual record: $e2');
        }
      }
    }
  }
}

Future<void> _bulkUploadObjectData(Map<String, dynamic> data) async {
  print('📤 Processing object data for bulk upload...');
  
  // Handle different possible structures
  if (data.containsKey('@graph')) {
    // JSON-LD format
    await _bulkUploadArrayData(data['@graph']);
  } else if (data.containsKey('curriculum')) {
    // Nested curriculum structure
    await _bulkUploadArrayData(data['curriculum']);
  } else if (data.containsKey('years') || data.containsKey('subjects') || data.containsKey('outcomes')) {
    // Structured format - bulk upload each section
    if (data['years'] != null) {
      print('📤 Bulk uploading years...');
      await _bulkUploadTable('curriculum_years', List<Map<String, dynamic>>.from(data['years']));
    }
    if (data['subjects'] != null) {
      print('📤 Bulk uploading subjects...');
      await _bulkUploadTable('curriculum_subjects', List<Map<String, dynamic>>.from(data['subjects']));
    }
    if (data['strands'] != null) {
      print('📤 Bulk uploading strands...');
      await _bulkUploadTable('curriculum_strands', List<Map<String, dynamic>>.from(data['strands']));
    }
    if (data['outcomes'] != null) {
      print('📤 Bulk uploading outcomes...');
      await _bulkUploadTable('curriculum_outcomes', List<Map<String, dynamic>>.from(data['outcomes']));
    }
  } else {
    // Try to process as individual items
    await _bulkUploadArrayData([data]);
  }
}

// Data type detection functions (same as before)
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

// Data processing functions (same as before)
Map<String, dynamic>? _processCurriculumItem(Map<String, dynamic> item) {
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

// Data extraction functions (same as before)
String _extractIdFromUrl(String url) {
  final parts = url.split('/');
  final lastPart = parts.last;
  
  if (lastPart.length > 200) {
    return 'id_${url.hashCode.abs()}';
  }
  
  return lastPart;
}

String _extractName(Map<String, dynamic> item) {
  final name = item['name'] ?? 
               item['title'] ?? 
               item['label'] ?? 
               item['http://purl.org/dc/terms/title']?.first?['@value'] ??
               item['http://purl.org/dc/terms/title']?['@value'] ??
               '';
  
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
  
  if (elaboration.length > 10000) {
    return elaboration.substring(0, 10000);
  }
  
  return elaboration;
}

String _extractYearLevel(Map<String, dynamic> item) {
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
  
  final notation = item['http://purl.org/ASN/schema/core/statementNotation']?.first?['@value'] ??
                  item['http://purl.org/ASN/schema/core/statementNotation']?['@value'] ??
                  '';
  
  if (notation.isNotEmpty) {
    final yearMatch = RegExp(r'year\s*(\d+)', caseSensitive: false).firstMatch(notation);
    if (yearMatch != null) {
      return 'year${yearMatch.group(1)}';
    }
  }
  
  return 'unknown';
}

String _extractSubjectId(Map<String, dynamic> item) {
  final subjectRef = item['http://purl.org/ASN/schema/core/subject']?.first?['@id'] ??
                    item['http://purl.org/ASN/schema/core/subject']?['@id'] ??
                    '';
  
  if (subjectRef.isNotEmpty) {
    return _extractIdFromUrl(subjectRef);
  }
  
  return '';
}

String _extractStrandId(Map<String, dynamic> item) {
  final strandRef = item['http://purl.org/ASN/schema/core/statementNotation']?.first?['@value'] ??
                   item['http://purl.org/ASN/schema/core/statementNotation']?['@value'] ??
                   '';
  
  if (strandRef.isNotEmpty) {
    return _extractIdFromUrl(strandRef);
  }
  
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

// HTTP request functions
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

Future<void> _makeBulkRequest(String method, String endpoint, {String? body}) async {
  final uri = Uri.parse('$supabaseUrl$endpoint');
  
  http.Response response;
  
  switch (method.toUpperCase()) {
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
    default:
      throw Exception('Unsupported HTTP method for bulk upload: $method');
  }
  
  if (response.statusCode >= 400) {
    throw Exception('HTTP $method failed: ${response.statusCode} - ${response.body}');
  }
} 