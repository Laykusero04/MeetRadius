import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../data/send_activity_message.dart';
import '../data/watch_activity_messages.dart';
import '../domain/chat_message.dart';
import 'activity_group_info_screen.dart';
import 'chat_time_labels.dart';

/// Group chat for one activity (`activities/{id}/messages`).
class ActivityChatThreadScreen extends StatefulWidget {
  const ActivityChatThreadScreen({
    super.key,
    required this.activityId,
    required this.activityTitle,
  });

  final String activityId;
  final String activityTitle;

  @override
  State<ActivityChatThreadScreen> createState() => _ActivityChatThreadScreenState();
}

class _ActivityChatThreadScreenState extends State<ActivityChatThreadScreen> {
  final _textCtrl = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;
  /// Message the user is replying to (cleared after send).
  ChatMessage? _replyDraft;

  @override
  void dispose() {
    _textCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _textCtrl.text;
    if (text.trim().isEmpty || _sending) return;
    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await sendActivityMessage(
        activityId: widget.activityId,
        text: text,
        replyTo: _replyDraft == null
            ? null
            : ChatReplySnapshot.fromMessage(_replyDraft!),
      );
      if (!mounted) return;
      _textCtrl.clear();
      setState(() => _replyDraft = null);
      _scrollToEnd();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Could not send: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: context.palette.scaffold,
      appBar: AppBar(
        title: Text(
          widget.activityTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: context.palette.scaffold,
        foregroundColor: context.palette.textPrimary,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Group info',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => openActivityGroupInfo(
              context,
              activityId: widget.activityId,
              activityTitle: widget.activityTitle,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: watchActivityMessages(widget.activityId),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Could not load messages.\n${snap.error}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: context.palette.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final messages = snap.data ?? const <ChatMessage>[];
                if (snap.connectionState == ConnectionState.waiting &&
                    messages.isEmpty) {
                  return const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet.\nSay hi to the group.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: context.palette.textMuted,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                final now = DateTime.now();
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final m = messages[i];
                    if (m.isMemberLeftEvent) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              m.text,
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                color: context.palette.textMuted,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              messengerThreadTimestamp(m.createdAt),
                              textAlign: TextAlign.center,
                              style: textTheme.labelSmall?.copyWith(
                                color: context.palette.textMuted
                                    .withValues(alpha: 0.88),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.55,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final mine = uid != null && m.senderUid == uid;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Align(
                        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                        child: Dismissible(
                          key: ValueKey<String>('chat-msg-reply-${m.id}'),
                          direction: DismissDirection.startToEnd,
                          confirmDismiss: (_) async {
                            setState(() => _replyDraft = m);
                            return false;
                          },
                          background: const _SwipeReplyBackground(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.sizeOf(context).width * 0.82,
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: mine
                                    ? context.palette.joinLive
                                    : context.palette.card,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(mine ? 16 : 4),
                                  bottomRight: Radius.circular(mine ? 4 : 16),
                                ),
                                border: Border.all(
                                  color: mine
                                      ? context.palette.joinLive
                                          .withValues(alpha: 0.4)
                                      : context.palette.cardBorderSubtle,
                                ),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (m.hasReply)
                                      _ReplyQuoteInBubble(
                                        message: m,
                                        mine: mine,
                                      ),
                                    if (m.hasReply) const SizedBox(height: 8),
                                    if (!mine)
                                      Text(
                                        m.senderDisplayName,
                                        style: textTheme.labelMedium?.copyWith(
                                          color: context.palette.liveAccent,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    if (!mine) const SizedBox(height: 4),
                                    Text(
                                      m.text,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: mine
                                            ? context.palette.joinLiveForeground
                                            : context.palette.textPrimary,
                                        height: 1.35,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      shortRelativeChatTime(m.createdAt, now),
                                      style: textTheme.labelSmall?.copyWith(
                                        color: mine
                                            ? context.palette.joinLiveForeground
                                                .withValues(alpha: 0.75)
                                            : context.palette.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Material(
            color: context.palette.card,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_replyDraft != null)
                      _ReplyComposerStrip(
                        draft: _replyDraft!,
                        onCancel: () => setState(() => _replyDraft = null),
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textCtrl,
                            minLines: 1,
                            maxLines: 5,
                            textCapitalization: TextCapitalization.sentences,
                            style: textTheme.bodyLarge?.copyWith(
                              color: context.palette.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: _replyDraft != null
                                  ? 'Reply…'
                                  : 'Message the group…',
                              hintStyle:
                                  TextStyle(color: context.palette.textMuted),
                              filled: true,
                              fillColor: context.palette.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  color: context.palette.chipBorder,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  color: context.palette.chipBorder,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  color: context.palette.liveAccent,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _sending ? null : _send,
                          style: IconButton.styleFrom(
                            backgroundColor: context.palette.joinLive,
                            foregroundColor:
                                context.palette.joinLiveForeground,
                          ),
                          icon: _sending
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: context
                                        .palette.joinLiveForeground,
                                  ),
                                )
                              : const Icon(Icons.send_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeReplyBackground extends StatelessWidget {
  const _SwipeReplyBackground();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: ColoredBox(
        color: p.surface,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.reply_rounded,
                  color: p.liveAccent,
                  size: 26,
                ),
                const SizedBox(width: 8),
                Text(
                  'Reply',
                  style: textTheme.labelLarge?.copyWith(
                    color: p.liveAccent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReplyQuoteInBubble extends StatelessWidget {
  const _ReplyQuoteInBubble({
    required this.message,
    required this.mine,
  });

  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final accent = mine
        ? p.joinLiveForeground.withValues(alpha: 0.65)
        : p.liveAccent;
    final subtle = mine
        ? p.joinLiveForeground.withValues(alpha: 0.85)
        : p.textSecondary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: mine
            ? Colors.white.withValues(alpha: 0.08)
            : p.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: accent, width: 3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.replyToSenderDisplayName ?? 'Member',
              style: textTheme.labelMedium?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              message.replyToText ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: subtle,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReplyComposerStrip extends StatelessWidget {
  const _ReplyComposerStrip({
    required this.draft,
    required this.onCancel,
  });

  final ChatMessage draft;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    var snippet = draft.text.trim();
    if (snippet.length > 72) {
      snippet = '${snippet.substring(0, 72)}…';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: p.liveAccent.withValues(alpha: 0.45)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          child: Row(
            children: [
              Icon(Icons.reply_rounded, size: 22, color: p.liveAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Replying to ${draft.senderDisplayName}',
                      style: textTheme.labelMedium?.copyWith(
                        color: p.liveAccent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      snippet.isEmpty ? 'Message' : snippet,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: p.textSecondary,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Cancel reply',
                icon: Icon(Icons.close, color: p.textMuted),
                onPressed: onCancel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
