import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Google Material 3 / Password Manager Palette
  // Dark Mode
  static const darkBg = Color(0xFF202124); // Google Dark Gray
  static const darkSurface = Color(0xFF282A2D); // Slightly elevated Google surface
  static const darkBorder = Color(0xFF3C4043); // Google Dark Border
  static const darkTextPrimary = Color(0xFFE8EAED); // Off-white for readability
  static const darkTextSecondary = Color(0xFF9AA0A6);

  // Light Mode  
  static const lightBg = Color(0xFFF8F9FA); // Google very bright gray background
  static const lightSurface = Color(0xFFFFFFFF); // Pure White Surface
  static const lightBorder = Color(0xFFDADCE0); // Google Light Border
  static const lightTextPrimary = Color(0xFF202124); // Almost Black
  static const lightTextSecondary = Color(0xFF5F6368);

  // Google Accents
  static const accentPrimary = Color(0xFF1A73E8); // Google Blue
  static const accentSecondary = Color(0xFF185ABC); // Darker Google Blue (Hover/Action)

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: accentPrimary,
      scaffoldBackgroundColor: lightBg,
      colorScheme: const ColorScheme.light(
        primary: accentPrimary,
        secondary: accentSecondary,
        surface: lightSurface,
        onSurface: lightTextPrimary,
        surfaceContainerHighest: Color(0xFFE8EAED), // Accent M3 
      ),
      textTheme: GoogleFonts.robotoTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.roboto(color: lightTextPrimary, fontWeight: FontWeight.w400, letterSpacing: 0),
        titleLarge: GoogleFonts.roboto(color: lightTextPrimary, fontWeight: FontWeight.w500, letterSpacing: 0.15),
        bodyLarge: GoogleFonts.roboto(color: lightTextPrimary, letterSpacing: 0.5),
        bodyMedium: GoogleFonts.roboto(color: lightTextPrimary, letterSpacing: 0.25),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF1F3F4), // Google-like filled fields
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFFDADCE0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFFDADCE0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFF1A73E8), width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightBorder),
        ),
      ),
      dividerColor: lightBorder,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: const Color(0xFF8AB4F8), // Google Light Blue for Dark Mode
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF8AB4F8),
        secondary: accentPrimary,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        surfaceContainerHighest: Color(0xFF3C4043),
      ),
      textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.roboto(color: darkTextPrimary, fontWeight: FontWeight.w400, letterSpacing: 0),
        titleLarge: GoogleFonts.roboto(color: darkTextPrimary, fontWeight: FontWeight.w500, letterSpacing: 0.15),
        bodyLarge: GoogleFonts.roboto(color: darkTextPrimary, letterSpacing: 0.5),
        bodyMedium: GoogleFonts.roboto(color: darkTextPrimary, letterSpacing: 0.25),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF303134), // Google TextField dark
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: darkBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: darkBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF8AB4F8), width: 2)),
      ),
      dividerColor: darkBorder,
    );
  }
}
