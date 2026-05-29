import 'package:flutter/material.dart';
import '../constants/spacing.dart';
import 'app_colors.dart';
import 'app_typography.dart';

const _inputRadius = BorderRadius.all(Radius.circular(AppRadius.sm));

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.red,
          onPrimary: Colors.white,
          surface: AppColors.surface,
          onSurface: AppColors.ink,
          outline: AppColors.border,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 1,
          shadowColor: AppColors.border,
          centerTitle: false,
          titleTextStyle: AppTypography.headingMedium.copyWith(
            color: AppColors.red,
          ),
          iconTheme: const IconThemeData(color: AppColors.ink),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.red,
          unselectedItemColor: AppColors.inkDim,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 1,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.border),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.inkDim),
          border: const OutlineInputBorder(
            borderRadius: _inputRadius,
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: _inputRadius,
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: _inputRadius,
            borderSide: BorderSide(color: AppColors.red, width: 1.5),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: _inputRadius,
            borderSide: BorderSide(color: AppColors.red),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.red,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: const RoundedRectangleBorder(borderRadius: _inputRadius),
            textStyle: AppTypography.labelLarge,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      );
}
