import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorderSubtle),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.upcomingBlue.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.upcomingBlue.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    schedulePill,
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.upcomingBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (category != null && category!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.chipBorder),
                  ),
                  child: Text(
                    category!,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
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
          Row(
            children: [
              Icon(Icons.place_outlined, size: 18, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Text(
                distance,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.people_outline, size: 18, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Text(
                goingLabel,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            friendsLine,
            style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: joinEnabled ? onJoin : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.joinUpcomingForeground,
                side: const BorderSide(color: AppColors.chipBorder),
                backgroundColor: AppColors.joinUpcoming,
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
