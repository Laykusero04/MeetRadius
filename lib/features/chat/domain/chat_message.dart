import 'package:cloud_firestore/cloud_firestore.dart';

/// Stored in Firestore on `messages` docs as `eventKind`.
const String kChatEventKindMemberLeft = 'member_left';
const String kChatEventKindActivityEnded = 'activity_ended';
const String kChatEventKindMemberJoined = 'member_joined';
const String kChatEventKindMemberCheckedIn = 'member_checked_in';

/// Snapshot of a message being replied to (stored on the new message doc).
class ChatReplySnapshot {
  const ChatReplySnapshot({
    required this.messageId,
    required this.textSnippet,
    required this.senderDisplayName,
  });

  final String messageId;
  final String textSnippet;
  final String senderDisplayName;

  factory ChatReplySnapshot.fromMessage(ChatMessage m) {
    var snippet = m.text.trim();
    if (snippet.length > 80) {
      snippet = '${snippet.substring(0, 80)}…';
    }
    if (snippet.isEmpty) snippet = 'Message';
    return ChatReplySnapshot(
      messageId: m.id,
      textSnippet: snippet,
      senderDisplayName: m.senderDisplayName,
    );
  }
}

/// One row under `activities/{activityId}/messages/{messageId}`.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.senderUid,
    required this.senderDisplayName,
    required this.createdAt,
    this.eventKind,
    this.replyToMessageId,
    this.replyToText,
    this.replyToSenderDisplayName,
  });

  final String id;
  final String text;
  final String senderUid;
  final String senderDisplayName;
  final DateTime createdAt;

  /// When set (e.g. `member_left`), UI shows a Messenger-style system line, not a bubble.
  final String? eventKind;

  /// Reply target (optional).
  final String? replyToMessageId;
  final String? replyToText;
  final String? replyToSenderDisplayName;

  bool get isMemberLeftEvent => eventKind == kChatEventKindMemberLeft;

  bool get isSystemEvent =>
      eventKind == kChatEventKindMemberLeft ||
      eventKind == kChatEventKindActivityEnded ||
      eventKind == kChatEventKindMemberJoined ||
      eventKind == kChatEventKindMemberCheckedIn;

  bool get hasReply =>
      replyToMessageId != null &&
      replyToMessageId!.isNotEmpty &&
      (replyToText != null && replyToText!.trim().isNotEmpty);

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
      eventKind: data['eventKind'] as String?,
      replyToMessageId: data['replyToMessageId'] as String?,
      replyToText: data['replyToText'] as String?,
      replyToSenderDisplayName: data['replyToSenderDisplayName'] as String?,
    );
  }
}
