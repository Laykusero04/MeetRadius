import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/meet_radius_palette.dart';
import '../../../activity/data/check_in_activity.dart';
import '../../../activity/domain/activity.dart';
import '../../../activity/domain/activity_check_in.dart';

/// Compact check-in CTA shown above the message list in a group chat.
class ChatCheckInBanner extends StatefulWidget {
  const ChatCheckInBanner({super.key, required this.activity});

  final Activity activity;

  @override
  State<ChatCheckInBanner> createState() => _ChatCheckInBannerState();
}

class _ChatCheckInBannerState extends State<ChatCheckInBanner> {
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
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final activity = widget.activity;

    if (uid != null && activity.hasCheckedIn(uid)) {
      return Material(
        color: p.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, size: 20, color: p.liveAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'You checked in at this meetup.',
                  style: textTheme.bodySmall?.copyWith(color: p.textSecondary),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!activityCanCheckIn(activity, uid)) {
      return const SizedBox.shrink();
    }

    return Material(
      color: p.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'At the meeting spot? Check in so the host knows you arrived.',
                style: textTheme.bodySmall?.copyWith(
                  color: p.textSecondary,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: _busy ? null : _checkIn,
              style: FilledButton.styleFrom(
                backgroundColor: p.joinLive,
                foregroundColor: p.joinLiveForeground,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: _busy
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: p.joinLiveForeground,
                      ),
                    )
                  : const Text('Check in'),
            ),
          ],
        ),
      ),
    );
  }
}
