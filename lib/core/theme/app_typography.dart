import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  // Display — Cormorant Garamond (hero numbers, headings)
  static TextStyle get displayLarge => const TextStyle(
        fontFamily: 'CormorantGaramond',
        fontSize: 64,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get displayMedium => const TextStyle(
        fontFamily: 'CormorantGaramond',
        fontSize: 48,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get displaySmall => const TextStyle(
        fontFamily: 'CormorantGaramond',
        fontSize: 36,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headingLarge => const TextStyle(
        fontFamily: 'CormorantGaramond',
        fontSize: 28,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headingMedium => const TextStyle(
        fontFamily: 'CormorantGaramond',
        fontSize: 22,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headingSmall => const TextStyle(
        fontFamily: 'CormorantGaramond',
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get displayItalic => const TextStyle(
        fontFamily: 'CormorantGaramond',
        fontSize: 22,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      );

  // Body — IBM Plex Sans (all UI text)
  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 11,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get labelLarge => const TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 13,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get labelMedium => const TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get labelSmall => const TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 10,
        fontWeight: FontWeight.w500,
      );

  // Mono — IBM Plex Mono (ALL currency amounts — no exceptions)
  static TextStyle get monoHero => const TextStyle(
        fontFamily: 'IBMPlexMono',
        fontSize: 48,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get monoLarge => const TextStyle(
        fontFamily: 'IBMPlexMono',
        fontSize: 28,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get monoMedium => const TextStyle(
        fontFamily: 'IBMPlexMono',
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get monoSmall => const TextStyle(
        fontFamily: 'IBMPlexMono',
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get monoXSmall => const TextStyle(
        fontFamily: 'IBMPlexMono',
        fontSize: 9.5,
        fontWeight: FontWeight.w400,
      );

  // Section labels — IBM Plex Mono, uppercase tracking, gold
  static TextStyle get sectionLabel => const TextStyle(
        fontFamily: 'IBMPlexMono',
        fontSize: 9.5,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.8,
        color: AppColors.gold,
      );
}
