import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';

/// Static activity pins on a dark basemap (Davao area — matches feed demo).
/// Uses [flutter_map] + OSM/CARTO tiles (no Mapbox/Google API keys).
class ActivityMapScreen extends StatelessWidget {
  const ActivityMapScreen({super.key});

  static final _center = LatLng(7.065, 125.595);

  static final _pins = <_MapPin>[
    _MapPin(
      point: LatLng(7.088, 125.618),
      title: 'Pickup basketball — City Gym',
      subtitle: 'Live · Starts in 12 min',
      live: true,
      icon: Icons.sports_basketball,
    ),
    _MapPin(
      point: LatLng(7.081, 125.611),
      title: 'Coffee meetup — NCCC Mall',
      subtitle: 'Live · Starts in 20 min',
      live: true,
      icon: Icons.local_cafe_outlined,
    ),
    _MapPin(
      point: LatLng(7.018, 125.528),
      title: 'Hiking — Mt. Apo trailhead',
      subtitle: 'Saturday · 7am',
      live: false,
      icon: Icons.terrain_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: _center,
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
                for (final pin in _pins)
                  Marker(
                    width: 44,
                    height: 44,
                    point: pin.point,
                    child: _ActivityPinButton(
                      live: pin.live,
                      icon: pin.icon,
                      onTap: () => _showPinSheet(context, pin),
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
                          '${_pins.where((p) => p.live).length} live',
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
      ],
    );
  }

  void _showPinSheet(BuildContext context, _MapPin pin) {
    final textTheme = Theme.of(context).textTheme;
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
              if (pin.live) ...[
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
                pin.title,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                pin.subtitle,
                style: textTheme.bodyMedium?.copyWith(
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
                  child: const Text('View on feed (static)'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MapPin {
  const _MapPin({
    required this.point,
    required this.title,
    required this.subtitle,
    required this.live,
    required this.icon,
  });

  final LatLng point;
  final String title;
  final String subtitle;
  final bool live;
  final IconData icon;
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
