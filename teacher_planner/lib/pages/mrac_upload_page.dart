// lib/pages/mrac_upload_page.dart

import 'package:flutter/material.dart';
import '../services/mrac_data_loader.dart';

class MRACUploadPage extends StatefulWidget {
  @override
  _MRACUploadPageState createState() => _MRACUploadPageState();
}

class _MRACUploadPageState extends State<MRACUploadPage> {
  bool _isLoading = false;
  String _status = 'Ready to upload MRAC data';
  Map<String, dynamic>? _results;

  Future<void> _uploadMRACData() async {
    setState(() {
      _isLoading = true;
      _status = 'Starting MRAC data upload...';
      _results = null;
    });

    try {
      final results = await MRACDataLoader.testMRACLoading();
      
      setState(() {
        _isLoading = false;
        _status = 'Upload completed!';
        _results = results;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = 'Upload failed: $e';
        _results = {'error': e.toString()};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MRAC Data Upload'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Machine-readable Australian Curriculum (MRAC) Upload',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This will download the official MRAC data and upload it to your Supabase database.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'MRAC Version 9.0 - Last updated 7 June 2024',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _uploadMRACData,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Uploading...'),
                      ],
                    )
                  : Text('Upload MRAC Data to Supabase'),
            ),
            
            SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    Text(_status),
                    if (_results != null) ...[
                      SizedBox(height: 16),
                      Text(
                        'Results',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _results!.entries.map((entry) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${entry.key}: ',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                    child: Text(
                                      entry.value.toString(),
                                      style: TextStyle(fontFamily: 'monospace'),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What this does:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    Text('• Downloads official MRAC data from ACARA'),
                    Text('• Parses the structured curriculum data'),
                    Text('• Clears existing curriculum data in Supabase'),
                    Text('• Uploads years, subjects, strands, and outcomes'),
                    Text('• Creates a complete curriculum database'),
                    SizedBox(height: 8),
                    Text(
                      'This process may take a few minutes depending on your internet connection.',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
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
} 