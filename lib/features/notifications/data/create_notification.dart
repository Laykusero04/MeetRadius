import 'package:cloud_firestore/cloud_firestore.dart';

import '../../chat/data/user_chat_prefs.dart';

/// Writes one in-app notification for [recipientUid] (best-effort).
Future<void> createAppNotification({
  required String recipientUid,
  required String type,
  required String activityId,
  required String activityTitle,
  required String body,
  bool openChat = false,
}) async {
  if (recipientUid.isEmpty || activityId.isEmpty) return;

  final ref = FirebaseFirestore.instance
      .collection('users')
      .doc(recipientUid)
      .collection('notifications')
      .doc();

  await ref.set({
    'type': type,
    'activityId': activityId,
    'activityTitle': activityTitle,
    'body': body,
    'openChat': openChat,
    'read': false,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

/// Notifies all activity members except [excludeUid].
Future<void> notifyActivityMembers({
  required String activityId,
  required String activityTitle,
  required List<String> memberIds,
  required String type,
  required String body,
  required String excludeUid,
  bool openChat = false,
}) async {
  for (final uid in memberIds) {
    if (uid.isEmpty || uid == excludeUid) continue;
    if (type == 'chat' &&
        !await shouldNotifyUserForChat(uid, activityId)) {
      continue;
    }
    try {
      await createAppNotification(
        recipientUid: uid,
        type: type,
        activityId: activityId,
        activityTitle: activityTitle,
        body: body,
        openChat: openChat,
      );
    } catch (_) {
      // Best-effort per recipient.
    }
  }
}
