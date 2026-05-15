import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../profile/domain/user_profile.dart';
import '../../safety/data/block_user.dart';

/// Prefix search on `searchNameLower` (set at registration).
Future<List<({String uid, UserProfile profile})>> searchUsersByName(
  String query, {
  int limit = 20,
}) async {
  final self = FirebaseAuth.instance.currentUser?.uid;
  if (self == null) return const [];

  final normalized = query.trim().toLowerCase();
  if (normalized.length < 2) return const [];

  final blockedSnap =
      await FirebaseFirestore.instance.collection('users').doc(self).get();
  final blocked = List<String>.from(
    (blockedSnap.data()?['blockedUserIds'] as List<dynamic>?)
            ?.map((e) => e.toString()) ??
        const [],
  );

  final end = '$normalized\uf8ff';
  final snap = await FirebaseFirestore.instance
      .collection('users')
      .where('searchNameLower', isGreaterThanOrEqualTo: normalized)
      .where('searchNameLower', isLessThanOrEqualTo: end)
      .limit(limit)
      .get();

  final results = <({String uid, UserProfile profile})>[];
  for (final doc in snap.docs) {
    if (doc.id == self) continue;
    if (isUserBlocked(blocked, doc.id)) continue;
    final data = doc.data();
    results.add((
      uid: doc.id,
      profile: UserProfile.fromFirestoreMap(data),
    ));
  }
  return results;
}

String buildSearchNameLower(String? firstName, String? lastName) {
  return '${firstName ?? ''} ${lastName ?? ''}'.trim().toLowerCase();
}
