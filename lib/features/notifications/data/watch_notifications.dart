import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/app_notification.dart';

/// Count of inbox items with `read: false`.
Stream<int> watchUnreadNotificationCount() {
  return watchNotifications().map(
    (list) => list.where((n) => !n.read).length,
  );
}

Stream<List<AppNotification>> watchNotifications() {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    return Stream<List<AppNotification>>.value(const []);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('notifications')
      .orderBy('createdAt', descending: true)
      .limit(80)
      .snapshots()
      .map((snap) {
        return snap.docs
            .map((d) => AppNotification.fromFirestore(d.id, d.data()))
            .toList();
      });
}

Future<void> markNotificationRead(String notificationId) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;
  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('notifications')
      .doc(notificationId)
      .update({'read': true});
}

/// Marks every unread notification in the inbox (up to 80).
Future<void> markAllNotificationsRead() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  final snap = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('notifications')
      .where('read', isEqualTo: false)
      .limit(80)
      .get();

  if (snap.docs.isEmpty) return;

  final batch = FirebaseFirestore.instance.batch();
  for (final doc in snap.docs) {
    batch.update(doc.reference, {'read': true});
  }
  await batch.commit();
}
