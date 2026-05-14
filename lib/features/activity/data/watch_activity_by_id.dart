import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/activity.dart';
import 'activity_from_firestore.dart';

/// One activity doc (e.g. group chat header / member list).
Stream<Activity?> watchActivityById(String activityId) {
  if (activityId.isEmpty) {
    return Stream<Activity?>.value(null);
  }
  return FirebaseFirestore.instance
      .collection('activities')
      .doc(activityId)
      .snapshots()
      .map((snap) {
        if (!snap.exists || snap.data() == null) return null;
        return activityFromFirestore(snap.id, snap.data()!);
      });
}
