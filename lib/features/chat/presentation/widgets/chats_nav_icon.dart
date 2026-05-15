import 'package:flutter/material.dart';

import '../../../../core/theme/meet_radius_palette.dart';
import '../../../safety/data/block_user.dart';
import '../../data/watch_unread_chat_count.dart';

/// Bottom-nav Chats icon with an unread thread badge.
class ChatsNavIcon extends StatelessWidget {
  const ChatsNavIcon({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: watchBlockedUserIds(),
      builder: (context, blockedSnap) {
        final blocked = blockedSnap.data ?? const <String>[];
        return StreamBuilder<int>(
          stream: watchUnreadChatCount(blockedHostIds: blocked),
          builder: (context, unreadSnap) {
            final unread = unreadSnap.data ?? 0;
            final icon = Icon(
              active ? Icons.chat_bubble : Icons.chat_bubble_outline,
            );
            if (unread <= 0) return icon;
            return Badge(
              label: Text(unread > 99 ? '99+' : '$unread'),
              backgroundColor: context.palette.liveAccent,
              child: icon,
            );
          },
        );
      },
    );
  }
}
