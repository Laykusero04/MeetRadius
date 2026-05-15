import 'package:flutter/material.dart';

import '../../../../core/theme/meet_radius_palette.dart';
import '../../../../shared/widgets/brand_gradient.dart';
import '../../domain/activity.dart';
import '../../domain/activity_check_in.dart';
import '../../domain/activity_capacity_labels.dart';
import '../../domain/activity_membership.dart';
import '../activity_actions.dart';
import 'activity_check_in_button.dart';

/// Primary / secondary actions for [FeedActivityDetailScreen].
class ActivityDetailActionBar extends StatelessWidget {
  const ActivityDetailActionBar({
    super.key,
    required this.activity,
    required this.activityTitle,
    this.busy = false,
  });

  final Activity activity;
  final String activityTitle;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final uid = currentActivityUserUid;
    final title = activityDisplayTitle(activity, activityTitle);

    if (uid == null) {
      return _BarShell(
        child: Text(
          'Sign in to join this activity.',
          style: textTheme.bodyMedium?.copyWith(color: p.textSecondary),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (activity.isOver && !activityCanOpenChat(activity, uid)) {
      return _BarShell(
        child: Text(
          'This activity has ended.',
          style: textTheme.bodyMedium?.copyWith(color: p.textMuted),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (activityCanOpenChat(activity, uid)) {
      return _BarShell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ActivityCheckInButton(activity: activity),
            if (activityCanCheckIn(activity, uid) ||
                activity.hasCheckedIn(uid)) ...[
              const SizedBox(height: 10),
            ],
            GradientCtaButton(
              onPressed: busy
                  ? null
                  : () => openActivityChat(
                        context,
                        activityId: activity.id,
                        activityTitle: title,
                      ),
              child: Text(
                activity.isOver ? 'Open chat (ended)' : 'Open chat',
              ),
            ),
            if (activityCanLeave(activity, uid)) ...[
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: busy
                    ? null
                    : () => performActivityMembershipAction(
                          context,
                          activity,
                          activityTitle: activityTitle,
                          openChatAfterJoin: false,
                        ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: p.textSecondary,
                  side: BorderSide(color: p.chipBorder),
                ),
                child: const Text('Leave activity'),
              ),
            ],
          ],
        ),
      );
    }

    if (activityCanJoin(activity, uid)) {
      return _BarShell(
        child: GradientCtaButton(
          onPressed: busy
              ? null
              : () => performActivityMembershipAction(
                    context,
                    activity,
                    activityTitle: activityTitle,
                  ),
          child: const Text('Join activity'),
        ),
      );
    }

    if (activityIsHost(activity, uid)) {
      return _BarShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ActivityCheckInButton(activity: activity),
            if (activityCanCheckIn(activity, uid) ||
                activity.hasCheckedIn(uid)) ...[
              const SizedBox(height: 10),
            ],
            GradientCtaButton(
              onPressed: busy
                  ? null
                  : () => openActivityChat(
                        context,
                        activityId: activity.id,
                        activityTitle: title,
                      ),
              child: const Text('Open chat'),
            ),
          ],
        ),
      );
    }

    if (activityIsFull(activity)) {
      return _BarShell(
        child: Text(
          'This activity is full.',
          style: textTheme.bodyMedium?.copyWith(color: p.textMuted),
          textAlign: TextAlign.center,
        ),
      );
    }

    return _BarShell(
      child: Text(
        'This activity is no longer open to join.',
        style: textTheme.bodyMedium?.copyWith(color: p.textMuted),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _BarShell extends StatelessWidget {
  const _BarShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.card,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: child,
        ),
      ),
    );
  }
}
