import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/user_profile.dart';

/// Reads `users/{uid}` when the signed-in user may read it (depends on rules).
Future<UserProfile?> fetchPublicUserProfile(String uid) async {
  if (uid.isEmpty) return null;
  final snap =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  if (!snap.exists || snap.data() == null) return null;
  return UserProfile.fromFirestoreMap(snap.data()!);
}

/// Parallel fetch for a member list (best-effort; missing docs stay null).
Future<Map<String, UserProfile?>> fetchPublicUserProfiles(
  Iterable<String> uids,
) async {
  final unique = uids.toSet();
  if (unique.isEmpty) return {};
  final entries = await Future.wait(
    unique.map((uid) async {
      return MapEntry(uid, await fetchPublicUserProfile(uid));
    }),
  );
  return Map.fromEntries(entries);
}
