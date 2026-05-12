import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/chat_message.dart';

/// Chronological messages for one activity’s group chat.
Stream<List<ChatMessage>> watchActivityMessages(String activityId) {
  return FirebaseFirestore.instance
      .collection('activities')
      .doc(activityId)
      .collection('messages')
      .orderBy('createdAt', descending: false)
      .limit(200)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((d) => ChatMessage.fromFirestore(d.id, d.data()))
            .toList(),
      );
}
