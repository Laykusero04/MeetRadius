import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../activity/domain/activity.dart';
import '../../feed/presentation/widgets/activity_feed_labels.dart';
import '../data/activity_geo.dart';

/// Activity pins from Firestore on a dark basemap (Davao area).
/// Uses [flutter_map] + OSM/CARTO tiles (no Mapbox/Google API keys).
class ActivityMapScreen extends StatefulWidget {
  const ActivityMapScreen({super.key});

  @override
  State<ActivityMapScreen> createState() => _ActivityMapScreenState();
}

class _ActivityMapScreenState extends State<ActivityMapScreen> {
  static final _activitiesQuery = FirebaseFirestore.instance
      .collection('activities')
      .orderBy('createdAt', descending: true)
      .limit(50);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _activitiesQuery.snapshots(),
      builder: (context, snapshot) {
        final activities = snapshot.hasData
            ? snapshot.data!.docs.map(Activity.fromDoc).toList()
            : <Activity>[];
        final liveCount = activities.where((a) => a.isLive).length;

        return Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: ActivityGeo.davaoAreaCenter,
                initialZoom: 11.4,
                minZoom: 9,
                maxZoom: 18,
                backgroundColor: AppColors.scaffold,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
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
                          onTap: () => _showActivitySheet(context, a),
                        ),
                      ),
                  ],
                ),
                SimpleAttributionWidget(
                  alignment: Alignment.bottomRight,
                  backgroundColor: AppColors.navBar.withValues(alpha: 0.92),
                  source: Text(
                    'OpenStreetMap contributors, CARTO',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
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
                          'Davao City · 15 mi',
                          style: textTheme.titleSmall?.copyWith(
                            color: AppColors.textPrimary,
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
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.chipBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bolt,
                              size: 16,
                              color: AppColors.liveAccent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$liveCount live',
                              style: textTheme.labelMedium?.copyWith(
                                color: AppColors.textPrimary,
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
            if (snapshot.hasError)
              Positioned.fill(
                child: Material(
                  color: AppColors.scaffold.withValues(alpha: 0.85),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Could not load map data.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
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
      _ => Icons.place_outlined,
    };
  }

  void _showActivitySheet(BuildContext context, Activity a) {
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final subtitle = a.isLive
        ? 'Live · ${activityStartsInLine(a.startsAt, now)}'
        : '${activitySchedulePill(a.startsAt)} · ${activityStartsInLine(a.startsAt, now)}';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.chipBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (a.isLive) ...[
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.liveDot,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'LIVE',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.liveAccent,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Text(
                a.title,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.place_outlined, size: 18, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      a.spot.isEmpty ? 'Nearby' : a.spot,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${a.joinedCount} of ${a.capacity} going · ${a.category}',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.joinLive,
                    foregroundColor: AppColors.joinLiveForeground,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
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
    final ring = live ? AppColors.liveAccent : AppColors.upcomingBlue;
    final fill = live
        ? AppColors.joinLive.withValues(alpha: 0.95)
        : AppColors.joinUpcoming;
    final iconColor =
        live ? AppColors.joinLiveForeground : AppColors.joinUpcomingForeground;

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
