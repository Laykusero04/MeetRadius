import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
    );
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.scaffold,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.liveAccent,
        onPrimary: AppColors.textPrimary,
        secondary: AppColors.upcomingBlue,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.scaffold,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.navBar,
        selectedItemColor: AppColors.textPrimary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.cardBorderSubtle),
    );
  }
}
