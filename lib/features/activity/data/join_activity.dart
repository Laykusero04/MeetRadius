import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../chat/data/send_activity_message.dart';
import '../../chat/domain/chat_message.dart' show kChatEventKindMemberJoined;
import '../../notifications/data/create_notification.dart';
import '../../safety/data/block_user.dart';

/// Adds the current user to `memberIds` and bumps `joinedCount` in a transaction.
Future<void> joinActivity(String activityId) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    throw StateError('Sign in to join an activity.');
  }

  final ref = FirebaseFirestore.instance.collection('activities').doc(activityId);

  final pre = await ref.get();
  if (!pre.exists) {
    throw StateError('This activity no longer exists.');
  }
  final preData = pre.data()!;
  final hostUid = preData['hostUid'] as String? ?? '';
  if (uid != hostUid) {
    final blockedSnap =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final blocked = List<String>.from(
      (blockedSnap.data()?['blockedUserIds'] as List<dynamic>?)
              ?.map((e) => e.toString()) ??
          const [],
    );
    if (isUserBlocked(blocked, hostUid)) {
      throw StateError(
        'You blocked this host. Unblock them in Settings to join.',
      );
    }
  }

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw StateError('Sign in to join an activity.');
  }

  await FirebaseFirestore.instance.runTransaction((txn) async {
    final snap = await txn.get(ref);
    if (!snap.exists) {
      throw StateError('This activity no longer exists.');
    }
    final data = snap.data()!;
    if (data['endedAt'] != null) {
      throw StateError('This activity has ended.');
    }
    final ends = data['endsAt'];
    if (ends is Timestamp && !ends.toDate().isAfter(DateTime.now())) {
      throw StateError('This activity has ended.');
    }
    final txnHostUid = data['hostUid'] as String? ?? '';
    if (uid == txnHostUid) {
      return;
    }

    final unlimited = data['capacityUnlimited'] as bool? ?? false;
    final capacity = (data['capacity'] as num?)?.toInt() ?? 0;
    final rawMembers = data['memberIds'];
    final members = List<String>.from(
      rawMembers is List ? rawMembers : const <dynamic>[],
    );
    if (members.contains(uid)) {
      throw StateError('You already joined this activity.');
    }
    if (!unlimited && members.length >= capacity) {
      throw StateError('This activity is full.');
    }

    final displayName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : (user.email ?? 'Member');
    final built = buildActivityChatMessageFields(
      user: user,
      text: '$displayName joined the group.',
      eventKind: kChatEventKindMemberJoined,
    );
    final msgRef = ref.collection('messages').doc();

    members.add(uid);
    txn.set(msgRef, built.messageFields);
    txn.update(ref, {
      'memberIds': members,
      'joinedCount': members.length,
      'lastMessagePreview': built.preview,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  });

  final after = await ref.get();
  if (!after.exists) return;
  final d = after.data()!;
  final title = (d['title'] as String?)?.trim();
  final activityTitle =
      title != null && title.isNotEmpty ? title : 'Activity';
  final displayName = FirebaseAuth.instance.currentUser?.displayName?.trim();
  final who = displayName != null && displayName.isNotEmpty
      ? displayName
      : 'Someone';

  if (hostUid.isNotEmpty && hostUid != uid) {
    await createAppNotification(
      recipientUid: hostUid,
      type: 'join',
      activityId: activityId,
      activityTitle: activityTitle,
      body: '$who joined your activity.',
    );
  }
}
