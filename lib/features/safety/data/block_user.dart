import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// `users/{uid}.blockedUserIds` — users hidden from feed, chats, joins.
Stream<List<String>> watchBlockedUserIds() {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    return Stream<List<String>>.value(const []);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((snap) {
        final raw = snap.data()?['blockedUserIds'];
        if (raw is! List) return const <String>[];
        return raw.map((e) => e.toString()).where((id) => id.isNotEmpty).toList();
      });
}

Future<void> blockUser(String blockedUid) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw StateError('Sign in to block someone.');
  }
  if (blockedUid.isEmpty || blockedUid == user.uid) {
    throw StateError('Cannot block this account.');
  }

  await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
    {
      'blockedUserIds': FieldValue.arrayUnion([blockedUid]),
    },
    SetOptions(merge: true),
  );
}

Future<void> unblockUser(String blockedUid) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
    {
      'blockedUserIds': FieldValue.arrayRemove([blockedUid]),
    },
    SetOptions(merge: true),
  );
}

bool isUserBlocked(List<String> blockedIds, String? uid) {
  if (uid == null || uid.isEmpty) return false;
  return blockedIds.contains(uid);
}
