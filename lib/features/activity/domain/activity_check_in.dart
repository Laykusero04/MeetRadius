import 'package:latlong2/latlong.dart';

import 'activity.dart';
import 'activity_membership.dart';

/// Max distance from the activity pin to allow check-in.
const double kCheckInGeofenceMeters = 150;

/// Check-in opens 30 minutes before start through end (or scheduled end).
bool activityCanCheckIn(Activity activity, [String? uid]) {
  final u = uid ?? currentActivityUserUid;
  if (u == null || !activityCanOpenChat(activity, u)) return false;
  if (activity.hasCheckedIn(u)) return false;
  if (activity.latitude == null || activity.longitude == null) return false;

  final now = DateTime.now();
  final windowStart = activity.startsAt.subtract(const Duration(minutes: 30));
  if (now.isBefore(windowStart)) return false;

  final windowEnd = activity.endedAt ??
      activity.endsAt ??
      activity.startsAt.add(const Duration(hours: 6));
  if (now.isAfter(windowEnd)) return false;

  return true;
}

double? distanceToActivityMeters(
  Activity activity,
  double userLat,
  double userLng,
) {
  final lat = activity.latitude;
  final lng = activity.longitude;
  if (lat == null || lng == null) return null;
  const dist = Distance();
  return dist(
    LatLng(userLat, userLng),
    LatLng(lat, lng),
  );
}

bool isWithinCheckInGeofence(
  Activity activity,
  double userLat,
  double userLng,
) {
  final meters = distanceToActivityMeters(activity, userLat, userLng);
  if (meters == null) return false;
  return meters <= kCheckInGeofenceMeters;
}
