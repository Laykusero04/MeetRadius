import 'package:flutter/material.dart';

import '../../../../core/theme/meet_radius_palette.dart';
import '../../data/check_in_activity.dart';
import '../../domain/activity.dart';
import '../../domain/activity_check_in.dart';
import '../../domain/activity_membership.dart';

/// Check-in CTA for activity detail (GPS geofence).
class ActivityCheckInButton extends StatefulWidget {
  const ActivityCheckInButton({
    super.key,
    required this.activity,
  });

  final Activity activity;

  @override
  State<ActivityCheckInButton> createState() => _ActivityCheckInButtonState();
}

class _ActivityCheckInButtonState extends State<ActivityCheckInButton> {
  bool _busy = false;

  Future<void> _checkIn() async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await checkInToActivity(widget.activity);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Checked in!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('$e'), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final uid = currentActivityUserUid;
    if (uid == null) return const SizedBox.shrink();

    if (widget.activity.hasCheckedIn(uid)) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: p.liveAccent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: p.liveAccent.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: p.liveAccent, size: 22),
            const SizedBox(width: 8),
            Text(
              'You checked in',
              style: textTheme.labelLarge?.copyWith(
                color: p.liveAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    if (!activityCanCheckIn(widget.activity, uid)) {
      return const SizedBox.shrink();
    }

    return OutlinedButton.icon(
      onPressed: _busy ? null : _checkIn,
      icon: _busy
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: p.upcomingBlue,
              ),
            )
          : Icon(Icons.location_on_outlined, color: p.upcomingBlue),
      label: Text(
        _busy ? 'Checking location…' : 'Check in at meeting spot',
        style: textTheme.labelLarge?.copyWith(
          color: p.upcomingBlue,
          fontWeight: FontWeight.w700,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: p.upcomingBlue.withValues(alpha: 0.5)),
      ),
    );
  }
}
