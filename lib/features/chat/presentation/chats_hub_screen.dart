import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../../activity/domain/activity.dart';
import '../../safety/data/block_user.dart';
import '../../safety/data/filter_blocked_activities.dart';
import '../data/mark_chat_thread_read.dart';
import '../data/user_chat_prefs.dart';
import '../data/watch_my_chat_threads.dart';
import 'activity_chat_thread_screen.dart';
import 'chat_time_labels.dart';

/// Lists activity group threads the signed-in user belongs to (Firestore `memberIds`).
class ChatsHubScreen extends StatelessWidget {
  const ChatsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        final user = authSnap.data;
        if (user == null) {
          return const _SignedOutChats();
        }
        return const _ChatsThreadList();
      },
    );
  }
}

class _SignedOutChats extends StatelessWidget {
  const _SignedOutChats();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chats',
            style: textTheme.headlineSmall?.copyWith(
              color: context.palette.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sign in to see group chats for activities you host or join.',
            style: textTheme.bodyMedium?.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatsThreadList extends StatelessWidget {
  const _ChatsThreadList();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: StreamBuilder<List<String>>(
            stream: watchBlockedUserIds(),
            builder: (context, blockedSnap) {
              final blocked = blockedSnap.data ?? const <String>[];
              return StreamBuilder<UserChatPrefs>(
                stream: watchUserChatPrefs(),
                builder: (context, prefsSnap) {
                  final prefs = prefsSnap.data ?? const UserChatPrefs();
                  return StreamBuilder<List<Activity>>(
                stream: watchMyChatThreads(),
                builder: (context, snap) {
              if (snap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Could not load chats.\n${snap.error}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: context.palette.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              if (snap.connectionState == ConnectionState.waiting &&
                  (snap.data == null || snap.data!.isEmpty)) {
                return const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              final threads = filterBlockedActivities(
                snap.data ?? const <Activity>[],
                blocked,
              );
              if (threads.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No chats yet.\nHost or join an activity — each has a group thread.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: context.palette.textMuted,
                        height: 1.45,
                      ),
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: threads.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final a = threads[i];
                  final preview =
                      (a.lastMessagePreview?.trim().isNotEmpty == true)
                      ? a.lastMessagePreview!.trim()
                      : 'Tap to open chat · ${a.spot}';
                  final time = a.lastMessageAt != null
                      ? shortRelativeChatTime(a.lastMessageAt!, now)
                      : '';
                  final unread = prefs.isThreadUnread(a.id, a.lastMessageAt);
                  final muted = prefs.isActivityMuted(a.id);
                  return Material(
                    color: context.palette.card,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        markChatThreadRead(a.id);
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ActivityChatThreadScreen(
                              activityId: a.id,
                              activityTitle: a.title,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: context.palette.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: context.palette.chipBorder,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                a.isLive
                                    ? Icons.bolt
                                    : Icons.chat_bubble_outline,
                                color: a.isLive
                                    ? context.palette.liveAccent
                                    : context.palette.textMuted,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          a.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: textTheme.titleSmall?.copyWith(
                                            color: context.palette.textPrimary,
                                            fontWeight: unread
                                                ? FontWeight.w800
                                                : FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      if (muted) ...[
                                        const SizedBox(width: 6),
                                        Icon(
                                          Icons.notifications_off_outlined,
                                          size: 16,
                                          color: context.palette.textMuted,
                                        ),
                                      ],
                                      if (unread) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: context.palette.liveAccent,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                      if (a.isEnded) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          'Ended',
                                          style: textTheme.labelSmall?.copyWith(
                                            color: context.palette.textMuted,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    preview,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: unread
                                          ? context.palette.textPrimary
                                          : context.palette.textSecondary,
                                      fontWeight: unread
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (time.isNotEmpty)
                              Text(
                                time,
                                style: textTheme.labelSmall?.copyWith(
                                  color: context.palette.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
                },
              );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
