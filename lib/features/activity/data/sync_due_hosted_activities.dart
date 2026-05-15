import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/activity.dart';
import 'apply_activity_end.dart';

const _scheduledEndMessage = 'This activity reached its scheduled end.';

/// Persists [endedAt] for hosted activities whose [endsAt] has passed (client MVP).
Future<void> syncDueHostedActivities() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final snap = await FirebaseFirestore.instance
      .collection('activities')
      .where('hostUid', isEqualTo: user.uid)
      .limit(100)
      .get();

  final now = DateTime.now();
  for (final doc in snap.docs) {
    final data = doc.data();
    if (data['endedAt'] != null) continue;
    final ends = data['endsAt'];
    if (ends is! Timestamp) continue;
    if (ends.toDate().isAfter(now)) continue;

    await _endDueActivityDoc(doc.reference, user, now);
  }
}

/// Ends due hosted activities visible in the current feed/map list (best-effort).
Future<void> syncDueHostedActivitiesFromList(List<Activity> visible) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || visible.isEmpty) return;

  final now = DateTime.now();
  for (final activity in visible) {
    if (activity.hostUid != user.uid) continue;
    if (activity.isEnded) continue;
    final ends = activity.endsAt;
    if (ends == null || ends.isAfter(now)) continue;

    final ref = FirebaseFirestore.instance.collection('activities').doc(activity.id);
    await _endDueActivityDoc(ref, user, now);
  }
}

Future<void> _endDueActivityDoc(
  DocumentReference<Map<String, dynamic>> ref,
  User user,
  DateTime now,
) async {
  try {
    var ended = false;
    await FirebaseFirestore.instance.runTransaction((txn) async {
      final fresh = await txn.get(ref);
      if (!fresh.exists) return;
      final d = fresh.data()!;
      if (d['endedAt'] != null) return;
      final endsAt = d['endsAt'];
      if (endsAt is! Timestamp || endsAt.toDate().isAfter(now)) return;

      applyActivityEndInTransaction(
        txn: txn,
        activityRef: ref,
        activityData: d,
        user: user,
        systemMessageText: _scheduledEndMessage,
      );
      ended = true;
    });

    if (ended) {
      final after = await ref.get();
      if (after.exists) {
        await notifyMembersActivityEnded(
          activityData: after.data()!,
          activityId: ref.id,
        );
      }
    }
  } catch (_) {
    // Best-effort; next app open retries.
  }
}
