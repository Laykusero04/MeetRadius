import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Appends a doc to `activities/{activityId}/messages` and updates thread preview on the activity.
Future<void> sendActivityMessage({
  required String activityId,
  required String text,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw StateError('Sign in to send a message.');
  }
  final trimmed = text.trim();
  if (trimmed.isEmpty) {
    return;
  }

  final preview = trimmed.length > 120 ? '${trimmed.substring(0, 120)}…' : trimmed;
  final displayName = user.displayName?.trim().isNotEmpty == true
      ? user.displayName!.trim()
      : (user.email ?? 'Member');

  final batch = FirebaseFirestore.instance.batch();
  final msgRef = FirebaseFirestore.instance
      .collection('activities')
      .doc(activityId)
      .collection('messages')
      .doc();

  batch.set(msgRef, {
    'text': trimmed,
    'senderUid': user.uid,
    'senderDisplayName': displayName,
    'createdAt': FieldValue.serverTimestamp(),
  });

  batch.update(
    FirebaseFirestore.instance.collection('activities').doc(activityId),
    {
      'lastMessagePreview': preview,
      'lastMessageAt': FieldValue.serverTimestamp(),
    },
  );

  await batch.commit();
}
