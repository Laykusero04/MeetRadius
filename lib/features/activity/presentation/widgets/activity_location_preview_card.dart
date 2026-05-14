import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/meet_radius_palette.dart';
import '../../domain/activity.dart';
import '../../../map/data/activity_geo.dart';
import '../activity_maps_actions.dart';

/// Read-only map preview for an activity pin; tap opens directions / external maps.
class ActivityLocationPreviewCard extends StatelessWidget {
  const ActivityLocationPreviewCard({
    super.key,
    required this.activity,
  });

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final spot = activity.spot.trim();
    final lat = activity.latitude;
    final lng = activity.longitude;

    late final LatLng displayPoint;
    late final bool hasCoords;
    if (lat != null && lng != null) {
      hasCoords = true;
      displayPoint = LatLng(lat, lng);
    } else if (spot.isNotEmpty) {
      hasCoords = false;
      displayPoint = ActivityGeo.jitterFromActivityId(activity.id);
    } else {
      return const SizedBox.shrink();
    }

    final label = spot.isNotEmpty ? spot : 'Meeting point';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LOCATION',
          style: textTheme.labelLarge?.copyWith(
            color: p.textMuted,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (lat != null && lng != null) {
                showActivityMapsActionSheet(
                  context,
                  latitude: lat,
                  longitude: lng,
                  placeLabel: label,
                );
              } else if (spot.isNotEmpty) {
                showActivityMapsSearchSheet(context, placeQuery: spot);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.cardBorderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: SizedBox(
                      height: 200,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          FlutterMap(
                            options: MapOptions(
                              initialCenter: displayPoint,
                              initialZoom: hasCoords ? 15.2 : 12.0,
                              interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.drag |
                                    InteractiveFlag.pinchZoom |
                                    InteractiveFlag.doubleTapZoom,
                              ),
                              backgroundColor: p.scaffold,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                                subdomains: const ['a', 'b', 'c', 'd'],
                                userAgentPackageName: 'com.example.meet_radius',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    width: 40,
                                    height: 40,
                                    point: displayPoint,
                                    child: Icon(
                                      Icons.location_on,
                                      color: p.liveAccent,
                                      size: 40,
                                      shadows: const [
                                        Shadow(
                                          blurRadius: 6,
                                          color: Colors.black38,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.55),
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  24,
                                  12,
                                  10,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      hasCoords
                                          ? Icons.navigation_outlined
                                          : Icons.search,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        hasCoords
                                            ? 'Tap for directions & maps'
                                            : 'No saved pin — tap to search this place',
                                        style: textTheme.labelLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.place_outlined, size: 20, color: p.textMuted),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            spot.isNotEmpty ? spot : 'Approximate area (no exact pin)',
                            style: textTheme.bodyMedium?.copyWith(
                              color: p.textPrimary,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
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
  }
}
