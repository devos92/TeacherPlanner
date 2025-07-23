// teacher_planner/scripts/examine_mrac_data.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

const String mracUrl = 'https://vocabulary.curriculum.edu.au/MRAC/2024/04/LA/ART/export/MRAC/2024/04/LA/ART.jsonld';

void main() async {
  print('🔍 Examining MRAC Data Structure');
  print('================================');
  print('📥 Downloading from: $mracUrl');
  print('');
  
  try {
    final response = await http.get(Uri.parse(mracUrl));
    
    if (response.statusCode != 200) {
      throw Exception('Failed to download MRAC data: ${response.statusCode}');
    }
    
    print('📖 Parsing MRAC data...');
    final data = json.decode(response.body);
    
    print('📊 Document structure:');
    print('   Type: ${data.runtimeType}');
    
    if (data is Map<String, dynamic>) {
      print('   Keys: ${data.keys.toList()}');
      
      if (data.containsKey('@graph')) {
        final graph = data['@graph'];
        print('   @graph type: ${graph.runtimeType}');
        print('   @graph length: ${graph is List ? graph.length : 'N/A'}');
        
        if (graph is List && graph.isNotEmpty) {
          print('   First item keys: ${graph.first.keys.toList()}');
          print('   First item sample: ${graph.first.toString().substring(0, 300)}...');
        }
      }
    } else if (data is List) {
      print('   Length: ${data.length}');
      if (data.isNotEmpty) {
        print('   First item keys: ${data.first.keys.toList()}');
        print('   First item sample: ${data.first.toString().substring(0, 300)}...');
      }
    }
    
  } catch (e) {
    print('❌ Error: $e');
  }
} 