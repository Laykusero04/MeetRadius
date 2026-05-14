import 'package:flutter/material.dart';

import 'meet_radius_palette.dart';

abstract final class AppTheme {
  static ThemeData dark() {
    const p = MeetRadiusPalette.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
    );
    return base.copyWith(
      extensions: const <ThemeExtension<dynamic>>[p],
      scaffoldBackgroundColor: p.scaffold,
      colorScheme: ColorScheme.dark(
        surface: p.surface,
        primary: p.liveAccent,
        onPrimary: const Color(0xFF042028),
        secondary: p.upcomingBlue,
        onSecondary: Colors.white,
        onSurface: p.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.scaffold,
        foregroundColor: p.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: p.navBar,
        selectedItemColor: p.liveAccent,
        unselectedItemColor: p.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: p.textPrimary,
        displayColor: p.textPrimary,
      ),
      dividerTheme: DividerThemeData(color: p.cardBorderSubtle),
    );
  }

  static ThemeData light() {
    const p = MeetRadiusPalette.light;
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
    );
    return base.copyWith(
      extensions: const <ThemeExtension<dynamic>>[p],
      scaffoldBackgroundColor: p.scaffold,
      colorScheme: ColorScheme.light(
        surface: p.surface,
        primary: p.liveAccent,
        onPrimary: Colors.white,
        secondary: p.upcomingBlue,
        onSecondary: Colors.white,
        onSurface: p.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.scaffold,
        foregroundColor: p.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: p.navBar,
        selectedItemColor: p.liveAccent,
        unselectedItemColor: p.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: p.textPrimary,
        displayColor: p.textPrimary,
      ),
      dividerTheme: DividerThemeData(color: p.cardBorderSubtle),
    );
  }
}
