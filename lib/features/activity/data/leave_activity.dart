import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../chat/data/send_activity_message.dart';
import '../../chat/domain/chat_message.dart' show kChatEventKindMemberLeft;

/// Removes the current user from `memberIds`, sets `joinedCount`, and appends a
/// Messenger-style system line (`… left the group.`) in one transaction.
/// The host cannot leave (they must delete or transfer hosting elsewhere).
Future<void> leaveActivity(String activityId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw StateError('Sign in to leave an activity.');
  }
  final uid = user.uid;

  final ref =
      FirebaseFirestore.instance.collection('activities').doc(activityId);

  await FirebaseFirestore.instance.runTransaction((txn) async {
    final snap = await txn.get(ref);
    if (!snap.exists) {
      throw StateError('This activity no longer exists.');
    }
    final data = snap.data()!;
    final hostUid = data['hostUid'] as String? ?? '';
    if (uid == hostUid) {
      throw StateError('Hosts cannot leave their own activity.');
    }

    final rawMembers = data['memberIds'];
    final members = List<String>.from(
      rawMembers is List ? rawMembers : const <dynamic>[],
    );
    if (!members.contains(uid)) {
      throw StateError('You are not in this activity.');
    }

    final displayName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : (user.email ?? 'Member');
    final built = buildActivityChatMessageFields(
      user: user,
      text: '$displayName left the group.',
      eventKind: kChatEventKindMemberLeft,
    );
    final msgRef = ref.collection('messages').doc();

    members.remove(uid);
    txn.set(msgRef, built.messageFields);
    txn.update(ref, {
      'memberIds': members,
      'joinedCount': members.length,
      'lastMessagePreview': built.preview,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  });
}
