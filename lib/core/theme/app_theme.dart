import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dml_hub/core/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get darkTheme {
    final scheme = const ColorScheme.dark(
      primary: AppColors.dmlBlue,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceVariant,
      error: AppColors.error,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.nunitoSansTextTheme(
        ThemeData.dark(useMaterial3: true).textTheme,
      ),
    );

    return base.copyWith(
      cardTheme: CardThemeData(
        color: AppColors.surfaceVariant,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.dmlBlue,
        foregroundColor: Colors.white,
      ),
    );
  }
}
