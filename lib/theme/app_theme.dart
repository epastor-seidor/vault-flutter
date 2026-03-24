import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Notion-inspired Palette
  static const notionLightBg = Color(0xFFFFFFFF);
  static const notionSidebarBg = Color(0xFFF7F6F3);
  static const notionBorder = Color(0xFFE9E9E7);
  static const notionTextPrimary = Color(0xFF37352F);
  static const notionTextSecondary = Color(0x9937352F);
  static const notionPrimary = Color(0xFF2383E2); // Notion's blue for links/actions
  static const notionHover = Color(0xFFEFEFEF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: notionPrimary,
      scaffoldBackgroundColor: notionLightBg,
      colorScheme: ColorScheme.light(
        primary: notionPrimary,
        secondary: notionPrimary,
        surface: notionLightBg,
        onSurface: notionTextPrimary,
        outline: notionBorder,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(color: notionTextPrimary, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.inter(color: notionTextPrimary, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.inter(color: notionTextPrimary, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: notionTextPrimary),
        bodyMedium: GoogleFonts.inter(color: notionTextPrimary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: notionLightBg,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: notionTextPrimary),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: notionTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: notionLightBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: notionBorder),
        ),
      ),
      dividerTheme: const DividerThemeData(
        thickness: 1,
        color: notionBorder,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: notionBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: notionBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: notionPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // Dark variant if needed
  static ThemeData get darkTheme {
    return ThemeData(
       useMaterial3: true,
       brightness: Brightness.dark,
       scaffoldBackgroundColor: const Color(0xFF191919),
       primaryColor: notionPrimary,
       colorScheme: const ColorScheme.dark(
         primary: notionPrimary,
         surface: Color(0xFF202020),
         onSurface: Colors.white,
       ),
       textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
       cardTheme: CardThemeData(
         color: const Color(0xFF202020),
         elevation: 0,
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(8),
           side: const BorderSide(color: Colors.white12),
         ),
       ),
    );
  }
}

