import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/activity.dart';
import 'activity_from_firestore.dart';

/// Upcoming / live activities ordered by start time (newest window first).
Stream<List<Activity>> watchActivities() {
  return FirebaseFirestore.instance
      .collection('activities')
      .orderBy('startsAt', descending: false)
      .limit(100)
      .snapshots()
      .map((snap) {
    final out = <Activity>[];
    for (final d in snap.docs) {
      try {
        out.add(activityFromFirestore(d.id, d.data()));
      } catch (_) {
        // Skip malformed docs.
      }
    }
    return out.where((a) => a.isDiscoverable).toList();
  });
}
