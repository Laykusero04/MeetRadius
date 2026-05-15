import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/discovery/discovery_anchor_service.dart';
import '../../../core/theme/meet_radius_palette.dart';
import '../../settings/domain/user_settings.dart';
import '../../activity/data/sync_due_hosted_activities.dart';
import '../../activity/data/watch_activities.dart';
import '../../activity/domain/activity.dart';
import '../../activity/presentation/feed_activity_detail_screen.dart';
import '../../settings/application/settings_cubit.dart';
import '../data/activity_geo.dart';

/// Map pins from Firestore `activities` (see [watchActivities]).
class ActivityMapScreen extends StatefulWidget {
  const ActivityMapScreen({super.key});

  @override
  State<ActivityMapScreen> createState() => _ActivityMapScreenState();
}

class _ActivityMapScreenState extends State<ActivityMapScreen> {
  late Future<LatLng> _anchorFuture;
  String? _lastDueSyncKey;

  @override
  void initState() {
    super.initState();
    _refreshAnchor();
  }

  void _refreshAnchor() {
    _anchorFuture = context.read<SettingsCubit>().resolveDiscoveryAnchor();
  }

  void _maybeSyncDueActivities(List<Activity> all) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final ids = all
        .where((a) => a.hostUid == uid && a.isPastScheduledEnd() && !a.isEnded)
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
    final usingGps = context.watch<SettingsCubit>().state.useGpsForDiscovery;

    return BlocListener<SettingsCubit, UserSettings>(
      listenWhen: (prev, next) =>
          prev.useGpsForDiscovery != next.useGpsForDiscovery ||
          prev.discoveryAnchorEpoch != next.discoveryAnchorEpoch,
      listener: (_, __) => setState(_refreshAnchor),
      child: FutureBuilder<LatLng>(
        future: _anchorFuture,
        builder: (context, anchorSnap) {
          final candidate = anchorSnap.data ?? ActivityGeo.davaoAreaCenter;

          return StreamBuilder<List<Activity>>(
            stream: watchActivities(),
            builder: (context, snap) {
              final raw = snap.data ?? const <Activity>[];
              _maybeSyncDueActivities(raw);
              final regional = ActivityGeo.davaoAreaCenter;
              int inRadiusCount(LatLng a) =>
                  raw.where((x) => activityWithinDiscoveryRadius(x, a)).length;
              final anchor = applyRegionalDiscoveryFallback(
                candidate: candidate,
                allowFallback: usingGps,
                candidateShowsActivities: inRadiusCount(candidate) > 0,
                regionalShowsActivities: inRadiusCount(regional) > 0,
              );
              final regionalFallback =
                  usingGps &&
                  anchor.latitude == regional.latitude &&
                  anchor.longitude == regional.longitude;
              final header = discoveryAreaHeaderLabel(
                anchor: anchor,
                usingGps: usingGps,
                usingRegionalFallback: regionalFallback,
              );
              final activities = raw
                  .where((a) => activityWithinDiscoveryRadius(a, anchor))
                  .toList();
        final liveCount = activities.where((a) => a.isLive).length;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: anchor,
            initialZoom: 11.4,
            minZoom: 9,
            maxZoom: 18,
            backgroundColor: context.palette.scaffold,
          ),
          children: [
            TileLayer(
              urlTemplate: isDark
                  ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                  : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.example.meet_radius',
            ),
            MarkerLayer(
              markers: [
                for (final a in activities)
                  Marker(
                    width: 44,
                    height: 44,
                    point: _pinPoint(a),
                    child: _ActivityPinButton(
                      live: a.isLive,
                      icon: _categoryIcon(a.category),
                      onTap: () => openFeedActivityDetail(
                        context,
                        activityId: a.id,
                        activityTitle: a.title,
                      ),
                    ),
                  ),
              ],
            ),
            SimpleAttributionWidget(
              alignment: Alignment.bottomRight,
              backgroundColor: context.palette.navBar.withValues(alpha: 0.92),
              source: Text(
                'OpenStreetMap contributors, CARTO',
                style: textTheme.labelSmall?.copyWith(
                  color: context.palette.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      header,
                      style: textTheme.titleSmall?.copyWith(
                        color: context.palette.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.palette.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: context.palette.chipBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt,
                          size: 16,
                          color: context.palette.liveAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$liveCount live',
                          style: textTheme.labelMedium?.copyWith(
                            color: context.palette.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
            },
          );
        },
      ),
    );
  }

  static LatLng _pinPoint(Activity a) {
    if (a.latitude != null && a.longitude != null) {
      return LatLng(a.latitude!, a.longitude!);
    }
    return ActivityGeo.jitterFromActivityId(a.id);
  }

  static IconData _categoryIcon(String category) {
    return switch (category) {
      'Sports' => Icons.sports_basketball,
      'Coffee' => Icons.local_cafe_outlined,
      'Social' => Icons.groups_2_outlined,
      'Outdoor' => Icons.terrain_outlined,
      'Gym' => Icons.fitness_center,
      'Study' => Icons.menu_book_outlined,
      'Food' => Icons.restaurant_outlined,
      'Music' => Icons.music_note_outlined,
      'Other' => Icons.more_horiz,
      _ => Icons.place_outlined,
    };
  }
}

class _ActivityPinButton extends StatelessWidget {
  const _ActivityPinButton({
    required this.live,
    required this.icon,
    required this.onTap,
  });

  final bool live;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ring = live ? context.palette.liveAccent : context.palette.upcomingBlue;
    final fill = live
        ? context.palette.joinLive.withValues(alpha: 0.95)
        : context.palette.joinUpcoming;
    final iconColor =
        live ? context.palette.joinLiveForeground : context.palette.joinUpcomingForeground;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill,
            border: Border.all(color: ring, width: 2),
            boxShadow: [
              BoxShadow(
                color: ring.withValues(alpha: 0.35),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }
}
