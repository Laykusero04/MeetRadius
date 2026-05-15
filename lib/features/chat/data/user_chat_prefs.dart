import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Per-user chat preferences on `users/{uid}`.
class UserChatPrefs {
  const UserChatPrefs({
    this.mutedActivityIds = const [],
    this.chatReadAt = const {},
    this.notifyChat = true,
  });

  final List<String> mutedActivityIds;
  final Map<String, DateTime> chatReadAt;
  final bool notifyChat;

  bool isActivityMuted(String activityId) =>
      mutedActivityIds.contains(activityId);

  bool isThreadUnread(String activityId, DateTime? lastMessageAt) {
    if (lastMessageAt == null) return false;
    final readAt = chatReadAt[activityId];
    if (readAt == null) return true;
    return lastMessageAt.isAfter(readAt);
  }
}

UserChatPrefs userChatPrefsFromFirestore(Map<String, dynamic>? data) {
  if (data == null) return const UserChatPrefs();

  final mutedRaw = data['mutedActivityIds'];
  final muted = mutedRaw is List
      ? mutedRaw.map((e) => e.toString()).where((id) => id.isNotEmpty).toList()
      : const <String>[];

  final readMap = <String, DateTime>{};
  final readRaw = data['chatReadAt'];
  if (readRaw is Map) {
    for (final entry in readRaw.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      if (value is Timestamp) {
        readMap[key] = value.toDate();
      }
    }
  }

  final notifyChat = data['notifyChat'] as bool? ?? true;

  return UserChatPrefs(
    mutedActivityIds: muted,
    chatReadAt: readMap,
    notifyChat: notifyChat,
  );
}

Stream<UserChatPrefs> watchUserChatPrefs() {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    return Stream<UserChatPrefs>.value(const UserChatPrefs());
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((snap) => userChatPrefsFromFirestore(snap.data()));
}

/// Writes device notification toggles to Firestore for server-side delivery rules.
Future<void> syncNotificationPrefsToFirestore({
  required bool notifyChat,
  required bool notifyActivity,
  required bool notifyLiveNearby,
}) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  await FirebaseFirestore.instance.collection('users').doc(uid).set(
    {
      'notifyChat': notifyChat,
      'notifyActivity': notifyActivity,
      'notifyLiveNearby': notifyLiveNearby,
      'updatedAt': FieldValue.serverTimestamp(),
    },
    SetOptions(merge: true),
  );
}

/// Loads recipient prefs once (used before fan-out chat notifications).
Future<UserChatPrefs> fetchUserChatPrefs(String uid) async {
  if (uid.isEmpty) return const UserChatPrefs();
  final snap =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  return userChatPrefsFromFirestore(snap.data());
}

/// Whether [recipientUid] should get a chat notification for [activityId].
Future<bool> shouldNotifyUserForChat(
  String recipientUid,
  String activityId,
) async {
  if (recipientUid.isEmpty || activityId.isEmpty) return false;
  final prefs = await fetchUserChatPrefs(recipientUid);
  if (!prefs.notifyChat) return false;
  if (prefs.isActivityMuted(activityId)) return false;
  return true;
}
