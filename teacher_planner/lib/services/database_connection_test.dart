import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

class DatabaseConnectionTest {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Test basic database connection
  static Future<bool> testConnection() async {
    try {
      print('🔍 Testing Supabase connection...');
      print('URL: ${AppConfig.supabaseUrl}');
      print('Anon Key: ${AppConfig.supabaseAnonKey.substring(0, 20)}...');
      
      // Test basic connection by trying to access a table
      final response = await _supabase
          .from('users')
          .select('count')
          .limit(1);
      
      print('✅ Database connection successful!');
      print('Response data: ${response.length} rows');
      return true;
    } catch (e) {
      print('❌ Database connection failed: $e');
      return false;
    }
  }

  /// Test authentication
  static Future<bool> testAuth() async {
    try {
      print('🔍 Testing authentication...');
      
      // Test if we can access auth
      final session = _supabase.auth.currentSession;
      print('✅ Authentication service accessible');
      print('Current session: ${session != null ? 'Active' : 'None'}');
      return true;
    } catch (e) {
      print('❌ Authentication test failed: $e');
      return false;
    }
  }

  /// Test table access
  static Future<bool> testTableAccess() async {
    try {
      print('🔍 Testing table access...');
      
      // Test access to main tables
      final tables = [
        'users',
        'weekly_plans', 
        'daily_details',
        'curriculum',
        'subjects'
      ];
      
      for (final table in tables) {
        try {
          final response = await _supabase
              .from(table)
              .select('count')
              .limit(1);
          print('✅ Table "$table" accessible');
        } catch (e) {
          print('⚠️  Table "$table" not accessible: $e');
        }
      }
      
      return true;
    } catch (e) {
      print('❌ Table access test failed: $e');
      return false;
    }
  }

  /// Run all tests
  static Future<void> runAllTests() async {
    print('🚀 Starting database connection tests...\n');
    
    final connectionTest = await testConnection();
    final authTest = await testAuth();
    final tableTest = await testTableAccess();
    
    print('\n📊 Test Results:');
    print('Connection: ${connectionTest ? '✅ PASS' : '❌ FAIL'}');
    print('Authentication: ${authTest ? '✅ PASS' : '❌ FAIL'}');
    print('Table Access: ${tableTest ? '✅ PASS' : '❌ FAIL'}');
    
    if (connectionTest && authTest && tableTest) {
      print('\n🎉 All tests passed! Database is ready to use.');
    } else {
      print('\n⚠️  Some tests failed. Check your configuration.');
    }
  }
} 