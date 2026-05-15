import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'send_activity_message.dart';

/// Appends a centered system line to an activity thread (join, check-in, etc.).
Future<void> postActivitySystemMessage({
  required String activityId,
  required String text,
  required String eventKind,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final trimmed = text.trim();
  if (trimmed.isEmpty) return;

  final built = buildActivityChatMessageFields(
    user: user,
    text: trimmed,
    eventKind: eventKind,
  );

  final batch = FirebaseFirestore.instance.batch();
  final activityRef =
      FirebaseFirestore.instance.collection('activities').doc(activityId);
  final msgRef = activityRef.collection('messages').doc();

  batch.set(msgRef, built.messageFields);
  batch.update(activityRef, {
    'lastMessagePreview': built.preview,
    'lastMessageAt': FieldValue.serverTimestamp(),
  });
  await batch.commit();
}
