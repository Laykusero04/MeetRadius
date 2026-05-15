import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Toggles mute for an activity thread (`users/{uid}.mutedActivityIds`).
Future<void> setActivityChatMuted({
  required String activityId,
  required bool muted,
}) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    throw StateError('Sign in to change mute settings.');
  }
  if (activityId.isEmpty) {
    throw StateError('Invalid activity.');
  }

  final ref = FirebaseFirestore.instance.collection('users').doc(uid);
  await ref.set(
    {
      if (muted)
        'mutedActivityIds': FieldValue.arrayUnion([activityId])
      else
        'mutedActivityIds': FieldValue.arrayRemove([activityId]),
    },
    SetOptions(merge: true),
  );
}
