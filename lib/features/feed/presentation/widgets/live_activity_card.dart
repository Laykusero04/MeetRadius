import 'package:flutter/material.dart';

import '../../../../core/theme/meet_radius_palette.dart';
import '../../../../shared/widgets/brand_gradient.dart';
import 'messenger_style_leave_row.dart';

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
    this.isOwnActivity = false,
    this.isLeaveAction = false,
    this.onManageOwn,
    this.onTapActivity,
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
  final bool isOwnActivity;
  final bool isLeaveAction;
  final VoidCallback? onManageOwn;

  /// Opens full activity details (host, members, schedule).
  final VoidCallback? onTapActivity;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final headerAndBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _LiveBadge(textTheme: textTheme),
            if (category != null && category!.isNotEmpty) ...[
              const SizedBox(width: 6),
              _CategoryPill(label: category!, textTheme: textTheme),
            ],
            const Spacer(),
            if (isOwnActivity && onManageOwn != null) ...[
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                tooltip: 'Edit or delete',
                icon: Icon(
                  Icons.more_vert,
                  color: context.palette.textMuted,
                  size: 22,
                ),
                onPressed: onManageOwn,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              startsIn,
              style: textTheme.labelMedium?.copyWith(
                color: context.palette.liveAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: textTheme.titleSmall?.copyWith(
            color: context.palette.textPrimary,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 6),
        _MetaRow(icon: Icons.place_outlined, label: distance),
        const SizedBox(height: 4),
        _MetaRow(icon: Icons.people_outline, label: joinedLabel),
        if (friendInitials.isNotEmpty && friendNamesLine != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              ...friendInitials.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: _MiniAvatar(letter: c),
                ),
              ),
              Expanded(
                child: Text(
                  friendNamesLine!,
                  style: textTheme.bodySmall?.copyWith(
                    color: context.palette.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ] else if (socialLine.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            socialLine,
            style: textTheme.bodySmall?.copyWith(
              color: context.palette.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: context.palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.palette.liveBorder, width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          onTapActivity == null
              ? headerAndBody
              : Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTapActivity,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: headerAndBody,
                    ),
                  ),
                ),
          const SizedBox(height: 10),
          if (isOwnActivity && onManageOwn != null)
            OutlinedButton(
              onPressed: onManageOwn,
              style: OutlinedButton.styleFrom(
                foregroundColor: context.palette.textPrimary,
                side: BorderSide(color: context.palette.chipBorder),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Manage activity'),
            )
          else if (isOwnActivity)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: BrandGradient.horizontal(context.palette),
                border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
              ),
              child: Text(
                joinButtonLabel,
                style: textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else if (isLeaveAction && onJoin != null)
            MessengerStyleLeaveRow(
              onLeave: joinEnabled ? onJoin : null,
              enabled: joinEnabled,
            )
          else
            GradientCtaButton(
              onPressed: joinEnabled ? onJoin : null,
              borderRadius: 12,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                joinButtonLabel,
                style: textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.palette.chipBorder),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: context.palette.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 11,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: context.palette.liveDot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'Live',
            style: textTheme.labelSmall?.copyWith(
              color: context.palette.textPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
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
        Icon(icon, size: 15, color: context.palette.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.palette.textSecondary,
              fontSize: 12,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
    final color = letter == 'A'
        ? context.palette.avatarPurple
        : context.palette.avatarGreen;
    return GradientAvatar(
      outerRadius: 12,
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
