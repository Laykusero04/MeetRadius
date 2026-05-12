import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/user_profile.dart';

/// Live `users/{uid}` from Firestore when present; otherwise auth-only [UserProfile].
Stream<UserProfile?> watchCurrentUserProfile() {
  return FirebaseAuth.instance.userChanges().asyncExpand((user) {
    if (user == null) return Stream<UserProfile?>.value(null);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((snap) {
      if (snap.exists && snap.data() != null) {
        final fromDoc = UserProfile.fromFirestoreMap(snap.data()!);
        final email = fromDoc.email.isNotEmpty ? fromDoc.email : (user.email?.trim() ?? '');
        return UserProfile(
          email: email,
          firstName: fromDoc.firstName,
          lastName: fromDoc.lastName,
          createdAt: fromDoc.createdAt ?? user.metadata.creationTime,
        );
      }
      return UserProfile.fromAuthUser(user);
    });
  });
}
