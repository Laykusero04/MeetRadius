/// Activity shown on the feed / map / chats.
class Activity {
  const Activity({
    required this.id,
    required this.title,
    required this.spot,
    required this.category,
    required this.capacity,
    required this.joinedCount,
    required this.isLive,
    required this.startsAt,
    required this.hostUid,
    this.hostEmail,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.latitude,
    this.longitude,
    this.memberIds = const [],
  });

  final String id;
  final String title;
  final String spot;
  final String category;
  final int capacity;
  final int joinedCount;
  final bool isLive;
  final DateTime startsAt;
  final String hostUid;
  final String? hostEmail;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final double? latitude;
  final double? longitude;
  final List<String> memberIds;

  bool matchesFeedChip(int chipIndex) {
    if (chipIndex <= 0) return true;
    final label = _chipIndexToCategory(chipIndex);
    if (label == null) return true;
    return category == label;
  }

  static String? _chipIndexToCategory(int chipIndex) {
    return switch (chipIndex) {
      1 => 'Sports',
      2 => 'Social',
      3 => 'Outdoor',
      _ => null,
    };
  }
}
