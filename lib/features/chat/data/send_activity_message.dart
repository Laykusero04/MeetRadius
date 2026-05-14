import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/chat_message.dart' show ChatReplySnapshot, kChatEventKindMemberLeft;

/// Subcollection message fields plus [lastMessagePreview] for the activity doc.
/// Use with [WriteBatch] / [Transaction] (same shape as user-sent lines).
///
/// Set [eventKind] to [kChatEventKindMemberLeft] for Messenger-style system lines
/// (centered, no bubble in the chat UI).
({Map<String, dynamic> messageFields, String preview}) buildActivityChatMessageFields({
  required User user,
  required String text,
  String? eventKind,
  ChatReplySnapshot? replyTo,
}) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError.value(text, 'text', 'must not be empty');
  }
  var preview =
      trimmed.length > 120 ? '${trimmed.substring(0, 120)}…' : trimmed;
  if (replyTo != null) {
    final prefix = 'Re: ';
    preview = '$prefix$preview';
    if (preview.length > 120) {
      preview = '${preview.substring(0, 120)}…';
    }
  }
  final displayName = user.displayName?.trim().isNotEmpty == true
      ? user.displayName!.trim()
      : (user.email ?? 'Member');
  return (
    messageFields: <String, dynamic>{
      'text': trimmed,
      'senderUid': user.uid,
      'senderDisplayName': displayName,
      'createdAt': FieldValue.serverTimestamp(),
      if (eventKind != null) 'eventKind': eventKind,
      if (replyTo != null) ...{
        'replyToMessageId': replyTo.messageId,
        'replyToText': replyTo.textSnippet,
        'replyToSenderDisplayName': replyTo.senderDisplayName,
      },
    },
    preview: preview,
  );
}

/// Appends a doc to `activities/{activityId}/messages` and updates thread preview on the activity.
Future<void> sendActivityMessage({
  required String activityId,
  required String text,
  ChatReplySnapshot? replyTo,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw StateError('Sign in to send a message.');
  }
  final trimmed = text.trim();
  if (trimmed.isEmpty) {
    return;
  }

  final built = buildActivityChatMessageFields(
    user: user,
    text: trimmed,
    replyTo: replyTo,
  );

  final batch = FirebaseFirestore.instance.batch();
  final msgRef = FirebaseFirestore.instance
      .collection('activities')
      .doc(activityId)
      .collection('messages')
      .doc();

  batch.set(msgRef, built.messageFields);

  batch.update(
    FirebaseFirestore.instance.collection('activities').doc(activityId),
    {
      'lastMessagePreview': built.preview,
      'lastMessageAt': FieldValue.serverTimestamp(),
    },
  );

  await batch.commit();
}
