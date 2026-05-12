import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../activity/domain/activity.dart';
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
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sign in to see group chats for activities you host or join.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            'Chats',
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'One thread per activity you’re in. Messages sync with Firestore.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Activity>>(
            stream: watchMyChatThreads(),
            builder: (context, snap) {
              if (snap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Could not load chats.\n${snap.error}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
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
              final threads = snap.data ?? const <Activity>[];
              if (threads.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No chats yet.\nHost or join an activity — each has a group thread.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
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
                  final preview = (a.lastMessagePreview?.trim().isNotEmpty == true)
                      ? a.lastMessagePreview!.trim()
                      : 'Tap to open chat · ${a.spot}';
                  final time = a.lastMessageAt != null
                      ? shortRelativeChatTime(a.lastMessageAt!, now)
                      : '';
                  return Material(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
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
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.chipBorder),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                a.isLive ? Icons.bolt : Icons.chat_bubble_outline,
                                color: a.isLive
                                    ? AppColors.liveAccent
                                    : AppColors.textMuted,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.titleSmall?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    preview,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
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
                                  color: AppColors.textMuted,
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
          ),
        ),
      ],
    );
  }
}
