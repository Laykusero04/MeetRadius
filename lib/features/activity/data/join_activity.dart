import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Adds the current user to `memberIds` and bumps `joinedCount` in a transaction.
Future<void> joinActivity(String activityId) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    throw StateError('Sign in to join an activity.');
  }

  final ref = FirebaseFirestore.instance.collection('activities').doc(activityId);

  await FirebaseFirestore.instance.runTransaction((txn) async {
    final snap = await txn.get(ref);
    if (!snap.exists) {
      throw StateError('This activity no longer exists.');
    }
    final data = snap.data()!;
    final hostUid = data['hostUid'] as String? ?? '';
    if (uid == hostUid) {
      return;
    }

    final unlimited = data['capacityUnlimited'] as bool? ?? false;
    final capacity = (data['capacity'] as num?)?.toInt() ?? 0;
    final rawMembers = data['memberIds'];
    final members = List<String>.from(
      rawMembers is List ? rawMembers : const <dynamic>[],
    );
    if (members.contains(uid)) {
      throw StateError('You already joined this activity.');
    }
    if (!unlimited && members.length >= capacity) {
      throw StateError('This activity is full.');
    }
    members.add(uid);
    txn.update(ref, {
      'memberIds': members,
      'joinedCount': members.length,
    });
  });
}
