import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.cyan,
      surface: AppColors.panel,
      error: AppColors.danger,
      onPrimary: AppColors.background,
      onSurface: AppColors.textPrimary,
    );

    final base = ThemeData(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,
      fontFamily: 'Segoe UI',
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displaySmall: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.4,
          color: AppColors.textPrimary,
        ),
        headlineSmall: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: AppColors.textPrimary,
        ),
        titleLarge: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: const TextStyle(
          fontSize: 15,
          height: 1.45,
          color: AppColors.textPrimary,
        ),
        bodyMedium: const TextStyle(
          fontSize: 13,
          height: 1.4,
          color: AppColors.textSecondary,
        ),
        labelLarge: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      dividerColor: AppColors.panelBorder,
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.panelLight,
          border: Border.all(color: AppColors.panelBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.panelLight,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
