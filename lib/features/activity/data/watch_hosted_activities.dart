import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/activity.dart';
import 'activity_from_firestore.dart';

/// Activities where [hostUid] is the host (profile grid / stats).
Stream<List<Activity>> watchHostedActivities(String hostUid) {
  if (hostUid.isEmpty) {
    return Stream<List<Activity>>.value(const []);
  }
  return FirebaseFirestore.instance
      .collection('activities')
      .where('hostUid', isEqualTo: hostUid)
      .limit(100)
      .snapshots()
      .map((snap) {
        final out = <Activity>[];
        for (final d in snap.docs) {
          try {
            out.add(activityFromFirestore(d.id, d.data()));
          } catch (_) {}
        }
        out.sort((a, b) => b.startsAt.compareTo(a.startsAt));
        return out;
      });
}
