import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../chat/data/send_activity_message.dart';
import '../../chat/domain/chat_message.dart' show kChatEventKindActivityEnded;
import '../../notifications/data/create_notification.dart';

/// Writes end fields + system chat line inside an existing transaction.
void applyActivityEndInTransaction({
  required Transaction txn,
  required DocumentReference<Map<String, dynamic>> activityRef,
  required Map<String, dynamic> activityData,
  required User user,
  required String systemMessageText,
}) {
  if (activityData['endedAt'] != null) return;

  final built = buildActivityChatMessageFields(
    user: user,
    text: systemMessageText,
    eventKind: kChatEventKindActivityEnded,
  );
  final msgRef = activityRef.collection('messages').doc();

  txn.set(msgRef, built.messageFields);
  txn.update(activityRef, {
    'isLive': false,
    'endedAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
    'lastMessagePreview': built.preview,
    'lastMessageAt': FieldValue.serverTimestamp(),
  });
}

/// Notifies members after an activity ends (call after transaction commits).
Future<void> notifyMembersActivityEnded({
  required Map<String, dynamic> activityData,
  required String activityId,
}) async {
  final members = List<String>.from(
    (activityData['memberIds'] as List<dynamic>?)?.map((e) => e.toString()) ??
        const [],
  );
  final title = (activityData['title'] as String?)?.trim();
  final activityTitle =
      title != null && title.isNotEmpty ? title : 'Activity';
  await notifyActivityMembers(
    activityId: activityId,
    activityTitle: activityTitle,
    memberIds: members,
    type: 'activity_ended',
    body: 'This activity has ended.',
    excludeUid: '',
    openChat: true,
  );
}
