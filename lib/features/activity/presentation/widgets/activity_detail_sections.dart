import 'package:flutter/material.dart';

import '../../../../core/theme/meet_radius_palette.dart';
import '../../domain/activity.dart';
import '../../domain/activity_capacity_labels.dart';
import '../../../../features/feed/presentation/widgets/activity_feed_labels.dart';
import '../../../../features/profile/data/fetch_public_user_profile.dart';
import '../../../../features/profile/domain/user_profile.dart';

/// One row in the activity details summary (icon + label + value).
class ActivityDetailRow extends StatelessWidget {
  const ActivityDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: p.textMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  color: p.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  color: valueColor ?? p.textPrimary,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Host / creator block (public profile when available).
class ActivityHostSummaryCard extends StatelessWidget {
  const ActivityHostSummaryCard({
    super.key,
    required this.hostUid,
    this.hostEmail,
  });

  final String hostUid;
  final String? hostEmail;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;

    if (hostUid.isEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<UserProfile?>(
      future: fetchPublicUserProfile(hostUid),
      builder: (context, profileSnap) {
        final profile = profileSnap.data;
        final displayName = profile?.displayName ??
            (hostEmail != null && hostEmail!.isNotEmpty
                ? hostEmail!.split('@').first
                : 'Host');
        final emailFromProfile = profile?.email;
        final subtitle = (emailFromProfile != null && emailFromProfile.isNotEmpty)
            ? emailFromProfile
            : (hostEmail ?? 'Posted this activity');

        return DecoratedBox(
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.cardBorderSubtle),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: p.brandPurple.withValues(alpha: 0.35),
                  foregroundColor: p.textPrimary,
                  child: profileSnap.connectionState == ConnectionState.waiting &&
                          profile == null
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: p.textPrimary,
                          ),
                        )
                      : Text(
                          profile?.initials ??
                              (hostUid.length >= 2
                                  ? hostUid.substring(0, 2)
                                  : hostUid)
                                  .toUpperCase(),
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Creator',
                        style: textTheme.labelMedium?.copyWith(
                          color: p.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          color: p.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: p.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: p.liveAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'HOST',
                    style: textTheme.labelSmall?.copyWith(
                      color: p.liveAccent,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Category, status, schedule, spot, size.
class ActivityDetailsSummaryCard extends StatelessWidget {
  const ActivityDetailsSummaryCard({
    super.key,
    required this.activity,
    required this.now,
  });

  final Activity activity;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final spot = activity.spot.trim().isEmpty ? 'Not set' : activity.spot.trim();
    final schedule = activitySchedulePill(activity.startsAt);
    final relative = activityStartsInLine(activity.startsAt, now);
    final endsAt = activity.endsAt;
    final endsSchedule =
        endsAt != null ? activitySchedulePill(endsAt) : null;
    final endsRelative =
        endsAt != null ? activityEndsInLine(endsAt, now) : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.cardBorderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DETAILS',
              style: textTheme.labelLarge?.copyWith(
                color: p.textMuted,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 14),
            ActivityDetailRow(
              icon: Icons.label_outline,
              label: 'Category',
              value: activity.category,
            ),
            const SizedBox(height: 12),
            ActivityDetailRow(
              icon: activity.isEnded
                  ? Icons.stop_circle_outlined
                  : (activity.isLive
                      ? Icons.bolt
                      : Icons.event_available_outlined),
              label: 'Status',
              value: activity.isEnded || activity.isPastScheduledEnd(now)
                  ? 'Ended'
                  : (activity.isLive ? 'Live now' : 'Upcoming'),
              valueColor: activity.isEnded || activity.isPastScheduledEnd(now)
                  ? p.textMuted
                  : (activity.isLive ? p.liveAccent : p.upcomingBlue),
            ),
            const SizedBox(height: 12),
            ActivityDetailRow(
              icon: Icons.schedule_outlined,
              label: 'Starts',
              value: '$schedule · $relative',
            ),
            if (endsSchedule != null && endsRelative != null) ...[
              const SizedBox(height: 12),
              ActivityDetailRow(
                icon: Icons.timer_off_outlined,
                label: 'Ends',
                value: '$endsSchedule · $endsRelative',
                valueColor: activity.isPastScheduledEnd(now)
                    ? p.textMuted
                    : null,
              ),
            ],
            const SizedBox(height: 12),
            ActivityDetailRow(
              icon: Icons.place_outlined,
              label: 'Meeting spot',
              value: spot,
            ),
            const SizedBox(height: 12),
            ActivityDetailRow(
              icon: Icons.people_outline,
              label: 'Size',
              value: activityCapacityDetail(activity),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple tappable row (feed-style: flat card, one accent line).
class ActivityOutlineNavRow extends StatelessWidget {
  const ActivityOutlineNavRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final a = accent ?? p.liveAccent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.chipBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: a.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: a, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleSmall?.copyWith(
                          color: p.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: p.textMuted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: p.textMuted, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
