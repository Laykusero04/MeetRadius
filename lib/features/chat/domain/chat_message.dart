import 'package:cloud_firestore/cloud_firestore.dart';

/// One row under `activities/{activityId}/messages/{messageId}`.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.senderUid,
    required this.senderDisplayName,
    required this.createdAt,
  });

  final String id;
  final String text;
  final String senderUid;
  final String senderDisplayName;
  final DateTime createdAt;

  factory ChatMessage.fromFirestore(String id, Map<String, dynamic> data) {
    final c = data['createdAt'];
    var created = DateTime.now();
    if (c is Timestamp) {
      created = c.toDate();
    }
    return ChatMessage(
      id: id,
      text: (data['text'] as String?) ?? '',
      senderUid: (data['senderUid'] as String?) ?? '',
      senderDisplayName: (data['senderDisplayName'] as String?) ?? 'Member',
      createdAt: created,
    );
  }
}
