import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../activity/domain/activity.dart';
import '../data/send_activity_message.dart';

/// Group chat for one activity (`activities/{id}/messages`).
class ActivityChatThreadScreen extends StatefulWidget {
  const ActivityChatThreadScreen({
    super.key,
    required this.activity,
    required this.onBack,
  });

  final Activity activity;
  final VoidCallback onBack;

  @override
  State<ActivityChatThreadScreen> createState() => _ActivityChatThreadScreenState();
}

class _ActivityChatThreadScreenState extends State<ActivityChatThreadScreen> {
  final _input = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  String _metaLine() {
    final a = widget.activity;
    if (a.isLive) return 'Live · ${a.joinedCount} going';
    return '${_weekdayTime(a.startsAt)} · ${a.joinedCount} going';
  }

  static String _weekdayTime(DateTime d) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final wd = weekdays[d.weekday - 1];
    final h24 = d.hour;
    final hour = h24 == 0 ? 12 : (h24 > 12 ? h24 - 12 : h24);
    final min = d.minute.toString().padLeft(2, '0');
    final ampm = h24 >= 12 ? 'pm' : 'am';
    return '$wd · $hour:$min $ampm';
  }

  Future<void> _send() async {
    final raw = _input.text;
    if (raw.trim().isEmpty || _sending) return;
    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      await sendActivityMessage(activityId: widget.activity.id, text: raw);
      if (!mounted) return;
      _input.clear();
    } catch (e) {
      if (!mounted) return;
      messenger?.showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final messagesQuery = FirebaseFirestore.instance
        .collection('activities')
        .doc(widget.activity.id)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .limit(100);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: AppColors.textPrimary,
                tooltip: 'Back',
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.activity.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _metaLine(),
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: messagesQuery.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Could not load messages.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.liveAccent),
                );
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return Center(
                  child: Text(
                    'No messages yet.\nSay hi to the group.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final doc = docs[i];
                  final d = doc.data();
                  final text = d['text'] as String? ?? '';
                  final senderUid = d['senderUid'] as String? ?? '';
                  final senderLabel = d['senderLabel'] as String? ?? 'Member';
                  final mine = uid != null && senderUid == uid;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MessageBubble(
                      text: text,
                      incoming: !mine,
                      sender: mine ? null : senderLabel,
                    ),
                  );
                },
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Message the group…',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: const BorderSide(color: AppColors.chipBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: const BorderSide(color: AppColors.chipBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: const BorderSide(
                          color: AppColors.liveAccent,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sending ? null : _send,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.joinLive,
                    foregroundColor: AppColors.joinLiveForeground,
                  ),
                  icon: _sending
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.joinLiveForeground,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.text,
    required this.incoming,
    this.sender,
  });

  final String text;
  final bool incoming;
  final String? sender;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final align = incoming ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    final bg = incoming ? AppColors.card : AppColors.avatarPurple.withValues(alpha: 0.35);
    final border = incoming
        ? Border.all(color: AppColors.cardBorderSubtle)
        : Border.all(color: AppColors.avatarPurple.withValues(alpha: 0.45));

    return Column(
      crossAxisAlignment: align,
      children: [
        if (incoming && sender != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              sender!,
              style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
            ),
          ),
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: incoming
                ? const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                    bottomLeft: Radius.circular(16),
                  ),
            border: border,
          ),
          child: Text(
            text,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
