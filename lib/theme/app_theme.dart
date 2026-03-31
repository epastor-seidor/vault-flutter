import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Stitch Design System: "The Digital Atelier" (Quiet Luxury)

  // Light Mode Tokens
  static const stBg = Color(0xFFF9F9F7);
  static const stSurface = Color(0xFFFFFFFF); // surfaceContainerLowest in DS
  static const stSurfaceLow = Color(0xFFF2F4F2);
  static const stSurfaceContainer = Color(0xFFECEFEC);
  static const stSurfaceContainerHigh = Color(0xFFE5E9E6);

  static const stPrimary = Color(0xFF5F5E5E);
  static const stPrimaryDim = Color(0xFF535252);
  static const stOnPrimary = Color(0xFFFAF7F6);

  static const stOnSurface = Color(0xFF2D3432);
  static const stOnSurfaceVariant = Color(0xFF5A605E);
  static const stOutlineVariant = Color(0xFFADB3B0); // Ghost border base
  static const stSecondaryContainer = Color(0xFFE5E2DD);
  static const stOnSecondaryContainer = Color(0xFF52524E);
  static const stTertiaryContainer = Color(0xFFF8F3EA);
  static const stOnTertiaryContainer = Color(0xFF5E5B55);

  // Dark Mode Tokens (derived cohesive palette for "Atelier")
  static const darkBg = Color(0xFF141414);
  static const darkSurface = Color(0xFF1C1C1E);
  static const darkSurfaceLow = Color(0xFF242426);
  static const darkPrimary = Color(0xFFE5E2E1);
  static const darkOnPrimary = Color(0xFF2D3432);
  static const darkOnSurface = Color(0xFFF9F9F7);
  static const darkOnSurfaceVariant = Color(0xFFAAAAAA);
  static const darkOutlineVariant = Color(0xFF3A3C3B);

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(
      ThemeData.light().textTheme,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: stPrimary,
      scaffoldBackgroundColor: stBg,
      colorScheme: const ColorScheme.light(
        primary: stPrimary,
        secondary: stPrimaryDim,
        surface: stBg,
        onSurface: stOnSurface,
        surfaceContainerHighest: stSurfaceContainerHigh,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.inter(
          color: stOnSurface,
          fontWeight: FontWeight.w600,
          fontSize: 24,
          letterSpacing: -0.02,
          height: 1.2,
        ),
        titleLarge: GoogleFonts.inter(
          color: stOnSurface,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          letterSpacing: -0.02,
          height: 1.2,
        ),
        titleMedium: GoogleFonts.inter(
          color: stOnSurface,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: -0.02,
          height: 1.2,
        ),
        bodyLarge: GoogleFonts.inter(
          color: stOnSurface,
          fontWeight: FontWeight.w400,
          height: 1.5,
          fontSize: 14,
        ),
        bodyMedium: GoogleFonts.inter(
          color: stOnSurfaceVariant,
          fontWeight: FontWeight.w400,
          height: 1.5,
          fontSize: 14,
        ),
        labelLarge: GoogleFonts.inter(
          color: stOnSurfaceVariant,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: stSurfaceLow,
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide(
            color: stOutlineVariant.withValues(alpha: 0.15),
          ), // Ghost border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide(
            color: stOutlineVariant.withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide(color: stPrimary, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: stSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: stOutlineVariant.withValues(alpha: 0.15)),
        ),
      ),
      dividerColor: stOutlineVariant.withValues(alpha: 0.15),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: darkPrimary,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkPrimary,
        surface: darkBg,
        onSurface: darkOnSurface,
        surfaceContainerHighest: darkSurfaceLow,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.inter(
          color: darkOnSurface,
          fontWeight: FontWeight.w600,
          fontSize: 24,
          letterSpacing: -0.02,
          height: 1.2,
        ),
        titleLarge: GoogleFonts.inter(
          color: darkOnSurface,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          letterSpacing: -0.02,
          height: 1.2,
        ),
        titleMedium: GoogleFonts.inter(
          color: darkOnSurface,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: -0.02,
          height: 1.2,
        ),
        bodyLarge: GoogleFonts.inter(
          color: darkOnSurface,
          fontWeight: FontWeight.w400,
          height: 1.5,
          fontSize: 14,
        ),
        bodyMedium: GoogleFonts.inter(
          color: darkOnSurfaceVariant,
          fontWeight: FontWeight.w400,
          height: 1.5,
          fontSize: 14,
        ),
        labelLarge: GoogleFonts.inter(
          color: darkOnSurfaceVariant,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: darkOutlineVariant.withValues(alpha: 0.3)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: darkOutlineVariant.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: darkOutlineVariant.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: darkPrimary, width: 2),
        ),
      ),
      dividerColor: darkOutlineVariant.withValues(alpha: 0.3),
    );
  }
}
