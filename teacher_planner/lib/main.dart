import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'services/supabase_service.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    
    // Initialize Supabase storage buckets
    await SupabaseService.initializeStorage();
    
    debugPrint('✅ Supabase initialized successfully');
  } catch (e) {
    debugPrint('❌ Error initializing Supabase: $e');
  }
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher Planner',
      theme: _buildAppTheme(),
      home: HomePage(),
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
      
      // Enhanced visual density for touch interfaces
      visualDensity: VisualDensity.adaptivePlatformDensity,
      
      // Responsive app bar theme
      appBarTheme: AppBarTheme(
        elevation: 2,
        shadowColor: Colors.black12,
        toolbarHeight: 64, // Slightly taller for better touch targets
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 24, // Standard touch-friendly icon size
        ),
        actionsIconTheme: IconThemeData(
          color: Colors.white,
          size: 24,
        ),
      ),
      
      // Enhanced icon theme
      iconTheme: IconThemeData(
        color: Colors.blue,
        size: 24, // Standard size for mobile
      ),
      
      // Improved button themes for touch interfaces
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(88, 48), // Minimum touch target size
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: Size(64, 48),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        sizeConstraints: BoxConstraints.tightFor(
          width: 56,
          height: 56,
        ),
        iconSize: 24,
      ),
      
      // Enhanced bottom navigation bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        elevation: 8,
      ),
      
      // Responsive input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: TextStyle(fontSize: 16),
        hintStyle: TextStyle(fontSize: 16, color: Colors.grey[600]),
      ),
      
      // Card theme with appropriate elevation for mobile
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      
      // Enhanced list tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minVerticalPadding: 8,
        minLeadingWidth: 24,
      ),
      
      // Responsive dialog theme
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        contentTextStyle: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      
      // Responsive and adaptive typography
      textTheme: TextTheme(
        // Display styles - for large text
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w300),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w300),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
        
        // Headline styles - for important headings
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        
        // Title styles - for medium emphasis text
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        
        // Body styles - for regular text
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        
        // Label styles - for smaller text
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      ),
    );
  }
}