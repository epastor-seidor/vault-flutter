import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Notion-inspired Design System
  // Warm grays, flat design, small radii, content-first

  // Light Mode Tokens (Notion palette)
  static const stBg = Color(0xFFFFFFFF);
  static const stSurface = Color(0xFFFFFFFF);
  static const stSurfaceLow = Color(0xFFF7F7F5);
  static const stSurfaceContainer = Color(0xFFF1F1EF);
  static const stSurfaceContainerHigh = Color(0xFFEBEBE9);

  // Notion warm gray primary
  static const stPrimary = Color(0xFF37352F);
  static const stPrimaryDim = Color(0xFF2F2F2F);
  static const stOnPrimary = Color(0xFFFFFFFF);

  static const stOnSurface = Color(0xFF37352F);
  static const stOnSurfaceVariant = Color(0xFF9B9A97);
  static const stOutlineVariant = Color(0xFFE3E2E0);
  static const stSecondaryContainer = Color(0xFFF1F1EF);
  static const stOnSecondaryContainer = Color(0xFF787774);
  static const stTertiaryContainer = Color(0xFFF7F7F5);
  static const stOnTertiaryContainer = Color(0xFF787774);

  // Semantic Colors - Light (Notion 10-color system)
  static const successLight = Color(0xFF4DAB92);
  static const successBgLight = Color(0xFFEEF3ED);
  static const successOnBgLight = Color(0xFF548164);
  static const errorLight = Color(0xFFEB5757);
  static const errorBgLight = Color(0xFFFAECEC);
  static const errorOnBgLight = Color(0xFFC4554D);
  static const warningLight = Color(0xFFFF9122);
  static const warningBgLight = Color(0xFFFAF3DD);
  static const warningOnBgLight = Color(0xFFC29143);
  static const infoLight = Color(0xFF529CCA);
  static const infoBgLight = Color(0xFFE9F3F7);
  static const infoOnBgLight = Color(0xFF487CA5);

  // Semantic Colors - Dark
  static const successDark = Color(0xFF2D9964);
  static const successBgDark = Color(0xFF242B26);
  static const successOnBgDark = Color(0xFF4F9768);
  static const errorDark = Color(0xFFCD4945);
  static const errorBgDark = Color(0xFF332523);
  static const errorOnBgDark = Color(0xFFBE524B);
  static const warningDark = Color(0xFFCA8E1B);
  static const warningBgDark = Color(0xFF372E20);
  static const warningOnBgDark = Color(0xFFC19138);
  static const infoDark = Color(0xFF2E7CD1);
  static const infoBgDark = Color(0xFF1F282D);
  static const infoOnBgDark = Color(0xFF447ACB);

  // Dark Mode Tokens (Notion dark palette)
  static const darkBg = Color(0xFF191919);
  static const darkSurface = Color(0xFF202020);
  static const darkSurfaceLow = Color(0xFF252525);
  static const darkPrimary = Color(0xFFD4D4D4);
  static const darkOnPrimary = Color(0xFF191919);
  static const darkOnSurface = Color(0xFFD4D4D4);
  static const darkOnSurfaceVariant = Color(0xFF9B9B9B);
  static const darkOutlineVariant = Color(0xFF333333);

  // Semantic color accessor
  static SemanticColors semantic(bool isDark) => SemanticColors(isDark: isDark);

  // Spacing Scale (4px grid - Notion style)
  static final spacing = const _SpacingTokens();

  // Border Radius Scale (Notion uses small radii: 3px)
  static final radius = const _RadiusTokens();

  // Animation Duration Scale
  static final animation = const _AnimationTokens();

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
          fontWeight: FontWeight.w700,
          fontSize: 30,
          letterSpacing: -0.02,
          height: 1.2,
        ),
        headlineLarge: GoogleFonts.inter(
          color: stOnSurface,
          fontWeight: FontWeight.w600,
          fontSize: 24,
          letterSpacing: -0.01,
          height: 1.3,
        ),
        headlineMedium: GoogleFonts.inter(
          color: stOnSurface,
          fontWeight: FontWeight.w600,
          fontSize: 20,
          letterSpacing: -0.01,
          height: 1.3,
        ),
        headlineSmall: GoogleFonts.inter(
          color: stOnSurface,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0,
          height: 1.4,
        ),
        titleLarge: GoogleFonts.inter(
          color: stOnSurface,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0,
          height: 1.4,
        ),
        titleMedium: GoogleFonts.inter(
          color: stOnSurface,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: 0,
          height: 1.4,
        ),
        bodyLarge: GoogleFonts.inter(
          color: stOnSurface,
          fontWeight: FontWeight.w400,
          height: 1.5,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.inter(
          color: stOnSurface,
          fontWeight: FontWeight.w400,
          height: 1.5,
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.inter(
          color: stOnSurfaceVariant,
          fontWeight: FontWeight.w400,
          height: 1.5,
          fontSize: 12,
        ),
        labelLarge: GoogleFonts.inter(
          color: stOnSurfaceVariant,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        labelMedium: GoogleFonts.inter(
          color: stOnSurfaceVariant,
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: stSurfaceLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(color: stOutlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(color: stOutlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: const BorderSide(color: Color(0xFF529CCA), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      cardTheme: CardThemeData(
        color: stSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
          side: const BorderSide(color: Color(0x1737352F), width: 1),
        ),
      ),
      dividerColor: const Color(0x1737352F),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: stPrimaryDim,
          foregroundColor: stOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: stOnSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF55534E), size: 20),
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
          fontWeight: FontWeight.w700,
          fontSize: 30,
          letterSpacing: -0.02,
          height: 1.2,
        ),
        headlineLarge: GoogleFonts.inter(
          color: darkOnSurface,
          fontWeight: FontWeight.w600,
          fontSize: 24,
          letterSpacing: -0.01,
          height: 1.3,
        ),
        headlineMedium: GoogleFonts.inter(
          color: darkOnSurface,
          fontWeight: FontWeight.w600,
          fontSize: 20,
          letterSpacing: -0.01,
          height: 1.3,
        ),
        headlineSmall: GoogleFonts.inter(
          color: darkOnSurface,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0,
          height: 1.4,
        ),
        titleLarge: GoogleFonts.inter(
          color: darkOnSurface,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0,
          height: 1.4,
        ),
        titleMedium: GoogleFonts.inter(
          color: darkOnSurface,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: 0,
          height: 1.4,
        ),
        bodyLarge: GoogleFonts.inter(
          color: darkOnSurface,
          fontWeight: FontWeight.w400,
          height: 1.5,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.inter(
          color: darkOnSurface,
          fontWeight: FontWeight.w400,
          height: 1.5,
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.inter(
          color: darkOnSurfaceVariant,
          fontWeight: FontWeight.w400,
          height: 1.5,
          fontSize: 12,
        ),
        labelLarge: GoogleFonts.inter(
          color: darkOnSurfaceVariant,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        labelMedium: GoogleFonts.inter(
          color: darkOnSurfaceVariant,
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(color: darkOutlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(color: darkOutlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: const BorderSide(color: Color(0xFF447ACB), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
          side: const BorderSide(color: Color(0x26FFFFFF), width: 1),
        ),
      ),
      dividerColor: const Color(0x26FFFFFF),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4D4D4),
          foregroundColor: const Color(0xFF191919),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkOnSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: Color(0xFFD3D3D3), size: 20),
    );
  }
}

class _SpacingTokens {
  const _SpacingTokens();
  double get xs => 4;
  double get sm => 8;
  double get md => 12;
  double get lg => 16;
  double get xl => 24;
  double get xxl => 32;
  double get xxxl => 48;
  double get huge => 64;
}

class _RadiusTokens {
  const _RadiusTokens();
  double get sm => 3;
  double get md => 5;
  double get lg => 8;
  double get xl => 12;
  double get full => 9999;
}

class _AnimationTokens {
  const _AnimationTokens();
  Duration get fast => const Duration(milliseconds: 100);
  Duration get normal => const Duration(milliseconds: 150);
  Duration get slow => const Duration(milliseconds: 200);
  Duration get slower => const Duration(milliseconds: 300);
  Curve get spring => Curves.easeOutBack;
  Curve get smooth => Curves.easeInOut;
  Curve get quick => Curves.easeOut;
}

class SemanticColors {
  final bool isDark;
  const SemanticColors({required this.isDark});

  Color get success => isDark ? AppTheme.successDark : AppTheme.successLight;
  Color get successBg =>
      isDark ? AppTheme.successBgDark : AppTheme.successBgLight;
  Color get successOnBg =>
      isDark ? AppTheme.successOnBgDark : AppTheme.successOnBgLight;
  Color get error => isDark ? AppTheme.errorDark : AppTheme.errorLight;
  Color get errorBg => isDark ? AppTheme.errorBgDark : AppTheme.errorBgLight;
  Color get errorOnBg =>
      isDark ? AppTheme.errorOnBgDark : AppTheme.errorOnBgLight;
  Color get warning => isDark ? AppTheme.warningDark : AppTheme.warningLight;
  Color get warningBg =>
      isDark ? AppTheme.warningBgDark : AppTheme.warningBgLight;
  Color get warningOnBg =>
      isDark ? AppTheme.warningOnBgDark : AppTheme.warningOnBgLight;
  Color get info => isDark ? AppTheme.infoDark : AppTheme.infoLight;
  Color get infoBg => isDark ? AppTheme.infoBgDark : AppTheme.infoBgLight;
  Color get infoOnBg => isDark ? AppTheme.infoOnBgDark : AppTheme.infoOnBgLight;
}
