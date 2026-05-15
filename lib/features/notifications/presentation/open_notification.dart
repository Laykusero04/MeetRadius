import 'package:flutter/material.dart';

import '../../activity/presentation/activity_actions.dart';
import '../../activity/presentation/feed_activity_detail_screen.dart';
import '../domain/app_notification.dart';

/// Deep link from the notifications inbox.
Future<void> openAppNotification(
  BuildContext context,
  AppNotification notification,
) async {
  if (notification.activityId.isEmpty) return;

  if (notification.openChat) {
    openActivityChat(
      context,
      activityId: notification.activityId,
      activityTitle: notification.activityTitle,
    );
    return;
  }

  openFeedActivityDetail(
    context,
    activityId: notification.activityId,
    activityTitle: notification.activityTitle,
  );
}
