import 'package:flutter/material.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../../notifications/data/watch_notifications.dart';
import '../../notifications/domain/app_notification.dart';
import '../../notifications/presentation/open_notification.dart';

/// In-app inbox (`users/{uid}/notifications`).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: p.scaffold,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: p.scaffold,
        foregroundColor: p.textPrimary,
        surfaceTintColor: Colors.transparent,
        actions: const [
          _ReadAllButton(),
        ],
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: watchNotifications(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Text(
                'Could not load notifications.',
                style: textTheme.bodyMedium?.copyWith(color: p.textSecondary),
              ),
            );
          }
          final list = snap.data;
          if (list == null) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_outlined,
                      size: 56,
                      color: p.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: textTheme.titleMedium?.copyWith(
                        color: p.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Joins, messages, and activity updates will show here.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: p.textSecondary,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: list.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: p.cardBorderSubtle),
            itemBuilder: (context, i) {
              final n = list[i];
              return _NotificationTile(notification: n);
            },
          );
        },
      ),
    );
  }
}

class _ReadAllButton extends StatefulWidget {
  const _ReadAllButton();

  @override
  State<_ReadAllButton> createState() => _ReadAllButtonState();
}

class _ReadAllButtonState extends State<_ReadAllButton> {
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return StreamBuilder<int>(
      stream: watchUnreadNotificationCount(),
      builder: (context, snap) {
        final unread = snap.data ?? 0;
        if (unread == 0) return const SizedBox.shrink();

        return TextButton(
          onPressed: _busy
              ? null
              : () async {
                  setState(() => _busy = true);
                  try {
                    await markAllNotificationsRead();
                  } catch (_) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Could not mark all as read.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } finally {
                    if (mounted) setState(() => _busy = false);
                  }
                },
          child: _busy
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: p.liveAccent,
                  ),
                )
              : Text(
                  'Read all',
                  style: TextStyle(
                    color: p.liveAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  IconData _iconForType(String type) {
    return switch (type) {
      'join' => Icons.person_add_outlined,
      'chat' => Icons.chat_bubble_outline,
      'check_in' => Icons.location_on_outlined,
      'activity_ended' => Icons.stop_circle_outlined,
      _ => Icons.notifications_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final n = notification;

    return Material(
      color: n.read ? p.scaffold : p.card,
      child: InkWell(
        onTap: () async {
          await markNotificationRead(n.id);
          if (!context.mounted) return;
          await openAppNotification(context, n);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: p.chipBorder),
                ),
                child: Icon(_iconForType(n.type), color: p.liveAccent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.activityTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: p.textPrimary,
                        fontWeight: n.read ? FontWeight.w600 : FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: p.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (!n.read)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6, left: 8),
                  decoration: BoxDecoration(
                    color: p.liveAccent,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
