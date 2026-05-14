import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Persists a text post under `users/{uid}/textPosts` for future feed use.
Future<void> createTextPost({required String body}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw StateError('You must be signed in to post.');
  }
  final text = body.trim();
  if (text.isEmpty) {
    throw ArgumentError('Post cannot be empty.');
  }

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('textPosts')
      .add({
        'body': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
}
