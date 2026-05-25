import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  // Display — Cormorant Garamond (hero numbers, headings)
  static TextStyle get displayLarge => GoogleFonts.cormorantGaramond(
        fontSize: 64,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get displayMedium => GoogleFonts.cormorantGaramond(
        fontSize: 48,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get displaySmall => GoogleFonts.cormorantGaramond(
        fontSize: 36,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headingLarge => GoogleFonts.cormorantGaramond(
        fontSize: 28,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headingMedium => GoogleFonts.cormorantGaramond(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headingSmall => GoogleFonts.cormorantGaramond(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get displayItalic => GoogleFonts.cormorantGaramond(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      );

  // Body — IBM Plex Sans (all UI text)
  static TextStyle get bodyLarge => GoogleFonts.ibmPlexSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.65,
      );

  static TextStyle get bodyMedium => GoogleFonts.ibmPlexSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.65,
      );

  static TextStyle get bodySmall => GoogleFonts.ibmPlexSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get labelLarge => GoogleFonts.ibmPlexSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get labelMedium => GoogleFonts.ibmPlexSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get labelSmall => GoogleFonts.ibmPlexSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      );

  // Mono — IBM Plex Mono (ALL currency amounts — no exceptions)
  static TextStyle get monoHero => GoogleFonts.ibmPlexMono(
        fontSize: 48,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get monoLarge => GoogleFonts.ibmPlexMono(
        fontSize: 28,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get monoMedium => GoogleFonts.ibmPlexMono(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get monoSmall => GoogleFonts.ibmPlexMono(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get monoXSmall => GoogleFonts.ibmPlexMono(
        fontSize: 10,
        fontWeight: FontWeight.w400,
      );

  // Section labels — IBM Plex Mono, uppercase tracking, always inkDim
  static TextStyle get sectionLabel => GoogleFonts.ibmPlexMono(
        fontSize: 9.5,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.8,
        color: AppColors.inkDim,
      );
}
