import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Creates an Auth account and a profile document at `users/{email}`.
///
/// Document id is the normalized email (trimmed, lower case) so it matches
/// the address users type, with a single doc per mailbox.
Future<void> registerUserWithProfile({
  required String email,
  required String password,
}) async {
  final normalizedEmail = email.trim().toLowerCase();

  final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: normalizedEmail,
    password: password,
  );

  final uid = credential.user?.uid;
  if (uid == null) {
    throw StateError('Registration succeeded but user uid is null.');
  }

  await FirebaseFirestore.instance.collection('users').doc(normalizedEmail).set({
    'email': normalizedEmail,
    'uid': uid,
    'createdAt': FieldValue.serverTimestamp(),
  });
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
