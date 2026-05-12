import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore-backed activity shown on the feed and created from Host.
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

  factory Activity.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final starts = d['startsAt'];
    DateTime startsAt;
    if (starts is Timestamp) {
      startsAt = starts.toDate();
    } else {
      startsAt = DateTime.now();
    }
    final lastAt = d['lastMessageAt'];
    DateTime? lastMessageAt;
    if (lastAt is Timestamp) {
      lastMessageAt = lastAt.toDate();
    }
    return Activity(
      id: doc.id,
      title: d['title'] as String? ?? '',
      spot: d['spot'] as String? ?? '',
      category: d['category'] as String? ?? 'Other',
      capacity: (d['capacity'] as num?)?.toInt() ?? 6,
      joinedCount: (d['joinedCount'] as num?)?.toInt() ?? 1,
      isLive: d['isLive'] as bool? ?? false,
      startsAt: startsAt,
      hostUid: d['hostUid'] as String? ?? '',
      hostEmail: d['hostEmail'] as String?,
      lastMessagePreview: d['lastMessagePreview'] as String?,
      lastMessageAt: lastMessageAt,
      latitude: (d['latitude'] as num?)?.toDouble(),
      longitude: (d['longitude'] as num?)?.toDouble(),
    );
  }

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
