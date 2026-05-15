import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/activity.dart';

Activity activityFromFirestore(String id, Map<String, dynamic> data) {
  final starts = data['startsAt'];
  final DateTime startsAt = starts is Timestamp
      ? starts.toDate()
      : DateTime.now();

  final lastMsg = data['lastMessageAt'];
  DateTime? lastMessageAt;
  if (lastMsg is Timestamp) {
    lastMessageAt = lastMsg.toDate();
  }

  final ended = data['endedAt'];
  DateTime? endedAt;
  if (ended is Timestamp) {
    endedAt = ended.toDate();
  }

  final ends = data['endsAt'];
  DateTime? endsAt;
  if (ends is Timestamp) {
    endsAt = ends.toDate();
  }

  return Activity(
    id: id,
    title: (data['title'] as String?) ?? '',
    spot: (data['spot'] as String?) ?? '',
    category: (data['category'] as String?) ?? 'Other',
    capacity: (data['capacity'] as num?)?.toInt() ?? 6,
    joinedCount: (data['joinedCount'] as num?)?.toInt() ?? 0,
    capacityUnlimited: data['capacityUnlimited'] as bool? ?? false,
    isLive: data['isLive'] as bool? ?? false,
    startsAt: startsAt,
    endsAt: endsAt,
    endedAt: endedAt,
    hostUid: (data['hostUid'] as String?) ?? '',
    hostEmail: data['hostEmail'] as String?,
    lastMessagePreview: data['lastMessagePreview'] as String?,
    lastMessageAt: lastMessageAt,
    latitude: (data['latitude'] as num?)?.toDouble(),
    longitude: (data['longitude'] as num?)?.toDouble(),
    memberIds: List<String>.from(
      (data['memberIds'] as List<dynamic>?)?.map((e) => e.toString()) ?? const [],
    ),
    checkedInMemberIds: List<String>.from(
      (data['checkedInMemberIds'] as List<dynamic>?)
              ?.map((e) => e.toString()) ??
          const [],
    ),
  );
}
