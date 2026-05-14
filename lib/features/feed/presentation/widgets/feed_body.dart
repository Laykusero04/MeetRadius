import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/meet_radius_palette.dart';
import '../../../activity/data/join_activity.dart';
import '../../../activity/data/leave_activity.dart';
import '../../../activity/data/watch_activities.dart';
import '../../../activity/domain/activity.dart';
import '../../../activity/domain/activity_capacity_labels.dart';
import '../../../activity/presentation/host_activity_actions_sheet.dart';
import '../../../activity/presentation/feed_activity_detail_screen.dart';
import '../../application/feed_filter_cubit.dart';
import 'activity_feed_labels.dart';
import 'live_activity_card.dart';
import 'upcoming_activity_card.dart';

/// Feed UI backed by Firestore `activities` (see [watchActivities]).
///
/// Category chips filter both lists; **Live now** / **Upcoming** tabs keep each
/// list independently scrollable so long live lists do not bury upcoming items.
class FeedBody extends StatefulWidget {
  const FeedBody({super.key});

  @override
  State<FeedBody> createState() => _FeedBodyState();
}

class _FeedBodyState extends State<FeedBody> {
  /// 0 = live, 1 = upcoming
  int _section = 0;

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
                    style: textTheme.bodyMedium?.copyWith(
                      color: context.palette.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final all = listSnap.data ?? const <Activity>[];
            final filtered =
                all.where((a) => a.matchesFeedChip(filter.chipIndex)).toList();
            final live = filtered.where((a) => a.isLive).toList();
            final upcoming = filtered.where((a) => !a.isLive).toList();
            final now = DateTime.now();
            final loading = listSnap.connectionState == ConnectionState.waiting &&
                all.isEmpty;

            final p = context.palette;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CategoryChips(
                  selectedIndex: filter.chipIndex,
                  onSelect: context.read<FeedFilterCubit>().selectChip,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  child: _FeedSectionTabs(
                    selected: _section,
                    onSelect: (i) => setState(() => _section = i),
                    liveCount: live.length,
                    upcomingCount: upcoming.length,
                  ),
                ),
                Expanded(
                  child: loading
                      ? Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: p.liveAccent,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          color: p.liveAccent,
                          onRefresh: () async {
                            await Future<void>.delayed(
                              const Duration(milliseconds: 400),
                            );
                          },
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 6, 20, 88),
                            children: [
                              if (_section == 0)
                                ..._buildLiveSectionChildren(
                                  context,
                                  live,
                                  now,
                                  textTheme,
                                  p,
                                )
                              else
                                ..._buildUpcomingChildren(
                                  context,
                                  upcoming,
                                  textTheme,
                                  p,
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Widget> _buildLiveSectionChildren(
    BuildContext context,
    List<Activity> live,
    DateTime now,
    TextTheme textTheme,
    MeetRadiusPalette p,
  ) {
    if (live.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.cardBorderSubtle),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_fire_department_outlined,
                          color: p.liveAccent, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Nothing live right now',
                        style: textTheme.titleSmall?.copyWith(
                          color: p.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Host something from the + menu, or check Upcoming for planned activities.',
                    style: textTheme.bodySmall?.copyWith(
                      color: p.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    return [
      for (var i = 0; i < live.length; i++) ...[
        Padding(
          padding: EdgeInsets.only(bottom: i < live.length - 1 ? 12 : 0),
          child: LiveActivityCard(
            title: live[i].title,
            category: live[i].category,
            startsIn: activityStartsInLine(live[i].startsAt, now),
            distance: live[i].spot.isEmpty ? 'Nearby' : live[i].spot,
            joinedLabel: activityLiveJoinedLabel(live[i]),
            socialLine: '',
            friendInitials: const [],
            friendNamesLine: null,
            joinButtonLabel: _joinLabel(live[i]),
            joinEnabled: _joinEnabled(live[i]),
            isLeaveAction: _isMemberNotHost(live[i]),
            isOwnActivity:
                FirebaseAuth.instance.currentUser?.uid == live[i].hostUid,
            onManageOwn:
                FirebaseAuth.instance.currentUser?.uid == live[i].hostUid
                    ? () => showHostActivityActionsSheet(context, live[i])
                    : null,
            onTapActivity: () => openFeedActivityDetail(
              context,
              activityId: live[i].id,
              activityTitle: live[i].title,
            ),
            onJoin: () => _tryJoinActivity(context, live[i]),
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildUpcomingChildren(
    BuildContext context,
    List<Activity> upcoming,
    TextTheme textTheme,
    MeetRadiusPalette p,
  ) {
    if (upcoming.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.cardBorderSubtle),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.event_outlined, color: p.upcomingBlue, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'No upcoming in this filter',
                        style: textTheme.titleSmall?.copyWith(
                          color: p.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Switch category chips or open Live now to see what is happening today.',
                    style: textTheme.bodySmall?.copyWith(
                      color: p.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    return [
      for (var i = 0; i < upcoming.length; i++) ...[
        Padding(
          padding: EdgeInsets.only(bottom: i < upcoming.length - 1 ? 12 : 0),
          child: UpcomingActivityCard(
            schedulePill: activitySchedulePill(upcoming[i].startsAt),
            category: upcoming[i].category,
            title: upcoming[i].title,
            distance: upcoming[i].spot.isEmpty ? 'Nearby' : upcoming[i].spot,
            goingLabel: activityGoingLabel(upcoming[i]),
            friendsLine: 'Friends going will show here later.',
            joinButtonLabel: _joinLabel(upcoming[i]),
            joinEnabled: _joinEnabled(upcoming[i]),
            isLeaveAction: _isMemberNotHost(upcoming[i]),
            isOwnActivity:
                FirebaseAuth.instance.currentUser?.uid == upcoming[i].hostUid,
            onManageOwn:
                FirebaseAuth.instance.currentUser?.uid == upcoming[i].hostUid
                    ? () =>
                        showHostActivityActionsSheet(context, upcoming[i])
                    : null,
            onTapActivity: () => openFeedActivityDetail(
              context,
              activityId: upcoming[i].id,
              activityTitle: upcoming[i].title,
            ),
            onJoin: () => _tryJoinActivity(context, upcoming[i]),
          ),
        ),
      ],
    ];
  }
}

class _FeedSectionTabs extends StatelessWidget {
  const _FeedSectionTabs({
    required this.selected,
    required this.onSelect,
    required this.liveCount,
    required this.upcomingCount,
  });

  final int selected;
  final ValueChanged<int> onSelect;
  final int liveCount;
  final int upcomingCount;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: _SegmentButton(
            selected: selected == 0,
            icon: Icons.bolt_rounded,
            label: 'Live now',
            count: liveCount,
            accent: p.liveAccent,
            onTap: () => onSelect(0),
            textTheme: textTheme,
            palette: p,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SegmentButton(
            selected: selected == 1,
            icon: Icons.event_available_outlined,
            label: 'Upcoming',
            count: upcomingCount,
            accent: p.upcomingBlue,
            onTap: () => onSelect(1),
            textTheme: textTheme,
            palette: p,
          ),
        ),
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.selected,
    required this.icon,
    required this.label,
    required this.count,
    required this.accent,
    required this.onTap,
    required this.textTheme,
    required this.palette,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final int count;
  final Color accent;
  final VoidCallback onTap;
  final TextTheme textTheme;
  final MeetRadiusPalette palette;

  @override
  Widget build(BuildContext context) {
    final p = palette;

    return Material(
      color: selected ? p.card : p.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? accent.withValues(alpha: 0.65) : p.chipBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? accent : p.textMuted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge?.copyWith(
                    color: selected ? p.textPrimary : p.textMuted,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: selected
                      ? accent.withValues(alpha: 0.18)
                      : p.chipBorder.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: textTheme.labelMedium?.copyWith(
                    color: selected ? accent : p.textMuted,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _joinLabel(Activity a) {
  final u = FirebaseAuth.instance.currentUser;
  if (u != null && u.uid == a.hostUid) return 'Your activity';
  if (_isMemberNotHost(a)) return 'Leave';
  if (activityIsFull(a)) return 'Full';
  return a.isLive ? 'Join now' : 'Join';
}

bool _isMemberNotHost(Activity a) {
  final u = FirebaseAuth.instance.currentUser;
  return u != null && a.memberIds.contains(u.uid) && u.uid != a.hostUid;
}

bool _joinEnabled(Activity a) {
  final u = FirebaseAuth.instance.currentUser;
  if (u != null && u.uid == a.hostUid) return false;
  if (_isMemberNotHost(a)) return true;
  if (activityIsFull(a)) return false;
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

  if (_isMemberNotHost(activity)) {
    try {
      await leaveActivity(activity.id);
      if (!context.mounted) return;
      messenger?.showSnackBar(
        const SnackBar(content: Text('You left this activity.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger?.showSnackBar(SnackBar(content: Text('$e')));
    }
    return;
  }

  if (activityIsFull(activity)) return;

  try {
    await joinActivity(activity.id);
    if (!context.mounted) return;
    messenger?.showSnackBar(const SnackBar(content: Text("You're in!")));
  } catch (e) {
    if (!context.mounted) return;
    messenger?.showSnackBar(SnackBar(content: Text('$e')));
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final p = context.palette;

    // ListView padding was inside a short SizedBox, which clipped chip labels
    // into thin strips. Keep vertical spacing outside the scroll viewport.
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
      child: SizedBox(
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: EdgeInsets.zero,
          itemCount: kFeedCategoryLabels.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final selected = index == selectedIndex;
            final label = kFeedCategoryLabels[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelect(index),
                borderRadius: BorderRadius.circular(24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  constraints: const BoxConstraints(minHeight: 44),
                  decoration: BoxDecoration(
                    color: p.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: selected ? p.chipSelectedBorder : p.chipBorder,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: textTheme.titleSmall?.copyWith(
                      fontSize: 15,
                      height: 1.15,
                      letterSpacing: 0.15,
                      color: selected ? p.textPrimary : p.textSecondary,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
