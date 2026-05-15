import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../social/data/search_users_by_name.dart';

/// Creates a Firebase Auth account, sets [User.displayName], and writes `users/{uid}` in Firestore.
Future<void> registerUserWithProfile({
  required String email,
  required String password,
  required String firstName,
  required String lastName,
}) async {
  final normalizedEmail = email.trim().toLowerCase();
  final trimmedFirst = firstName.trim();
  final trimmedLast = lastName.trim();

  final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: normalizedEmail,
    password: password,
  );

  final user = credential.user;
  if (user == null) {
    throw StateError('Registration succeeded but user is null.');
  }

  final fullName = '$trimmedFirst $trimmedLast'.trim();
  if (fullName.isNotEmpty) {
    try {
      await user.updateDisplayName(fullName);
    } catch (e) {
      debugPrint('MeetRadius: updateDisplayName failed (non-fatal): $e');
    }
  }

  try {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'email': normalizedEmail,
      'firstName': trimmedFirst,
      'lastName': trimmedLast,
      'searchNameLower': buildSearchNameLower(trimmedFirst, trimmedLast),
      'notifyChat': true,
      'notifyActivity': true,
      'notifyLiveNearby': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    try {
      await user.delete();
    } catch (_) {
      // Best-effort cleanup; original error is more important.
    }
    rethrow;
  }
}

String messageForAuthException(FirebaseAuthException e) {
  switch (e.code) {
    case 'email-already-in-use':
      return 'That email is already registered.';
    case 'invalid-email':
      return 'That email address is not valid.';
    case 'weak-password':
      return 'Password is too weak. Use at least 6 characters.';
    case 'operation-not-allowed':
      return 'Email/password sign-in is not enabled in Firebase.';
    default:
      return e.message?.isNotEmpty == true ? e.message! : 'Sign up failed (${e.code}).';
  }
}
