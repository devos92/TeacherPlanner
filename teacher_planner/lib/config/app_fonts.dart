// lib/config/app_fonts.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  // Fancy font for display elements (headers, titles, etc.)
  static TextStyle get displayLarge => GoogleFonts.shadowsIntoLightTwo(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  
  static TextStyle get displayMedium => GoogleFonts.shadowsIntoLightTwo(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
  
  static TextStyle get displaySmall => GoogleFonts.shadowsIntoLightTwo(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
  
  static TextStyle get headlineLarge => GoogleFonts.shadowsIntoLightTwo(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Colors.black87,
  );
  
  static TextStyle get headlineMedium => GoogleFonts.shadowsIntoLightTwo(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
  
  static TextStyle get headlineSmall => GoogleFonts.shadowsIntoLightTwo(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
  
  // Normal font for user input and settings
  static TextStyle get titleLarge => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
    fontFamily: 'Roboto',
  );
  
  static TextStyle get titleMedium => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
    fontFamily: 'Roboto',
  );
  
  static TextStyle get titleSmall => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
    fontFamily: 'Roboto',
  );
  
  static TextStyle get bodyLarge => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
    fontFamily: 'Roboto',
  );
  
  static TextStyle get bodyMedium => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
    fontFamily: 'Roboto',
  );
  
  static TextStyle get bodySmall => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
    fontFamily: 'Roboto',
  );
  
  static TextStyle get labelLarge => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
    fontFamily: 'Roboto',
  );
  
  static TextStyle get labelMedium => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
    fontFamily: 'Roboto',
  );
  
  static TextStyle get labelSmall => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
    fontFamily: 'Roboto',
  );
  
  // Special styles for specific elements
  static TextStyle get weekDayHeader => GoogleFonts.shadowsIntoLightTwo(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  static TextStyle get periodLabel => GoogleFonts.shadowsIntoLightTwo(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
  
  static TextStyle get lessonTitle => GoogleFonts.shadowsIntoLightTwo(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.black87,
  );
  
  static TextStyle get lessonSubtitle => GoogleFonts.shadowsIntoLightTwo(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );
  
  // Normal font for user input content
  static TextStyle get lessonContent => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
    height: 1.4,
    fontFamily: 'Roboto',
  );
  
  static TextStyle get userInput => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
    fontFamily: 'Roboto',
  );
  
  static TextStyle get buttonText => GoogleFonts.shadowsIntoLightTwo(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  static TextStyle get dialogTitle => GoogleFonts.shadowsIntoLightTwo(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
  
  static TextStyle get dialogContent => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
    fontFamily: 'Roboto',
  );
  
  // Helper method to get font with custom parameters
  static TextStyle custom({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
    bool fancy = false, // Add parameter to choose font style
  }) {
    if (fancy) {
      return GoogleFonts.shadowsIntoLightTwo(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        decoration: decoration,
      );
    } else {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        decoration: decoration,
        fontFamily: 'Roboto',
      );
    }
  }
} 