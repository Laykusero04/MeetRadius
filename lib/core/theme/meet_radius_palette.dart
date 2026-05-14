import 'package:flutter/material.dart';

/// Brand + semantic colors for MeetRadius (cyan → purple). Registered per [ThemeData].
@immutable
class MeetRadiusPalette extends ThemeExtension<MeetRadiusPalette> {
  const MeetRadiusPalette({
    required this.brandCyan,
    required this.brandPurple,
    required this.brandPurpleDeep,
    required this.scaffold,
    required this.surface,
    required this.card,
    required this.cardBorderSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.liveAccent,
    required this.liveBorder,
    required this.joinLive,
    required this.joinLiveForeground,
    required this.upcomingBlue,
    required this.joinUpcoming,
    required this.joinUpcomingForeground,
    required this.chipSelectedBorder,
    required this.chipBorder,
    required this.navBar,
    required this.liveDot,
    required this.avatarPurple,
    required this.avatarGreen,
    required this.streakCalloutBg,
    required this.streakCalloutBorder,
    required this.streakCalloutTitle,
    required this.badgeEarnedBorder,
    required this.badgeEarnedForeground,
  });

  final Color brandCyan;
  final Color brandPurple;
  final Color brandPurpleDeep;
  final Color scaffold;
  final Color surface;
  final Color card;
  final Color cardBorderSubtle;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color liveAccent;
  final Color liveBorder;
  final Color joinLive;
  final Color joinLiveForeground;
  final Color upcomingBlue;
  final Color joinUpcoming;
  final Color joinUpcomingForeground;
  final Color chipSelectedBorder;
  final Color chipBorder;
  final Color navBar;
  final Color liveDot;
  final Color avatarPurple;
  final Color avatarGreen;
  final Color streakCalloutBg;
  final Color streakCalloutBorder;
  final Color streakCalloutTitle;
  final Color badgeEarnedBorder;
  final Color badgeEarnedForeground;

  static const MeetRadiusPalette dark = MeetRadiusPalette(
    brandCyan: Color(0xFF22D3EE),
    brandPurple: Color(0xFF9333EA),
    brandPurpleDeep: Color(0xFF6D28D9),
    scaffold: Color(0xFF030306),
    surface: Color(0xFF0C0C12),
    card: Color(0xFF111118),
    cardBorderSubtle: Color(0xFF232330),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    liveAccent: Color(0xFF22D3EE),
    liveBorder: Color(0xFF4C3D7A),
    joinLive: Color(0xFF2A1F4A),
    joinLiveForeground: Color(0xFFEEF8FF),
    upcomingBlue: Color(0xFF9333EA),
    joinUpcoming: Color(0xFF15151F),
    joinUpcomingForeground: Color(0xFFE4E4EF),
    chipSelectedBorder: Color(0xFF22D3EE),
    chipBorder: Color(0xFF2A2A38),
    navBar: Color(0xFF050508),
    liveDot: Color(0xFFE53935),
    avatarPurple: Color(0xFF9333EA),
    avatarGreen: Color(0xFF14B8A6),
    streakCalloutBg: Color(0xFF151022),
    streakCalloutBorder: Color(0xFF4C3D7A),
    streakCalloutTitle: Color(0xFF7DD3FC),
    badgeEarnedBorder: Color(0xFFC4B5FD),
    badgeEarnedForeground: Color(0xFFF3E8FF),
  );

  static const MeetRadiusPalette light = MeetRadiusPalette(
    brandCyan: Color(0xFF0891B2),
    brandPurple: Color(0xFF7C3AED),
    brandPurpleDeep: Color(0xFF6D28D9),
    scaffold: Color(0xFFF8FAFC),
    surface: Color(0xFFF1F5F9),
    card: Color(0xFFFFFFFF),
    cardBorderSubtle: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF64748B),
    liveAccent: Color(0xFF0891B2),
    liveBorder: Color(0xFFC4B5FD),
    joinLive: Color(0xFFEDE9FE),
    joinLiveForeground: Color(0xFF1E1B4B),
    upcomingBlue: Color(0xFF7C3AED),
    joinUpcoming: Color(0xFFF1F5F9),
    joinUpcomingForeground: Color(0xFF334155),
    chipSelectedBorder: Color(0xFF0891B2),
    chipBorder: Color(0xFFCBD5E1),
    navBar: Color(0xFFFFFFFF),
    liveDot: Color(0xFFE53935),
    avatarPurple: Color(0xFF7C3AED),
    avatarGreen: Color(0xFF0D9488),
    streakCalloutBg: Color(0xFFF5F3FF),
    streakCalloutBorder: Color(0xFFC4B5FD),
    streakCalloutTitle: Color(0xFF0369A1),
    badgeEarnedBorder: Color(0xFF9333EA),
    badgeEarnedForeground: Color(0xFF581C87),
  );

  @override
  MeetRadiusPalette copyWith({
    Color? brandCyan,
    Color? brandPurple,
    Color? brandPurpleDeep,
    Color? scaffold,
    Color? surface,
    Color? card,
    Color? cardBorderSubtle,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? liveAccent,
    Color? liveBorder,
    Color? joinLive,
    Color? joinLiveForeground,
    Color? upcomingBlue,
    Color? joinUpcoming,
    Color? joinUpcomingForeground,
    Color? chipSelectedBorder,
    Color? chipBorder,
    Color? navBar,
    Color? liveDot,
    Color? avatarPurple,
    Color? avatarGreen,
    Color? streakCalloutBg,
    Color? streakCalloutBorder,
    Color? streakCalloutTitle,
    Color? badgeEarnedBorder,
    Color? badgeEarnedForeground,
  }) {
    return MeetRadiusPalette(
      brandCyan: brandCyan ?? this.brandCyan,
      brandPurple: brandPurple ?? this.brandPurple,
      brandPurpleDeep: brandPurpleDeep ?? this.brandPurpleDeep,
      scaffold: scaffold ?? this.scaffold,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      cardBorderSubtle: cardBorderSubtle ?? this.cardBorderSubtle,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      liveAccent: liveAccent ?? this.liveAccent,
      liveBorder: liveBorder ?? this.liveBorder,
      joinLive: joinLive ?? this.joinLive,
      joinLiveForeground: joinLiveForeground ?? this.joinLiveForeground,
      upcomingBlue: upcomingBlue ?? this.upcomingBlue,
      joinUpcoming: joinUpcoming ?? this.joinUpcoming,
      joinUpcomingForeground:
          joinUpcomingForeground ?? this.joinUpcomingForeground,
      chipSelectedBorder: chipSelectedBorder ?? this.chipSelectedBorder,
      chipBorder: chipBorder ?? this.chipBorder,
      navBar: navBar ?? this.navBar,
      liveDot: liveDot ?? this.liveDot,
      avatarPurple: avatarPurple ?? this.avatarPurple,
      avatarGreen: avatarGreen ?? this.avatarGreen,
      streakCalloutBg: streakCalloutBg ?? this.streakCalloutBg,
      streakCalloutBorder: streakCalloutBorder ?? this.streakCalloutBorder,
      streakCalloutTitle: streakCalloutTitle ?? this.streakCalloutTitle,
      badgeEarnedBorder: badgeEarnedBorder ?? this.badgeEarnedBorder,
      badgeEarnedForeground:
          badgeEarnedForeground ?? this.badgeEarnedForeground,
    );
  }

  @override
  MeetRadiusPalette lerp(ThemeExtension<MeetRadiusPalette>? other, double t) {
    if (other is! MeetRadiusPalette) return this;
    if (t < 0.5) return this;
    return other;
  }
}

extension MeetRadiusPaletteContext on BuildContext {
  MeetRadiusPalette get palette =>
      Theme.of(this).extension<MeetRadiusPalette>() ?? MeetRadiusPalette.dark;
}
