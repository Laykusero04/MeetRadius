import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../features/map/data/activity_geo.dart';
import '../../features/settings/data/settings_repository.dart';

export 'activity_distance.dart';
export 'discovery_config.dart';

/// Current GPS fix when services and permission allow; otherwise null.
Future<LatLng?> fetchCurrentGpsPosition() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return null;

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission != LocationPermission.whileInUse &&
      permission != LocationPermission.always) {
    return null;
  }

  try {
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 12),
      ),
    );
    return LatLng(pos.latitude, pos.longitude);
  } catch (_) {
    return null;
  }
}

/// Resolves the map/feed anchor from GPS or saved manual coordinates.
///
/// GPS is **not** written to prefs here — only [SettingsRepository.saveDiscoveryAnchor]
/// (e.g. “Refresh discovery location” with GPS off) updates the manual anchor.
Future<LatLng> resolveDiscoveryAnchor(SettingsRepository repository) async {
  final settings = repository.load();
  if (settings.useGpsForDiscovery) {
    final gps = await fetchCurrentGpsPosition();
    if (gps != null) return gps;
  }
  return repository.loadDiscoveryAnchor();
}

/// When GPS is on but far from MVP activities, use the regional center so dev emulators work.
LatLng applyRegionalDiscoveryFallback({
  required LatLng candidate,
  required bool allowFallback,
  required bool candidateShowsActivities,
  required bool regionalShowsActivities,
}) {
  if (!allowFallback || candidateShowsActivities || !regionalShowsActivities) {
    return candidate;
  }
  return ActivityGeo.davaoAreaCenter;
}
