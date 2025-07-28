import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/supabase_config.dart';
import 'services/supabase_service.dart';
import 'pages/home_page.dart';
import 'utils/responsive_utils.dart';
import 'services/cache_service.dart';
import 'services/lazy_loading_service.dart';

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
  
  // Initialize caching and lazy loading services
  await CacheService.instance.initialize();
  await LazyLoadingService.instance.initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Apply Shadows Into Light Two font theme throughout the app
        textTheme: GoogleFonts.shadowsIntoLightTwoTextTheme(),
        // Update other theme components to use the custom font
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.shadowsIntoLightTwo(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedLabelStyle: GoogleFonts.shadowsIntoLightTwo(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.shadowsIntoLightTwo(
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: GoogleFonts.shadowsIntoLightTwo(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: GoogleFonts.shadowsIntoLightTwo(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
        cardTheme: CardThemeData(
          // Card theme with custom font
        ),
        dialogTheme: DialogThemeData(
          titleTextStyle: GoogleFonts.shadowsIntoLightTwo(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          contentTextStyle: GoogleFonts.shadowsIntoLightTwo(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Colors.black87,
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}