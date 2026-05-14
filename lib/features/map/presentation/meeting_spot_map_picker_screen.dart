import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../../../shared/widgets/brand_gradient.dart';
import '../data/activity_geo.dart';

/// Full-screen map with a fixed center pin; the chosen point is the camera center.
///
/// Returns the selected [LatLng] via [Navigator.pop], or null if dismissed.
class MeetingSpotMapPickerScreen extends StatefulWidget {
  const MeetingSpotMapPickerScreen({super.key, this.initialPosition});

  final LatLng? initialPosition;

  @override
  State<MeetingSpotMapPickerScreen> createState() =>
      _MeetingSpotMapPickerScreenState();
}

class _MeetingSpotMapPickerScreenState extends State<MeetingSpotMapPickerScreen> {
  final MapController _mapController = MapController();
  late LatLng _center;

  @override
  void initState() {
    super.initState();
    _center = widget.initialPosition ?? ActivityGeo.davaoAreaCenter;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _syncCenterFromCamera() {
    final c = _mapController.camera.center;
    if (_center.latitude != c.latitude || _center.longitude != c.longitude) {
      setState(() => _center = c);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final start = widget.initialPosition ?? ActivityGeo.davaoAreaCenter;

    return Scaffold(
      backgroundColor: p.scaffold,
      appBar: AppBar(
        backgroundColor: p.card,
        foregroundColor: p.textPrimary,
        elevation: 0,
        title: Text(
          'Meeting spot',
          style: textTheme.titleMedium?.copyWith(
            color: p.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: start,
                initialZoom: 14,
                minZoom: 9,
                maxZoom: 18,
                backgroundColor: p.scaffold,
                onMapEvent: (event) {
                  if (event is MapEventMoveEnd ||
                      event is MapEventFlingAnimationEnd) {
                    _syncCenterFromCamera();
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: isDark
                      ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                      : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.example.meet_radius',
                ),
                SimpleAttributionWidget(
                  alignment: Alignment.bottomRight,
                  backgroundColor: p.navBar.withValues(alpha: 0.92),
                  source: Text(
                    'OpenStreetMap contributors, CARTO',
                    style: textTheme.labelSmall?.copyWith(
                      color: p.textSecondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Transform.translate(
                  offset: const Offset(0, -22),
                  child: Icon(
                    Icons.place,
                    size: 52,
                    color: p.liveAccent,
                    shadows: const [
                      Shadow(
                        blurRadius: 6,
                        color: Color(0x66000000),
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Material(
                  color: p.card,
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Pan and zoom so the pin sits on your meet-up point.',
                          style: textTheme.bodySmall?.copyWith(
                            color: p.textSecondary,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${_center.latitude.toStringAsFixed(5)}, '
                          '${_center.longitude.toStringAsFixed(5)}',
                          style: textTheme.labelMedium?.copyWith(
                            color: p.textMuted,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 14),
                        GradientCtaButton(
                          onPressed: () => Navigator.pop<LatLng>(
                            context,
                            _mapController.camera.center,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: const Text('Use this location'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
