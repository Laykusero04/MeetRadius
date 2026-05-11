import 'package:flutter/material.dart';

/// MeetRadius dark UI palette (aligned with MVP: local, active, minimal).
abstract final class AppColors {
  static const Color scaffold = Color(0xFF121212);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color card = Color(0xFF1E1E1E);
  static const Color cardBorderSubtle = Color(0xFF2C2C2C);

  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textMuted = Color(0xFF6E6E6E);

  static const Color liveAccent = Color(0xFFE07C4C);
  static const Color liveBorder = Color(0xFF6B3F28);
  static const Color joinLive = Color(0xFF7A4A32);
  static const Color joinLiveForeground = Color(0xFFF5EDE8);

  static const Color upcomingBlue = Color(0xFF4A8AD4);
  static const Color joinUpcoming = Color(0xFF333333);
  static const Color joinUpcomingForeground = Color(0xFFE0E0E0);

  static const Color chipSelectedBorder = Color(0xFFFFFFFF);
  static const Color chipBorder = Color(0xFF3D3D3D);

  static const Color navBar = Color(0xFF141414);
  static const Color liveDot = Color(0xFFE53935);

  static const Color avatarPurple = Color(0xFF7C4DFF);
  static const Color avatarGreen = Color(0xFF43A047);

  /// Profile streak callout (warm, urgent but calm).
  static const Color streakCalloutBg = Color(0xFF2D1F1C);
  static const Color streakCalloutBorder = Color(0xFF8B4A38);
  static const Color streakCalloutTitle = Color(0xFFE8886A);

  /// Milestone / earned badge accent.
  static const Color badgeEarnedBorder = Color(0xFFD4A574);
  static const Color badgeEarnedForeground = Color(0xFFE8C99A);
}
