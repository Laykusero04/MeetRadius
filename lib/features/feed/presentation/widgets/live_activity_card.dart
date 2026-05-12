import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class LiveActivityCard extends StatelessWidget {
  const LiveActivityCard({
    super.key,
    required this.title,
    required this.startsIn,
    required this.distance,
    required this.joinedLabel,
    required this.socialLine,
    this.category,
    this.friendInitials = const [],
    this.friendNamesLine,
    this.onJoin,
    this.joinButtonLabel = 'Join now',
    this.joinEnabled = true,
  });

  final String title;
  final String startsIn;
  final String distance;
  final String joinedLabel;
  final String socialLine;
  /// e.g. Sports, Coffee — shown as a small pill when set.
  final String? category;
  final List<String> friendInitials;
  final String? friendNamesLine;
  final VoidCallback? onJoin;
  final String joinButtonLabel;
  final bool joinEnabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.liveBorder, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _LiveBadge(textTheme: textTheme),
              if (category != null && category!.isNotEmpty) ...[
                const SizedBox(width: 8),
                _CategoryPill(label: category!, textTheme: textTheme),
              ],
              const Spacer(),
              Text(
                startsIn,
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.liveAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _MetaRow(icon: Icons.place_outlined, label: distance),
          const SizedBox(height: 6),
          _MetaRow(icon: Icons.people_outline, label: joinedLabel),
          const SizedBox(height: 12),
          if (friendInitials.isNotEmpty && friendNamesLine != null) ...[
            Row(
              children: [
                ...friendInitials.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _MiniAvatar(letter: c),
                  ),
                ),
                Expanded(
                  child: Text(
                    friendNamesLine!,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ] else
            Text(
              socialLine,
              style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: joinEnabled ? onJoin : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.joinLive,
                foregroundColor: AppColors.joinLiveForeground,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(joinButtonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.label, required this.textTheme});

  final String label;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.chipBorder),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.liveDot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Live',
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    final color = letter == 'A' ? AppColors.avatarPurple : AppColors.avatarGreen;
    return CircleAvatar(
      radius: 14,
      backgroundColor: color,
      child: Text(
        letter,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
