import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/meet_radius_palette.dart';
import '../../../activity/data/sync_due_hosted_activities.dart'
    show syncDueHostedActivities, syncDueHostedActivitiesFromList;
import '../../../activity/data/watch_activities.dart';
import '../../../safety/data/block_user.dart';
import '../../../safety/data/filter_blocked_activities.dart';
import '../../../activity/domain/activity.dart';
import '../../../activity/domain/activity_capacity_labels.dart';
import '../../../activity/domain/activity_membership.dart';
import '../../../activity/presentation/activity_actions.dart';
import '../../../../core/discovery/discovery_anchor_service.dart';
import '../../../profile/data/fetch_public_user_profile.dart';
import '../../../profile/domain/user_profile.dart';
import '../../../settings/application/settings_cubit.dart';
import '../../../settings/domain/user_settings.dart';
import '../../../social/data/follow_user.dart';
import '../../../social/domain/friends_attending.dart';
import '../../../activity/presentation/host_activity_actions_sheet.dart';
import '../../../activity/presentation/feed_activity_detail_screen.dart';
import '../../../map/data/activity_geo.dart';
import '../../application/feed_filter_cubit.dart';
import 'activity_feed_labels.dart';
import 'feed_location_empty_hint.dart';
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
  late Future<LatLng> _anchorFuture;
  String? _lastDueSyncKey;

  /// Avoids feed emptying when GPS resolves far from seeded activities (common on iOS).
  LatLng? _feedAnchor;

  Map<String, UserProfile?> _friendProfiles = const {};
  String? _friendProfilesRequestKey;

  bool _anchorUsedRegionalFallback = false;

  @override
  void initState() {
    super.initState();
    syncDueHostedActivities();
    _refreshAnchor();
  }

  void _refreshAnchor() {
    _feedAnchor = null;
    final cubit = context.read<SettingsCubit>();
    _anchorFuture = cubit.resolveDiscoveryAnchor();
  }

  int _countInRadius(List<Activity> all, LatLng anchor) =>
      all.where((a) => activityWithinDiscoveryRadius(a, anchor)).length;

  /// Picks GPS unless it hides everything while the MVP region still has activities.
  LatLng _commitFeedAnchor(
    LatLng candidate,
    List<Activity> all, {
    required bool useGpsForDiscovery,
  }) {
    int countFor(LatLng anchor) => _countInRadius(all, anchor);

    final regional = ActivityGeo.davaoAreaCenter;
    final chosen = applyRegionalDiscoveryFallback(
      candidate: candidate,
      allowFallback: useGpsForDiscovery,
      candidateShowsActivities: countFor(candidate) > 0,
      regionalShowsActivities: countFor(regional) > 0,
    );
    _anchorUsedRegionalFallback =
        useGpsForDiscovery &&
        chosen.latitude == regional.latitude &&
        chosen.longitude == regional.longitude &&
        (candidate.latitude != regional.latitude ||
            candidate.longitude != regional.longitude);

    if (_feedAnchor == null) {
      _feedAnchor = chosen;
      return chosen;
    }
    final prev = _feedAnchor!;
    if (chosen.latitude == prev.latitude && chosen.longitude == prev.longitude) {
      return prev;
    }
    final oldCount = countFor(prev);
    final newCount = countFor(chosen);
    if (newCount >= oldCount) {
      _feedAnchor = chosen;
      return chosen;
    }
    return prev;
  }

  double? _nearestActivityMiles(List<Activity> all, LatLng anchor) {
    double? nearest;
    for (final a in all) {
      final miles = distanceToAnchorMiles(a, anchor);
      if (miles == null) continue;
      nearest = nearest == null ? miles : (miles < nearest ? miles : nearest);
    }
    return nearest;
  }

  void _scheduleFriendProfiles(Set<String> uids) {
    final key = uids.join('|');
    if (key == _friendProfilesRequestKey) return;
    _friendProfilesRequestKey = key;
    if (uids.isEmpty) {
      if (_friendProfiles.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _friendProfilesRequestKey != key) return;
          setState(() => _friendProfiles = const {});
        });
      }
      return;
    }
    fetchPublicUserProfiles(uids).then((profiles) {
      if (!mounted || _friendProfilesRequestKey != key) return;
      setState(() => _friendProfiles = profiles);
    });
  }

  void _maybeSyncDueActivities(List<Activity> all) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final ids =
        all
            .where(
              (a) => a.hostUid == uid && a.isPastScheduledEnd() && !a.isEnded,
            )
            .map((a) => a.id)
            .toList()
          ..sort();
    if (ids.isEmpty) return;
    final key = ids.join(',');
    if (key == _lastDueSyncKey) return;
    _lastDueSyncKey = key;
    syncDueHostedActivitiesFromList(all);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<SettingsCubit, UserSettings>(
      listenWhen: (prev, next) =>
          prev.useGpsForDiscovery != next.useGpsForDiscovery ||
          prev.discoveryAnchorEpoch != next.discoveryAnchorEpoch,
      listener: (_, __) {
        setState(_refreshAnchor);
      },
      child: BlocBuilder<FeedFilterCubit, ({int chipIndex})>(
        builder: (context, filter) {
          return FutureBuilder<LatLng>(
            future: _anchorFuture,
            builder: (context, anchorSnap) {
              final settingsCubit = context.read<SettingsCubit>();
              final usingGps = settingsCubit.state.useGpsForDiscovery;
              final resolvedAnchor = anchorSnap.data;
              return StreamBuilder<List<String>>(
                stream: watchBlockedUserIds(),
                builder: (context, blockedSnap) {
                  final blocked = blockedSnap.data ?? const <String>[];
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

                      final rawFromFirestore =
                          listSnap.data ?? const <Activity>[];
                      final all = filterBlockedActivities(
                        rawFromFirestore,
                        blocked,
                      );
                      _maybeSyncDueActivities(all);
                      final savedAnchor =
                          settingsCubit.repository.loadDiscoveryAnchor();
                      final candidateAnchor =
                          resolvedAnchor ?? savedAnchor;
                      final anchor = _commitFeedAnchor(
                        candidateAnchor,
                        all,
                        useGpsForDiscovery: usingGps,
                      );
                      final inRadius = all
                          .where(
                            (a) => activityWithinDiscoveryRadius(a, anchor),
                          )
                          .toList();
                      final allOutsideRadius =
                          all.isNotEmpty && inRadius.isEmpty;
                      final nearestMiles = allOutsideRadius
                          ? _nearestActivityMiles(all, candidateAnchor)
                          : null;
                      final filtered = inRadius
                          .where((a) => a.matchesFeedChip(filter.chipIndex))
                          .toList();
                      final live = sortActivitiesForFeed(
                        filtered.where((a) => a.isLive).toList(),
                        anchor,
                      );
                      final upcoming = sortActivitiesForFeed(
                        filtered.where((a) => !a.isLive).toList(),
                        anchor,
                      );
                      final now = DateTime.now();
                      final loading = !listSnap.hasData &&
                          listSnap.connectionState == ConnectionState.waiting;

                      final p = context.palette;
                      final selfUid = FirebaseAuth.instance.currentUser?.uid;

                      return StreamBuilder<List<String>>(
                        stream: watchFollowingIds(),
                        builder: (context, followingSnap) {
                          final following = followingIdsSet(
                            followingSnap.data ?? const [],
                          );
                          final friendUids = friendUidsOnActivities(
                            [...live, ...upcoming],
                            following,
                          );
                          _scheduleFriendProfiles(friendUids);
                          final friendProfiles = _friendProfiles;

                          return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      8,
                                      20,
                                      0,
                                    ),
                                    child: Text(
                                      discoveryAreaHeaderLabel(
                                        anchor: anchor,
                                        usingGps: usingGps,
                                        usingRegionalFallback:
                                            _anchorUsedRegionalFallback,
                                      ),
                                      style: textTheme.titleSmall?.copyWith(
                                        color: p.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (_anchorUsedRegionalFallback)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        0,
                                        20,
                                        4,
                                      ),
                                      child: Text(
                                        'GPS is far from local activities — showing ${kDefaultDiscoveryAreaLabel} area',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: p.liveAccent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  _CategoryChips(
                                    selectedIndex: filter.chipIndex,
                                    onSelect: context
                                        .read<FeedFilterCubit>()
                                        .selectChip,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      10,
                                      20,
                                      16,
                                    ),
                                    child: _FeedSectionTabs(
                                      selected: _section,
                                      onSelect: (i) =>
                                          setState(() => _section = i),
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
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: p.liveAccent,
                                              ),
                                            ),
                                          )
                                        : RefreshIndicator(
                                            color: p.liveAccent,
                                            onRefresh: () async {
                                              await Future<void>.delayed(
                                                const Duration(
                                                  milliseconds: 400,
                                                ),
                                              );
                                            },
                                            child: ListView(
                                              physics:
                                                  const AlwaysScrollableScrollPhysics(),
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                20,
                                                6,
                                                20,
                                                88,
                                              ),
                                              children: [
                                                if (_section == 0)
                                                  ..._buildLiveSectionChildren(
                                                    context,
                                                    live,
                                                    now,
                                                    textTheme,
                                                    p,
                                                    anchor,
                                                    followingIds: following,
                                                    friendProfiles:
                                                        friendProfiles,
                                                    selfUid: selfUid,
                                                    allOutsideRadius:
                                                        allOutsideRadius,
                                                    totalActivityCount:
                                                        all.length,
                                                    nearestMiles: nearestMiles,
                                                    usedRegionalFallback:
                                                        _anchorUsedRegionalFallback,
                                                  )
                                                else
                                                  ..._buildUpcomingChildren(
                                                    context,
                                                    upcoming,
                                                    textTheme,
                                                    p,
                                                    anchor,
                                                    followingIds: following,
                                                    friendProfiles:
                                                        friendProfiles,
                                                    selfUid: selfUid,
                                                    allOutsideRadius:
                                                        allOutsideRadius,
                                                    totalActivityCount:
                                                        all.length,
                                                    nearestMiles: nearestMiles,
                                                    usedRegionalFallback:
                                                        _anchorUsedRegionalFallback,
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
                },
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildLiveSectionChildren(
    BuildContext context,
    List<Activity> live,
    DateTime now,
    TextTheme textTheme,
    MeetRadiusPalette p,
    LatLng anchor, {
    required Set<String> followingIds,
    required Map<String, UserProfile?> friendProfiles,
    String? selfUid,
    required bool allOutsideRadius,
    required int totalActivityCount,
    required double? nearestMiles,
    required bool usedRegionalFallback,
  }) {
    if (live.isEmpty) {
      if (allOutsideRadius && totalActivityCount > 0) {
        return [
          FeedLocationEmptyHint(
            activityCount: totalActivityCount,
            nearestMiles: nearestMiles,
            usedRegionalFallback: usedRegionalFallback,
          ),
        ];
      }
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
                      Icon(
                        Icons.local_fire_department_outlined,
                        color: p.liveAccent,
                        size: 22,
                      ),
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
            distance: activityDistanceDetailLine(live[i], anchor),
            joinedLabel: activityLiveJoinedLabel(live[i]),
            socialLine: '',
            friendInitials: _friendsDisplay(
              live[i],
              followingIds,
              friendProfiles,
              selfUid,
            ).initials,
            friendNamesLine: _friendsDisplay(
              live[i],
              followingIds,
              friendProfiles,
              selfUid,
            ).namesLine,
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
    LatLng anchor, {
    required Set<String> followingIds,
    required Map<String, UserProfile?> friendProfiles,
    String? selfUid,
    required bool allOutsideRadius,
    required int totalActivityCount,
    required double? nearestMiles,
    required bool usedRegionalFallback,
  }) {
    if (upcoming.isEmpty) {
      if (allOutsideRadius && totalActivityCount > 0) {
        return [
          FeedLocationEmptyHint(
            activityCount: totalActivityCount,
            nearestMiles: nearestMiles,
            usedRegionalFallback: usedRegionalFallback,
          ),
        ];
      }
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
                      Icon(
                        Icons.event_outlined,
                        color: p.upcomingBlue,
                        size: 22,
                      ),
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
            distance: activityDistanceDetailLine(upcoming[i], anchor),
            goingLabel: activityGoingLabel(upcoming[i]),
            friendsLine: _friendsLine(
              upcoming[i],
              followingIds,
              friendProfiles,
              selfUid,
            ),
            joinButtonLabel: _joinLabel(upcoming[i]),
            joinEnabled: _joinEnabled(upcoming[i]),
            isLeaveAction: _isMemberNotHost(upcoming[i]),
            isOwnActivity:
                FirebaseAuth.instance.currentUser?.uid == upcoming[i].hostUid,
            onManageOwn:
                FirebaseAuth.instance.currentUser?.uid == upcoming[i].hostUid
                ? () => showHostActivityActionsSheet(context, upcoming[i])
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

  FriendsAttendingDisplay _friendsDisplay(
    Activity activity,
    Set<String> followingIds,
    Map<String, UserProfile?> friendProfiles,
    String? selfUid,
  ) {
    return friendsAttendingForActivity(
      activity: activity,
      followingIds: followingIds,
      profiles: friendProfiles,
      excludeUid: selfUid,
    );
  }

  String _friendsLine(
    Activity activity,
    Set<String> followingIds,
    Map<String, UserProfile?> friendProfiles,
    String? selfUid,
  ) {
    final display = _friendsDisplay(
      activity,
      followingIds,
      friendProfiles,
      selfUid,
    );
    return display.hasLine ? display.namesLine! : '';
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
              Icon(icon, size: 22, color: selected ? accent : p.textMuted),
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
  if (activityIsHost(a)) return 'Manage';
  if (activityCanOpenChat(a) && !activityCanLeave(a)) return 'Open chat';
  if (activityCanLeave(a)) return 'Leave';
  if (activityIsFull(a)) return 'Full';
  return a.isLive ? 'Join now' : 'Join';
}

bool _isMemberNotHost(Activity a) => activityCanLeave(a);

bool _joinEnabled(Activity a) {
  if (activityIsHost(a)) return false;
  if (activityCanLeave(a)) return true;
  if (activityCanOpenChat(a)) return true;
  return activityCanJoin(a);
}

Future<void> _tryJoinActivity(BuildContext context, Activity activity) async {
  if (activityCanOpenChat(activity) && !activityCanLeave(activity)) {
    openActivityHub(context, activity: activity, openChatIfMember: true);
    return;
  }
  await performActivityMembershipAction(context, activity);
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
