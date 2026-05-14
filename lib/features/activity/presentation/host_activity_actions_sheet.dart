import 'package:flutter/material.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../../feed/presentation/widgets/activity_feed_labels.dart';
import '../data/delete_activity.dart';
import '../domain/activity.dart';
import '../domain/activity_capacity_labels.dart';
import 'edit_activity_screen.dart';

/// Bottom sheet: edit or delete an activity the current user hosts (feed / list).
Future<void> showHostActivityActionsSheet(
  BuildContext context,
  Activity activity,
) async {
  final p = context.palette;
  final textTheme = Theme.of(context).textTheme;
  final schedule = activitySchedulePill(activity.startsAt);

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: p.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetCtx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                activity.title.isEmpty ? activity.category : activity.title,
                style: textTheme.titleMedium?.copyWith(
                  color: p.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${activity.category} · '
                '${activity.spot.isEmpty ? 'Spot TBD' : activity.spot}',
                style: textTheme.bodyMedium?.copyWith(color: p.textSecondary),
              ),
              const SizedBox(height: 6),
              Text(
                schedule,
                style: textTheme.bodySmall?.copyWith(color: p.textMuted),
              ),
              const SizedBox(height: 6),
              Text(
                activityGoingLabel(activity),
                style: textTheme.labelMedium?.copyWith(color: p.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                activity.isLive ? 'Live' : 'Upcoming',
                style: textTheme.labelLarge?.copyWith(
                  color: activity.isLive ? p.liveAccent : p.upcomingBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(sheetCtx);
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                EditActivityScreen(activity: activity),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: p.textPrimary,
                        side: BorderSide(color: p.chipBorder),
                      ),
                      child: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (dialogCtx) {
                            return AlertDialog(
                              backgroundColor: p.card,
                              title: Text(
                                'Delete activity?',
                                style: TextStyle(
                                  color: p.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              content: Text(
                                'This removes it for everyone. You cannot undo this.',
                                style: TextStyle(
                                  color: p.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogCtx, false),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(color: p.textSecondary),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogCtx, true),
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: p.liveAccent,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                        if (ok != true) return;
                        try {
                          await deleteActivity(activity.id);
                          if (!context.mounted) return;
                          Navigator.pop(sheetCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Activity deleted.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$e'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: p.liveAccent,
                        side: BorderSide(
                          color: p.liveAccent.withValues(alpha: 0.45),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
