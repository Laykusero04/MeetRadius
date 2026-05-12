import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Appends a document to `activities/{activityId}/messages` and updates
/// [lastMessagePreview] / [lastMessageAt] on the parent activity.
Future<void> sendActivityMessage({
  required String activityId,
  required String text,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw StateError('Sign in to send a message.');
  }
  final trimmed = text.trim();
  if (trimmed.isEmpty) return;

  var label = user.email?.split('@').first ?? user.uid;
  if (label.length > 24) label = label.substring(0, 24);

  var preview = '$label: $trimmed';
  if (preview.length > 140) preview = '${preview.substring(0, 137)}...';

  final batch = FirebaseFirestore.instance.batch();
  final msgRef = FirebaseFirestore.instance
      .collection('activities')
      .doc(activityId)
      .collection('messages')
      .doc();

  batch.set(msgRef, {
    'text': trimmed,
    'senderUid': user.uid,
    'senderLabel': label,
    if (user.email != null) 'senderEmail': user.email,
    'createdAt': FieldValue.serverTimestamp(),
  });

  final activityRef = FirebaseFirestore.instance.collection('activities').doc(activityId);
  batch.update(activityRef, {
    'lastMessagePreview': preview,
    'lastMessageAt': FieldValue.serverTimestamp(),
  });

  await batch.commit();
}
