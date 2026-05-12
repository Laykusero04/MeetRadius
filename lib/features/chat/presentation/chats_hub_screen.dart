import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../activity/domain/activity.dart';
import '../../feed/presentation/widgets/activity_feed_labels.dart';
import 'activity_chat_thread_screen.dart';
import 'chat_time_labels.dart';

/// Activity-scoped chats: threads from Firestore for activities you host or joined.
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
        return _ChatsContent(uid: user.uid);
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

class _ChatsContent extends StatefulWidget {
  const _ChatsContent({required this.uid});

  final String uid;

  @override
  State<_ChatsContent> createState() => _ChatsContentState();
}

class _ChatsContentState extends State<_ChatsContent> {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _participantSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _hostSub;
  QuerySnapshot<Map<String, dynamic>>? _participantSnap;
  QuerySnapshot<Map<String, dynamic>>? _hostSnap;
  Activity? _openActivity;

  @override
  void initState() {
    super.initState();
    _attachStreams(widget.uid);
  }

  @override
  void didUpdateWidget(covariant _ChatsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid) {
      _attachStreams(widget.uid);
    }
  }

  void _attachStreams(String uid) {
    _participantSub?.cancel();
    _hostSub?.cancel();
    _participantSub = FirebaseFirestore.instance
        .collection('activities')
        .where('participantIds', arrayContains: uid)
        .snapshots()
        .listen((s) {
      if (mounted) setState(() => _participantSnap = s);
    });
    _hostSub = FirebaseFirestore.instance
        .collection('activities')
        .where('hostUid', isEqualTo: uid)
        .snapshots()
        .listen((s) {
      if (mounted) setState(() => _hostSnap = s);
    });
  }

  @override
  void dispose() {
    _participantSub?.cancel();
    _hostSub?.cancel();
    super.dispose();
  }

  List<Activity> _mergedActivities() {
    final map = <String, Activity>{};
    for (final d in _participantSnap?.docs ?? const <QueryDocumentSnapshot<Map<String, dynamic>>>[]) {
      map[d.id] = Activity.fromDoc(d);
    }
    for (final d in _hostSnap?.docs ?? const <QueryDocumentSnapshot<Map<String, dynamic>>>[]) {
      map[d.id] = Activity.fromDoc(d);
    }
    final list = map.values.toList();
    list.sort((a, b) {
      final ta = a.lastMessageAt ?? a.startsAt;
      final tb = b.lastMessageAt ?? b.startsAt;
      return tb.compareTo(ta);
    });
    return list;
  }

  String _metaLine(Activity a) {
    if (a.isLive) return 'Live · ${a.joinedCount} going';
    return '${activitySchedulePill(a.startsAt)} · ${a.joinedCount} going';
  }

  @override
  Widget build(BuildContext context) {
    if (_openActivity != null) {
      return ActivityChatThreadScreen(
        activity: _openActivity!,
        onBack: () => setState(() => _openActivity = null),
      );
    }

    final threads = _mergedActivities();
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            'Chats',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            'Activities you host or join. Coordinate time and place here.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: threads.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No chats yet.\nHost an activity or join one from the Feed tab.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: threads.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final a = threads[i];
                    final preview = a.lastMessagePreview ?? 'No messages yet';
                    final timeLabel = a.lastMessageAt != null
                        ? shortRelativeChatTime(a.lastMessageAt!, now)
                        : '';

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => _openActivity = a),
                        borderRadius: BorderRadius.circular(16),
                        child: Ink(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.forum_outlined,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          a.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _metaLine(a),
                                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                color: AppColors.liveAccent,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (timeLabel.isNotEmpty)
                                    Text(
                                      timeLabel,
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                            color: AppColors.textMuted,
                                          ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                preview,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
