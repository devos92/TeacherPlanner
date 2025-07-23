// lib/examples/api_test_page.dart

import 'package:flutter/material.dart';
import '../services/curriculum_service.dart';

class ApiTestPage extends StatefulWidget {
  @override
  _ApiTestPageState createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final CurriculumService _curriculumService = CurriculumService();
  Map<String, dynamic>? _testResults;
  bool _isTesting = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Test Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _testApiConnection,
            tooltip: 'Test API Connection',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Machine-readable Australian Curriculum (MRAC) Test',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This page tests connectivity to the official Machine-readable Australian Curriculum (MRAC) to help debug issues.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'MRAC provides structured curriculum data in RDF/XML, JSON+LD, and SPARQL formats.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isTesting ? null : _testApiConnection,
                      child: _isTesting
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text('Testing...'),
                              ],
                            )
                          : Text('Test API Connection'),
                    ),
                  ],
                ),
              ),
            ),
            
            if (_errorMessage != null) ...[
              SizedBox(height: 16),
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Error',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (_testResults != null) ...[
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Results',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      ..._buildTestResults(),
                    ],
                  ),
                ),
              ),
            ],

            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Troubleshooting',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'If the MRAC is not accessible, the app will automatically fall back to local curriculum data. You can also:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 8),
                    Text('• Check your internet connection'),
                    Text('• Verify the Australian Curriculum MRAC page is accessible'),
                    Text('• Download MRAC files manually from the official website'),
                    Text('• Try refreshing the data'),
                    Text('• Switch to local data mode if needed'),
                    SizedBox(height: 8),
                    Text(
                      'MRAC Version 9.0 was last updated on 7 June 2024.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTestResults() {
    final widgets = <Widget>[];
    
    _testResults!.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        widgets.add(_buildEndpointResult(key, value));
      } else {
        widgets.add(_buildSimpleResult(key, value.toString()));
      }
      widgets.add(SizedBox(height: 8));
    });
    
    return widgets;
  }

  Widget _buildEndpointResult(String endpoint, Map<String, dynamic> result) {
    final isAccessible = result['accessible'] == true;
    
    return Card(
      color: isAccessible ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isAccessible ? Icons.check_circle : Icons.error,
                  color: isAccessible ? Colors.green : Colors.red,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    endpoint,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isAccessible ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text('Status: ${result['status']}'),
            if (result['content_type'] != null)
              Text('Content-Type: ${result['content_type']}'),
            if (result['body_preview'] != null) ...[
              SizedBox(height: 4),
              Text(
                'Response Preview:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  result['body_preview'],
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
            if (result['error'] != null)
              Text('Error: ${result['error']}', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleResult(String key, String value) {
    return Row(
      children: [
        Text(
          '$key: ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  Future<void> _testApiConnection() async {
    setState(() {
      _isTesting = true;
      _errorMessage = null;
      _testResults = null;
    });

    try {
      final results = await _curriculumService.testApiConnection();
      setState(() {
        _testResults = results;
        _isTesting = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isTesting = false;
      });
    }
  }
} 