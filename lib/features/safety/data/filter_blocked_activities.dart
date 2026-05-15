import '../../activity/domain/activity.dart';

/// Hides activities hosted by anyone in [blockedUserIds].
List<Activity> filterBlockedActivities(
  List<Activity> activities,
  List<String> blockedUserIds,
) {
  if (blockedUserIds.isEmpty) return activities;
  return activities
      .where((a) => !blockedUserIds.contains(a.hostUid))
      .toList();
}
