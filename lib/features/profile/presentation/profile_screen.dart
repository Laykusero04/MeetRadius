import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Static profile (MVP shell) — wire to user model later.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorderSubtle),
        ),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.avatarPurple,
                  child: Text(
                    'M',
                    style: textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Matt',
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Member since Jan 2025',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const _StatsRow(),
            const SizedBox(height: 20),
            const _StreakCallout(),
            const SizedBox(height: 28),
            Text(
              'BADGES',
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const _BadgesWrap(),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const dividerColor = AppColors.cardBorderSubtle;

    Widget cell(String value, String label) {
      return Expanded(
        child: Column(
          children: [
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        cell('47', 'Activities'),
        Container(width: 1, height: 44, color: dividerColor),
        cell('6', 'Week streak'),
        Container(width: 1, height: 44, color: dividerColor),
        cell('12', 'Hosted'),
      ],
    );
  }
}

class _StreakCallout extends StatelessWidget {
  const _StreakCallout();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.streakCalloutBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.streakCalloutBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '6-week streak',
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.streakCalloutTitle,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep it going — activity this week',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgesWrap extends StatelessWidget {
  const _BadgesWrap();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: const [
        _ProfileBadgeChip(
          label: '25 activities',
          icon: Icons.military_tech_outlined,
          style: _BadgeStyle.earned,
        ),
        _ProfileBadgeChip(
          label: 'Sports',
          icon: Icons.sports_basketball_outlined,
          style: _BadgeStyle.standard,
        ),
        _ProfileBadgeChip(
          label: 'Outdoor',
          icon: Icons.terrain_outlined,
          style: _BadgeStyle.standard,
        ),
        _ProfileBadgeChip(
          label: '50 activities',
          icon: Icons.lock_outline,
          style: _BadgeStyle.locked,
        ),
      ],
    );
  }
}

enum _BadgeStyle { earned, standard, locked }

class _ProfileBadgeChip extends StatelessWidget {
  const _ProfileBadgeChip({
    required this.label,
    required this.icon,
    required this.style,
  });

  final String label;
  final IconData icon;
  final _BadgeStyle style;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    late Color border;
    late Color fg;
    late Color bg;

    switch (style) {
      case _BadgeStyle.earned:
        border = AppColors.badgeEarnedBorder;
        fg = AppColors.badgeEarnedForeground;
        bg = AppColors.streakCalloutBg.withValues(alpha: 0.5);
      case _BadgeStyle.standard:
        border = AppColors.chipBorder;
        fg = AppColors.textSecondary;
        bg = AppColors.surface;
      case _BadgeStyle.locked:
        border = AppColors.cardBorderSubtle;
        fg = AppColors.textMuted;
        bg = AppColors.surface.withValues(alpha: 0.6);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
