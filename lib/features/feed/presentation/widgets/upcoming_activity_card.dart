import 'package:flutter/material.dart';

import '../../../../core/theme/meet_radius_palette.dart';
import 'messenger_style_leave_row.dart';

class UpcomingActivityCard extends StatelessWidget {
  const UpcomingActivityCard({
    super.key,
    required this.schedulePill,
    required this.title,
    required this.distance,
    required this.goingLabel,
    required this.friendsLine,
    this.category,
    this.onJoin,
    this.joinButtonLabel = 'Join',
    this.joinEnabled = true,
    this.isOwnActivity = false,
    this.isLeaveAction = false,
    this.onManageOwn,
    this.onTapActivity,
  });

  final String schedulePill;
  final String title;
  final String distance;
  final String goingLabel;
  final String friendsLine;
  final String? category;
  final VoidCallback? onJoin;
  final String joinButtonLabel;
  final bool joinEnabled;
  final bool isOwnActivity;
  /// Member (not host) is going — primary action is leave.
  final bool isLeaveAction;
  /// Host-only: opens edit/delete (e.g. feed sheet).
  final VoidCallback? onManageOwn;
  final VoidCallback? onTapActivity;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final headerAndBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.palette.upcomingBlue.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: context.palette.upcomingBlue.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  schedulePill,
                  style: textTheme.labelSmall?.copyWith(
                    color: context.palette.upcomingBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (category != null && category!.isNotEmpty) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.palette.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.palette.chipBorder),
                ),
                child: Text(
                  category!,
                  style: textTheme.labelSmall?.copyWith(
                    color: context.palette.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
            if (isOwnActivity && onManageOwn != null) ...[
              const SizedBox(width: 4),
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
            ],
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
        Row(
          children: [
            Icon(Icons.place_outlined, size: 15, color: context.palette.textMuted),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                distance,
                style: textTheme.bodySmall?.copyWith(
                  color: context.palette.textSecondary,
                  fontSize: 12,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.people_outline, size: 15, color: context.palette.textMuted),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                goingLabel,
                style: textTheme.bodySmall?.copyWith(
                  color: context.palette.textSecondary,
                  fontSize: 12,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (friendsLine.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            friendsLine,
            style: textTheme.bodySmall?.copyWith(
              color: context.palette.textMuted,
              fontSize: 11,
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: context.palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.palette.cardBorderSubtle),
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
          SizedBox(
            width: double.infinity,
            child: isOwnActivity && onManageOwn != null
                ? OutlinedButton(
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
                : isLeaveAction && onJoin != null
                    ? MessengerStyleLeaveRow(
                        onLeave: joinEnabled ? onJoin : null,
                        enabled: joinEnabled,
                      )
                    : OutlinedButton(
                        onPressed: joinEnabled ? onJoin : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              context.palette.joinUpcomingForeground,
                          side: BorderSide(color: context.palette.chipBorder),
                          backgroundColor: context.palette.joinUpcoming,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
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
