import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NileAppTheme {
  const NileAppTheme._();

  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFFF8F4EC);
  static const Color surface = Color(0xFFFFFCF6);
  static const Color text = Color(0xFF1F1A14);

  static ThemeData light() {
    final baseTextTheme = ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: gold,
        brightness: Brightness.light,
        primary: gold,
        secondary: const Color(0xFF0E6B68),
        surface: surface,
      ),
      textTheme: GoogleFonts.cairoTextTheme(baseTextTheme).copyWith(
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: text,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: text,
        ),
        titleMedium: GoogleFonts.cairo(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: text,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: text,
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 11,
          color: const Color(0xFF6D6256),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: text,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF153F4A),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF153F4A),
          minimumSize: const Size.fromHeight(54),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          side: BorderSide(
            color: const Color(0xFF153F4A).withValues(alpha: 0.22),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: gold.withValues(alpha: 0.18),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? text : const Color(0xFF766B5F),
          );
        }),
      ),
    );
  }
}
