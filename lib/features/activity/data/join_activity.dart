import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Increments [joinedCount] if below [capacity] (atomic via transaction).
/// Adds the current user to [participantIds] so they appear in activity chats.
Future<void> joinActivity(String activityId) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    throw StateError('Sign in to join an activity.');
  }

  final ref = FirebaseFirestore.instance.collection('activities').doc(activityId);

  await FirebaseFirestore.instance.runTransaction((tx) async {
    final snap = await tx.get(ref);
    if (!snap.exists) {
      throw StateError('This activity is no longer available.');
    }
    final data = snap.data()!;
    final capacity = (data['capacity'] as num?)?.toInt() ?? 0;
    final joined = (data['joinedCount'] as num?)?.toInt() ?? 0;
    if (joined >= capacity) {
      throw StateError('This activity is already full.');
    }
    tx.update(ref, {
      'joinedCount': joined + 1,
      'participantIds': FieldValue.arrayUnion([uid]),
    });
  });
}
