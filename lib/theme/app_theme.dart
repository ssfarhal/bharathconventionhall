import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // THEME LOCK: light — source: domain signal (venue business, client-facing)
  // Scaffold.backgroundColor = AppTheme.backgroundLight — ALL screens

  static const Color primary = Color(0xFF7B1D3C);
  static const Color primaryContainer = Color(0xFFF9E4EC);
  static const Color primaryLight = Color(0xFFAD4D6A);
  static const Color secondary = Color(0xFFC9963A);
  static const Color secondaryContainer = Color(0xFFFFF3DC);
  static const Color success = Color(0xFF2D7A4F);
  static const Color successContainer = Color(0xFFE6F4ED);
  static const Color warning = Color(0xFFB45309);
  static const Color warningContainer = Color(0xFFFFF3DC);
  static const Color error = Color(0xFFB91C1C);
  static const Color errorContainer = Color(0xFFFDE8E8);

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFFDF3F6);
  static const Color backgroundLight = Color(0xFFF8F4F5);
  static const Color outlineLight = Color(0xFFCCBEC2);
  static const Color outlineVariantLight = Color(0xFFEEE6E9);

  static const Color surfaceDark = Color(0xFF2A1820);
  static const Color backgroundDark = Color(0xFF1A0D12);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: Color(0xFF4A0020),
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: Color(0xFF5A3A00),
      surface: surfaceLight,
      onSurface: Color(0xFF1A1A1A),
      surfaceContainerHighest: surfaceVariantLight,
      onSurfaceVariant: Color(0xFF5A4A50),
      error: error,
      onError: Colors.white,
      outline: outlineLight,
      outlineVariant: outlineVariantLight,
      inverseSurface: Color(0xFF2A1820),
      onInverseSurface: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundLight,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        displayMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        headlineLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        titleSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        bodyMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        bodySmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        labelLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        labelMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        labelSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
    ),
    appBarTheme: AppBarThemeData(
      backgroundColor: surfaceLight,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      iconTheme: const IconThemeData(color: primary),
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A1A),
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceLight,
      indicatorColor: primaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primary,
          );
        }
        return GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF9E9E9E),
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primary, size: 24);
        }
        return const IconThemeData(color: Color(0xFF9E9E9E), size: 24);
      }),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: surfaceVariantLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: outlineLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      labelStyle: const TextStyle(color: Color(0xFF5A4A50)),
      floatingLabelStyle: const TextStyle(color: primary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceVariantLight,
      selectedColor: primaryContainer,
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      side: const BorderSide(color: outlineLight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    dividerTheme: const DividerThemeData(
      color: outlineVariantLight,
      thickness: 1,
      space: 0,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      elevation: 8,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF5A1030),
      onPrimaryContainer: const Color(0xFFF9E4EC),
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFF5A3A00),
      onSecondaryContainer: const Color(0xFFFFF3DC),
      surface: surfaceDark,
      onSurface: const Color(0xFFE6E6E6),
      surfaceContainerHighest: const Color(0xFF3A2028),
      onSurfaceVariant: const Color(0xFFBBADB2),
      error: const Color(0xFFCF6679),
      onError: Colors.white,
      outline: const Color(0xFF8A7A80),
      outlineVariant: const Color(0xFF3A2A30),
      inverseSurface: const Color(0xFFF0E8EA),
      onInverseSurface: const Color(0xFF1A0D12),
    ),
    scaffoldBackgroundColor: backgroundDark,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE6E6E6),
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE6E6E6),
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE6E6E6),
        ),
        bodyMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE6E6E6),
        ),
        bodySmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFFBBADB2),
        ),
      ),
    ),
    appBarTheme: AppBarThemeData(
      backgroundColor: surfaceDark,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFE6E6E6),
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceDark,
      indicatorColor: const Color(0xFF5A1030),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primary,
          );
        }
        return GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF9E9E9E),
        );
      }),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: const Color(0xFF3A2028),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF8A7A80), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
    ),
  );

  // Semantic color helpers
  static Color eventTypeColor(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'wedding':
        return const Color(0xFF7B1D3C);
      case 'reception':
        return const Color(0xFFC9963A);
      case 'engagement':
        return const Color(0xFF2D7A4F);
      case 'birthday':
        return const Color(0xFF1565C0);
      case 'corporate':
        return const Color(0xFF5A189A);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
