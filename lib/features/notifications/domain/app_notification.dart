import 'package:cloud_firestore/cloud_firestore.dart';

/// In-app alert stored at `users/{uid}/notifications/{id}`.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.activityId,
    required this.activityTitle,
    required this.body,
    required this.createdAt,
    this.openChat = false,
    this.read = false,
  });

  final String id;
  final String type;
  final String activityId;
  final String activityTitle;
  final String body;
  final DateTime createdAt;
  final bool openChat;
  final bool read;

  static AppNotification fromFirestore(String id, Map<String, dynamic> data) {
    final created = data['createdAt'];
    var createdAt = DateTime.now();
    if (created is Timestamp) createdAt = created.toDate();

    return AppNotification(
      id: id,
      type: (data['type'] as String?) ?? 'generic',
      activityId: (data['activityId'] as String?) ?? '',
      activityTitle: (data['activityTitle'] as String?) ?? 'Activity',
      body: (data['body'] as String?) ?? '',
      createdAt: createdAt,
      openChat: data['openChat'] as bool? ?? false,
      read: data['read'] as bool? ?? false,
    );
  }
}
