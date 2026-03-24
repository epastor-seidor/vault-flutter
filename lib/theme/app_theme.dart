import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Notion-inspired Light Palette
  static const notionLightBg = Color(0xFFFFFFFF);
  static const notionSidebarBg = Color(0xFFF7F6F3);
  static const notionBorder = Color(0xFFE9E9E7);
  static const notionTextPrimary = Color(0xFF37352F);
  static const notionTextSecondary = Color(0x9937352F);
  static const notionPrimary = Color(0xFF2383E2);
  static const notionHover = Color(0xFFEFEFEF);

  // Premium Dark Palette (Deep Charcoal/Navy)
  static const darkBg = Color(0xFF0F1115);
  static const darkSurface = Color(0xFF1A1D23);
  static const darkBorder = Color(0xFF2D323C);
  static const darkTextPrimary = Color(0xFFE2E8F0);
  static const darkTextSecondary = Color(0xFF94A3B8);

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
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(color: notionTextPrimary, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.outfit(color: notionTextPrimary, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.outfit(color: notionTextPrimary, fontWeight: FontWeight.w600, letterSpacing: -0.5),
        bodyLarge: GoogleFonts.outfit(color: notionTextPrimary),
        bodyMedium: GoogleFonts.outfit(color: notionTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: notionLightBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: notionBorder),
        ),
      ),
      dividerTheme: const DividerThemeData(thickness: 1, color: notionBorder),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: notionPrimary,
      colorScheme: ColorScheme.dark(
        primary: notionPrimary,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        outline: darkBorder,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder),
        ),
      ),
      dividerTheme: const DividerThemeData(thickness: 1, color: darkBorder),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
