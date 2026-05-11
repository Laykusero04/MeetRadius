import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Activity-scoped chats (MVP): list of joined threads + static thread UI.
class ChatsHubScreen extends StatefulWidget {
  const ChatsHubScreen({super.key});

  @override
  State<ChatsHubScreen> createState() => _ChatsHubScreenState();
}

class _ChatsHubScreenState extends State<ChatsHubScreen> {
  static const _threads = [
    _ThreadSummary(
      title: 'Pickup basketball — City Gym',
      meta: 'Live · 4 going',
      preview: 'Alex: I’m parking now, 3 min',
      timeLabel: '2m',
    ),
    _ThreadSummary(
      title: 'Coffee meetup — NCCC Mall',
      meta: 'Starts in 18 min',
      preview: 'Jordan: Meet at the south entrance?',
      timeLabel: '12m',
    ),
    _ThreadSummary(
      title: 'Hiking — Mt. Apo trailhead',
      meta: 'Saturday · 7am',
      preview: 'You: Sounds good — see you there',
      timeLabel: 'Yesterday',
    ),
  ];

  int? _openIndex;

  @override
  Widget build(BuildContext context) {
    if (_openIndex != null) {
      return _ActivityChatThread(
        summary: _threads[_openIndex!],
        onBack: () => setState(() => _openIndex = null),
      );
    }

    return _ChatsList(
      threads: _threads,
      onOpen: (i) => setState(() => _openIndex = i),
    );
  }
}

class _ThreadSummary {
  const _ThreadSummary({
    required this.title,
    required this.meta,
    required this.preview,
    required this.timeLabel,
  });

  final String title;
  final String meta;
  final String preview;
  final String timeLabel;
}

class _ChatsList extends StatelessWidget {
  const _ChatsList({
    required this.threads,
    required this.onOpen,
  });

  final List<_ThreadSummary> threads;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            'Only activities you’ve joined. Keep it practical — time, place, running late.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: threads.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final t = threads[i];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onOpen(i),
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
                                    t.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.titleSmall?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    t.meta,
                                    style: textTheme.labelMedium?.copyWith(
                                      color: AppColors.liveAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              t.timeLabel,
                              style: textTheme.labelMedium?.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          t.preview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
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

class _ActivityChatThread extends StatefulWidget {
  const _ActivityChatThread({
    required this.summary,
    required this.onBack,
  });

  final _ThreadSummary summary;
  final VoidCallback onBack;

  @override
  State<_ActivityChatThread> createState() => _ActivityChatThreadState();
}

class _ActivityChatThreadState extends State<_ActivityChatThread> {
  final _input = TextEditingController();

  static const _messages = [
    _ChatLine(text: 'Who’s already at the court?', incoming: true, sender: 'Alex'),
    _ChatLine(text: 'I’m walking over — 5 min out', incoming: true, sender: 'Jordan'),
    _ChatLine(text: 'Grabbing water — save me a spot', incoming: false, sender: null),
    _ChatLine(text: 'Cool, we’re on court 2', incoming: true, sender: 'Alex'),
  ];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                      widget.summary.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      widget.summary.meta,
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
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            itemCount: _messages.length,
            itemBuilder: (context, i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MessageBubble(line: _messages[i]),
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
                  onPressed: () {
                    if (_input.text.trim().isEmpty) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Static chat — wire Firestore next.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    _input.clear();
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.joinLive,
                    foregroundColor: AppColors.joinLiveForeground,
                  ),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatLine {
  const _ChatLine({
    required this.text,
    required this.incoming,
    this.sender,
  });

  final String text;
  final bool incoming;
  final String? sender;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.line});

  final _ChatLine line;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final align = line.incoming ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    final bg = line.incoming ? AppColors.card : AppColors.avatarPurple.withValues(alpha: 0.35);
    final border = line.incoming
        ? Border.all(color: AppColors.cardBorderSubtle)
        : Border.all(color: AppColors.avatarPurple.withValues(alpha: 0.45));

    return Column(
      crossAxisAlignment: align,
      children: [
        if (line.incoming && line.sender != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              line.sender!,
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
            borderRadius: line.incoming
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
            line.text,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
