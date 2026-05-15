import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/activity.dart';
import 'activity_from_firestore.dart';

/// Activities the user joined but does not host (profile Joined tab).
Stream<List<Activity>> watchJoinedActivities(String uid) {
  if (uid.isEmpty) {
    return Stream<List<Activity>>.value(const []);
  }

  return FirebaseFirestore.instance
      .collection('activities')
      .where('memberIds', arrayContains: uid)
      .limit(100)
      .snapshots()
      .map((snap) {
        final out = <Activity>[];
        for (final d in snap.docs) {
          try {
            final a = activityFromFirestore(d.id, d.data());
            if (a.hostUid != uid) out.add(a);
          } catch (_) {}
        }
        out.sort((a, b) => b.startsAt.compareTo(a.startsAt));
        return out;
      });
}
