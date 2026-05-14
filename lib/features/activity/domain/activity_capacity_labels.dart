import 'activity.dart';

/// True when the activity cannot accept more members.
bool activityIsFull(Activity a) =>
    !a.capacityUnlimited && a.joinedCount >= a.capacity;

/// Feed / map line: `3 of 10 going` or `5 going` when unlimited.
String activityGoingLabel(Activity a) {
  if (a.capacityUnlimited) return '${a.joinedCount} going';
  return '${a.joinedCount} of ${a.capacity} going';
}

/// Live tab wording (`joined` vs `going`).
String activityLiveJoinedLabel(Activity a) {
  if (a.capacityUnlimited) return '${a.joinedCount} joined';
  return '${a.joinedCount} of ${a.capacity} joined';
}

/// One line for settings / group info: max or ∞, and current turnout.
String activityCapacityDetail(Activity a) {
  final maxPart = a.capacityUnlimited ? 'Max ∞' : 'Max ${a.capacity}';
  return '$maxPart · ${activityGoingLabel(a)}';
}
