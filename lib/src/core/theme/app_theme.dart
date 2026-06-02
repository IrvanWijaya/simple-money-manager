import 'package:flutter/material.dart';

/// Foundational dark theme for the Simple Money Manager app.
///
/// Feature surfaces build on top of this baseline. Colors and typography are
/// intentionally conservative here; later UI features refine them toward the
/// reference screens.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  // Primary action / selected-control blue, matching the reference add button
  // and highlighted controls. Income values use a slightly lighter blue, and
  // expense values use red/pink, per the reference screens.
  static const Color primary = Color(0xFF2F80FF);
  static const Color income = Color(0xFF4F9DF5);
  static const Color expense = Color(0xFFE53935);
  static const Color onBackground = Color(0xFFE0E0E0);
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final colorScheme = const ColorScheme.dark(
      primary: AppColors.primary,
      surface: AppColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onBackground,
        elevation: 0,
      ),
    );
  }
}
