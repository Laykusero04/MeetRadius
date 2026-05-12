import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../activity/data/join_activity.dart';
import '../../../activity/data/watch_activities.dart';
import '../../../activity/domain/activity.dart';
import '../../application/feed_filter_cubit.dart';
import 'activity_feed_labels.dart';
import 'live_activity_card.dart';
import 'upcoming_activity_card.dart';

/// Feed UI backed by Firestore `activities` (see [watchActivities]).
class FeedBody extends StatelessWidget {
  const FeedBody({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<FeedFilterCubit, ({int chipIndex})>(
      builder: (context, filter) {
        return StreamBuilder<List<Activity>>(
          stream: watchActivities(),
          builder: (context, listSnap) {
            if (listSnap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Could not load activities.\n${listSnap.error}',
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final all = listSnap.data ?? const <Activity>[];
            final filtered = all.where((a) => a.matchesFeedChip(filter.chipIndex)).toList();
            final live = filtered.where((a) => a.isLive).toList();
            final upcoming = filtered.where((a) => !a.isLive).toList();
            final now = DateTime.now();
            final loading = listSnap.connectionState == ConnectionState.waiting && all.isEmpty;

            return RefreshIndicator(
              color: AppColors.liveAccent,
              onRefresh: () async {
                await Future<void>.delayed(const Duration(milliseconds: 400));
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _FeedLocationHeader(textTheme: textTheme)),
                  SliverToBoxAdapter(
                    child: _CategoryChips(
                      selectedIndex: filter.chipIndex,
                      onSelect: context.read<FeedFilterCubit>().selectChip,
                    ),
                  ),
                  if (loading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
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
                      const Spacer(),
                      Text(
                        '${live.length}',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (live.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      'No live activities in this filter. Host one from the Host tab.',
                      style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final a = live[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: index < live.length - 1 ? 12 : 0),
                          child: LiveActivityCard(
                            title: a.title,
                            category: a.category,
                            startsIn: activityStartsInLine(a.startsAt, now),
                            distance: a.spot.isEmpty ? 'Nearby' : a.spot,
                            joinedLabel: '${a.joinedCount} of ${a.capacity} joined',
                            socialLine: '',
                            friendInitials: const [],
                            friendNamesLine: null,
                            joinButtonLabel: _joinLabel(a),
                            joinEnabled: _joinEnabled(a),
                            onJoin: () => _tryJoinActivity(context, a),
                          ),
                        );
                      },
                      childCount: live.length,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'UPCOMING',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.textMuted,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${upcoming.length}',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (upcoming.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Text(
                      'No upcoming activities here yet.',
                      style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final a = upcoming[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index < upcoming.length - 1 ? 12 : 0,
                          ),
                          child: UpcomingActivityCard(
                            schedulePill: activitySchedulePill(a.startsAt),
                            category: a.category,
                            title: a.title,
                            distance: a.spot.isEmpty ? 'Nearby' : a.spot,
                            goingLabel: '${a.joinedCount} of ${a.capacity} going',
                            friendsLine: 'Friends going will show here later.',
                            joinButtonLabel: _joinLabel(a),
                            joinEnabled: _joinEnabled(a),
                            onJoin: () => _tryJoinActivity(context, a),
                          ),
                        );
                      },
                      childCount: upcoming.length,
                    ),
                  ),
                ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

String _joinLabel(Activity a) {
  if (a.joinedCount >= a.capacity) return 'Full';
  final u = FirebaseAuth.instance.currentUser;
  if (u != null && u.uid == a.hostUid) return 'Your activity';
  if (u != null && a.memberIds.contains(u.uid)) return 'Joined';
  return a.isLive ? 'Join now' : 'Join';
}

bool _joinEnabled(Activity a) {
  if (a.joinedCount >= a.capacity) return false;
  final u = FirebaseAuth.instance.currentUser;
  if (u != null && u.uid == a.hostUid) return false;
  if (u != null && a.memberIds.contains(u.uid)) return false;
  return true;
}

Future<void> _tryJoinActivity(BuildContext context, Activity activity) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    messenger?.showSnackBar(
      const SnackBar(content: Text('Sign in to join activities.')),
    );
    return;
  }
  if (user.uid == activity.hostUid) return;
  if (activity.joinedCount >= activity.capacity) return;

  try {
    await joinActivity(activity.id);
    if (!context.mounted) return;
    messenger?.showSnackBar(const SnackBar(content: Text("You're in!")));
  } catch (e) {
    if (!context.mounted) return;
    messenger?.showSnackBar(SnackBar(content: Text('$e')));
  }
}

class _FeedLocationHeader extends StatelessWidget {
  const _FeedLocationHeader({required this.textTheme});

  final TextTheme textTheme;

  static String _avatarLetter(User? user) {
    if (user == null) return '?';
    final email = user.email;
    if (email != null && email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    final name = user.displayName;
    if (name != null && name.isNotEmpty) {
      return name[0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        final user = authSnap.data;
        final letter = _avatarLetter(user);

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
                  letter,
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selectedIndex, required this.onSelect});

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
        itemCount: kFeedCategoryLabels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          final label = kFeedCategoryLabels[index];
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
                  color: selected ? AppColors.chipSelectedBorder : AppColors.chipBorder,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: selected ? AppColors.textPrimary : AppColors.textMuted,
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
