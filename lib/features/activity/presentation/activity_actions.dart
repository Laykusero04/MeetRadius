import 'package:flutter/material.dart';

import '../data/join_activity.dart';
import '../data/leave_activity.dart';
import '../domain/activity.dart';
import '../domain/activity_membership.dart';
import 'feed_activity_detail_screen.dart';
import '../../chat/presentation/activity_chat_thread_screen.dart';

/// Opens the group chat for an activity the user has joined.
void openActivityChat(
  BuildContext context, {
  required String activityId,
  required String activityTitle,
}) {
  Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => ActivityChatThreadScreen(
        activityId: activityId,
        activityTitle: activityTitle,
      ),
    ),
  );
}

/// Routes by membership: members → chat; others → activity detail.
void openActivityHub(
  BuildContext context, {
  required Activity activity,
  String? activityTitle,
  bool openChatIfMember = true,
}) {
  final title = activityDisplayTitle(
    activity,
    activityTitle ?? 'Activity',
  );
  if (openChatIfMember && activityCanOpenChat(activity)) {
    openActivityChat(
      context,
      activityId: activity.id,
      activityTitle: title,
    );
    return;
  }
  openFeedActivityDetail(
    context,
    activityId: activity.id,
    activityTitle: title,
  );
}

/// Join, leave, or open chat; shows SnackBars on success.
Future<void> performActivityMembershipAction(
  BuildContext context,
  Activity activity, {
  String? activityTitle,
  bool openChatAfterJoin = true,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final uid = currentActivityUserUid;
  if (uid == null) {
    messenger?.showSnackBar(
      const SnackBar(content: Text('Sign in to join activities.')),
    );
    return;
  }

  final title = activityDisplayTitle(activity, activityTitle ?? 'Activity');

  if (activityCanLeave(activity, uid)) {
    try {
      await leaveActivity(activity.id);
      if (!context.mounted) return;
      messenger?.showSnackBar(
        const SnackBar(content: Text('You left this activity.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger?.showSnackBar(SnackBar(content: Text('$e')));
    }
    return;
  }

  if (activityCanOpenChat(activity, uid)) {
    openActivityChat(
      context,
      activityId: activity.id,
      activityTitle: title,
    );
    return;
  }

  if (!activityCanJoin(activity, uid)) return;

  try {
    await joinActivity(activity.id);
    if (!context.mounted) return;
    messenger?.showSnackBar(
      SnackBar(
        content: const Text("You're in!"),
        behavior: SnackBarBehavior.floating,
        action: openChatAfterJoin
            ? SnackBarAction(
                label: 'Open chat',
                onPressed: () {
                  openActivityChat(
                    context,
                    activityId: activity.id,
                    activityTitle: title,
                  );
                },
              )
            : null,
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    messenger?.showSnackBar(SnackBar(content: Text('$e')));
  }
}
