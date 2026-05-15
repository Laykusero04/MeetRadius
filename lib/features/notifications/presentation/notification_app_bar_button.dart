import 'package:flutter/material.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../data/watch_notifications.dart';

/// App bar bell with a live unread count from Firestore.
class NotificationAppBarButton extends StatelessWidget {
  const NotificationAppBarButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return StreamBuilder<int>(
      stream: watchUnreadNotificationCount(),
      builder: (context, snap) {
        final unread = snap.data ?? 0;
        final icon = const Icon(Icons.notifications_outlined);

        return IconButton(
          tooltip: unread > 0
              ? '$unread unread notification${unread == 1 ? '' : 's'}'
              : 'Notifications',
          onPressed: onPressed,
          icon: unread > 0
              ? Badge(
                  label: Text(unread > 99 ? '99+' : '$unread'),
                  backgroundColor: p.liveAccent,
                  textColor: Colors.white,
                  child: icon,
                )
              : icon,
        );
      },
    );
  }
}
