import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'live_activity_card.dart';
import 'upcoming_activity_card.dart';

const _kCategoryChips = ['All', 'Sports', 'Social', 'Outdoor'];

/// Static feed list + filters (used inside shell [IndexedStack]).
class FeedBody extends StatefulWidget {
  const FeedBody({super.key});

  @override
  State<FeedBody> createState() => _FeedBodyState();
}

class _FeedBodyState extends State<FeedBody> {
  int _chipIndex = 0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _FeedLocationHeader(textTheme: textTheme)),
        SliverToBoxAdapter(
          child: _CategoryChips(
            selectedIndex: _chipIndex,
            onSelect: (i) => setState(() => _chipIndex = i),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text('🔥 ', style: textTheme.labelLarge),
                Text(
                  'LIVE NOW',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate(const [
              LiveActivityCard(
                title: 'Need 2 basketball players',
                startsIn: 'Starts in 12 min',
                distance: '0.4 mi away',
                joinedLabel: '4 of 6 joined',
                socialLine: '',
                friendInitials: ['A', 'J'],
                friendNamesLine: 'Alex + Jordan going',
              ),
              SizedBox(height: 12),
              LiveActivityCard(
                title: 'Coffee meetup — NCCC Mall',
                startsIn: 'Starts in 20 min',
                distance: '1.1 mi away',
                joinedLabel: '3 going',
                socialLine: 'No friends going yet',
                friendInitials: [],
                friendNamesLine: null,
              ),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'UPCOMING',
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const UpcomingActivityCard(
                schedulePill: 'Saturday · 7am',
                title: 'Hiking — Mt. Apo trailhead',
                distance: '8.2 mi away',
                goingLabel: '11 going',
                friendsLine: '2 friends going',
              ),
              const SizedBox(height: 80),
            ]),
          ),
        ),
      ],
    );
  }
}

class _FeedLocationHeader extends StatelessWidget {
  const _FeedLocationHeader({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: AppColors.textPrimary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Davao City · 15 mi',
              style: textTheme.titleSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.avatarPurple,
            child: Text(
              'M',
              style: textTheme.titleMedium?.copyWith(
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

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _kCategoryChips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          final label = _kCategoryChips[index];
          return GestureDetector(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppColors.chipSelectedBorder
                      : AppColors.chipBorder,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
