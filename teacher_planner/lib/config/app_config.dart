import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'supabase_config.dart';

class AppConfig {
  static String get supabaseUrl {
    return dotenv.env['SUPABASE_URL']?.isNotEmpty == true 
        ? dotenv.env['SUPABASE_URL']! 
        : SupabaseConfig.supabaseUrl;
  }

  static String get supabaseAnonKey {
    return dotenv.env['SUPABASE_ANON_KEY']?.isNotEmpty == true 
        ? dotenv.env['SUPABASE_ANON_KEY']! 
        : SupabaseConfig.supabaseAnonKey;
  }

  static String get supabaseServiceRoleKey {
    return dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';
  }

  static String get emailServiceApiKey {
    return dotenv.env['EMAIL_SERVICE_API_KEY'] ?? '';
  }

  static String get emailServiceUrl {
    return dotenv.env['EMAIL_SERVICE_URL'] ?? '';
  }

  static String get appName {
    return dotenv.env['APP_NAME'] ?? 'TeacherPlanner';
  }

  static String get appVersion {
    return dotenv.env['APP_VERSION'] ?? '1.0.0';
  }

  // Validation methods
  static bool get isSupabaseConfigured {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }

  static bool get isEmailServiceConfigured {
    return emailServiceApiKey.isNotEmpty && emailServiceUrl.isNotEmpty;
  }

  // Error messages for missing configuration
  static String get missingSupabaseConfigMessage {
    return '''
Missing Supabase configuration!
Please ensure your .env file contains:
- SUPABASE_URL
- SUPABASE_ANON_KEY
''';
  }

  static String get missingEmailConfigMessage {
    return '''
Missing Email Service configuration!
Please ensure your .env file contains:
- EMAIL_SERVICE_API_KEY
- EMAIL_SERVICE_URL
''';
  }
} 