import 'activity_categories.dart';

/// Activity shown on the feed / map / chats.
class Activity {
  const Activity({
    required this.id,
    required this.title,
    required this.spot,
    required this.category,
    required this.capacity,
    required this.joinedCount,
    this.capacityUnlimited = false,
    required this.isLive,
    required this.startsAt,
    this.endsAt,
    this.endedAt,
    required this.hostUid,
    this.hostEmail,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.latitude,
    this.longitude,
    this.memberIds = const [],
    this.checkedInMemberIds = const [],
  });

  final String id;
  final String title;
  final String spot;
  final String category;
  final int capacity;
  final int joinedCount;
  /// When true, [capacity] is not enforced for joins (open-ended group size).
  final bool capacityUnlimited;
  final bool isLive;
  final DateTime startsAt;
  /// Optional scheduled stop; host intent (see [endedAt] for actual stop).
  final DateTime? endsAt;
  /// When set, the activity is ended and hidden from feed/map discovery.
  final DateTime? endedAt;
  final String hostUid;

  bool get isEnded => endedAt != null;

  bool isPastScheduledEnd([DateTime? at]) {
    final e = endsAt;
    if (e == null || isEnded) return false;
    return !e.isAfter(at ?? DateTime.now());
  }

  bool get isOver => isEnded || isPastScheduledEnd();

  /// Visible on feed / map; joins allowed (subject to capacity).
  bool get isDiscoverable => !isOver;
  final String? hostEmail;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final double? latitude;
  final double? longitude;
  final List<String> memberIds;
  final List<String> checkedInMemberIds;

  bool hasCheckedIn(String uid) => checkedInMemberIds.contains(uid);

  bool matchesFeedChip(int chipIndex) {
    if (chipIndex <= 0 || chipIndex >= kFeedCategoryLabels.length) return true;
    return category == kFeedCategoryLabels[chipIndex];
  }
}
