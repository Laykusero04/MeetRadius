import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'apply_activity_end.dart';

/// Ends an activity the current user hosts: not live, hidden from feed/map.
/// Chat thread stays open for existing members.
Future<void> endActivity(String activityId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw StateError('You must be signed in to end an activity.');
  }

  final ref =
      FirebaseFirestore.instance.collection('activities').doc(activityId);

  await FirebaseFirestore.instance.runTransaction((txn) async {
    final snap = await txn.get(ref);
    if (!snap.exists) {
      throw StateError('This activity no longer exists.');
    }
    final data = snap.data()!;
    if (data['hostUid'] != user.uid) {
      throw StateError('Only the host can end this activity.');
    }
    if (data['endedAt'] != null) {
      throw StateError('This activity has already ended.');
    }

    final displayName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : (user.email ?? 'Host');
    applyActivityEndInTransaction(
      txn: txn,
      activityRef: ref,
      activityData: data,
      user: user,
      systemMessageText: '$displayName ended the activity.',
    );
  });

  final after = await ref.get();
  if (after.exists) {
    await notifyMembersActivityEnded(
      activityData: after.data()!,
      activityId: activityId,
    );
  }
}
