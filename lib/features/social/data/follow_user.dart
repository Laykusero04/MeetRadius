import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../safety/data/block_user.dart';

/// People you follow — shown as friends on activity cards (Strava-style).
Stream<List<String>> watchFollowingIds() {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    return Stream<List<String>>.value(const []);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((snap) {
        final raw = snap.data()?['followingIds'];
        if (raw is! List) return const <String>[];
        return raw
            .map((e) => e.toString())
            .where((id) => id.isNotEmpty)
            .toList();
      });
}

Set<String> followingIdsSet(List<String> ids) => ids.toSet();

Future<bool> isFollowingUser(String targetUid) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null || targetUid.isEmpty) return false;
  final snap =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  final raw = snap.data()?['followingIds'];
  if (raw is! List) return false;
  return raw.map((e) => e.toString()).contains(targetUid);
}

Future<void> followUser(String targetUid) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw StateError('Sign in to follow someone.');
  }
  if (targetUid.isEmpty || targetUid == user.uid) {
    throw StateError('Cannot follow this account.');
  }

  final blockedSnap =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  final blocked = List<String>.from(
    (blockedSnap.data()?['blockedUserIds'] as List<dynamic>?)
            ?.map((e) => e.toString()) ??
        const [],
  );
  if (isUserBlocked(blocked, targetUid)) {
    throw StateError('Unblock this person in Settings before following.');
  }

  await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
    {
      'followingIds': FieldValue.arrayUnion([targetUid]),
    },
    SetOptions(merge: true),
  );
}

Future<void> unfollowUser(String targetUid) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  if (targetUid.isEmpty) return;

  await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
    {
      'followingIds': FieldValue.arrayRemove([targetUid]),
    },
    SetOptions(merge: true),
  );
}
