import 'package:latlong2/latlong.dart';

import '../../features/activity/domain/activity.dart';
import '../../features/map/data/activity_geo.dart';
import 'discovery_config.dart';

const _distance = Distance();

/// Pin used for distance (stored coords or stable jitter).
LatLng activityPinPoint(Activity activity) {
  if (activity.latitude != null && activity.longitude != null) {
    return LatLng(activity.latitude!, activity.longitude!);
  }
  return ActivityGeo.jitterFromActivityId(activity.id);
}

double? distanceToAnchorMiles(Activity activity, LatLng anchor) {
  final pin = activityPinPoint(activity);
  final meters = _distance(pin, anchor);
  return meters / 1609.344;
}

String activityDistanceLabel(Activity activity, LatLng anchor) {
  final miles = distanceToAnchorMiles(activity, anchor);
  if (miles == null) return 'Nearby';
  if (miles < 0.1) return 'At meeting spot';
  if (miles < 10) return '${miles.toStringAsFixed(1)} mi';
  return '${miles.round()} mi';
}

String activityDistanceDetailLine(Activity activity, LatLng anchor) {
  final miles = distanceToAnchorMiles(activity, anchor);
  final dist = miles != null ? activityDistanceLabel(activity, anchor) : 'Nearby';
  final spot = activity.spot.trim();
  if (spot.isEmpty) return dist;
  return '$dist · $spot';
}

bool activityWithinDiscoveryRadius(Activity activity, LatLng anchor) {
  final miles = distanceToAnchorMiles(activity, anchor);
  if (miles == null) return true;
  return miles <= kDiscoveryRadiusMiles;
}

/// Live first, then distance, then sooner start times.
List<Activity> sortActivitiesForFeed(List<Activity> list, LatLng anchor) {
  final copy = [...list];
  copy.sort((a, b) {
    if (a.isLive != b.isLive) return a.isLive ? -1 : 1;
    final da = distanceToAnchorMiles(a, anchor) ?? double.infinity;
    final db = distanceToAnchorMiles(b, anchor) ?? double.infinity;
    final cmp = da.compareTo(db);
    if (cmp != 0) return cmp;
    return a.startsAt.compareTo(b.startsAt);
  });
  return copy;
}

String discoveryAreaHeaderLabel({
  required LatLng anchor,
  required bool usingGps,
  bool usingRegionalFallback = false,
}) {
  final String label;
  if (usingRegionalFallback) {
    label = kDefaultDiscoveryAreaLabel;
  } else if (usingGps) {
    label = 'Near you';
  } else {
    label = kDefaultDiscoveryAreaLabel;
  }
  return '$label · ${kDiscoveryRadiusMiles.round()} mi';
}
