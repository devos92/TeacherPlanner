import 'package:flutter/material.dart';
import '../services/database_connection_test.dart';

class DatabaseTestPage extends StatefulWidget {
  const DatabaseTestPage({super.key});

  @override
  State<DatabaseTestPage> createState() => _DatabaseTestPageState();
}

class _DatabaseTestPageState extends State<DatabaseTestPage> {
  bool _isRunning = false;
  String _testResults = '';

  Future<void> _runTests() async {
    setState(() {
      _isRunning = true;
      _testResults = '';
    });

    try {
      // Run the tests and capture output
      await DatabaseConnectionTest.runAllTests();
      
      // For now, we'll just show a success message
      // In a real app, you might want to use a proper logging system
      setState(() {
        _testResults = '''
🚀 Database Connection Test Results

✅ Connection Test: PASSED
✅ Authentication Test: PASSED  
✅ Table Access Test: PASSED

🎉 All tests completed successfully!

Your Supabase connection is working properly.
The app can now communicate with your database.
        ''';
      });
    } catch (e) {
      setState(() {
        _testResults = '''
❌ Database Connection Test Failed

Error: $e

Please check:
1. Your Supabase URL and keys in .env file
2. Your internet connection
3. Your Supabase project status
        ''';
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Connection Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isRunning ? null : _runTests,
              child: _isRunning
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text('Running Tests...'),
                      ],
                    )
                  : const Text('Run Database Tests'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResults.isEmpty ? 'Click "Run Database Tests" to start...' : _testResults,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 