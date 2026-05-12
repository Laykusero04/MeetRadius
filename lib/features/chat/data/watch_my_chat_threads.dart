import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../activity/data/activity_from_firestore.dart';
import '../../activity/domain/activity.dart';

/// Activities where the current user is in [Activity.memberIds] (host or joined).
Stream<List<Activity>> watchMyChatThreads() {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    return Stream<List<Activity>>.value(const []);
  }

  return FirebaseFirestore.instance
      .collection('activities')
      .where('memberIds', arrayContains: uid)
      .snapshots()
      .map((snap) {
    final list = snap.docs
        .map((d) => activityFromFirestore(d.id, d.data()))
        .toList();
    list.sort((a, b) {
      final ta = a.lastMessageAt ?? a.startsAt;
      final tb = b.lastMessageAt ?? b.startsAt;
      return tb.compareTo(ta);
    });
    return list;
  });
}
