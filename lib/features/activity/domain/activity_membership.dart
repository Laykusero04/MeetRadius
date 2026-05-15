import 'package:firebase_auth/firebase_auth.dart';

import 'activity.dart';
import 'activity_capacity_labels.dart';

String? get currentActivityUserUid => FirebaseAuth.instance.currentUser?.uid;

bool activityIsHost(Activity activity, [String? uid]) {
  final u = uid ?? currentActivityUserUid;
  return u != null && u == activity.hostUid;
}

bool activityIsMember(Activity activity, [String? uid]) {
  final u = uid ?? currentActivityUserUid;
  return u != null && activity.memberIds.contains(u);
}

/// Host is always in [memberIds] at create time.
bool activityCanOpenChat(Activity activity, [String? uid]) {
  return activityIsMember(activity, uid);
}

bool activityCanJoin(Activity activity, [String? uid]) {
  final u = uid ?? currentActivityUserUid;
  if (u == null) return false;
  if (activityIsHost(activity, u)) return false;
  if (activityIsMember(activity, u)) return false;
  if (!activity.isDiscoverable) return false;
  if (activityIsFull(activity)) return false;
  return true;
}

bool activityCanLeave(Activity activity, [String? uid]) {
  final u = uid ?? currentActivityUserUid;
  return u != null && activityIsMember(activity, u) && !activityIsHost(activity, u);
}

String activityDisplayTitle(Activity activity, [String fallback = 'Activity']) {
  final t = activity.title.trim();
  return t.isNotEmpty ? t : fallback;
}
