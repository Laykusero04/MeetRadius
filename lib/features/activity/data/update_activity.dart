import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Updates an existing activity. Only the host (`hostUid`) may update.
///
/// Firestore rules should restrict updates, e.g. only when
/// `resource.data.hostUid == request.auth.uid`.
Future<void> updateActivity({
  required String activityId,
  required String title,
  required String spot,
  required double latitude,
  required double longitude,
  required String category,
  required int minCapacity,
  required int capacity,
  required bool capacityUnlimited,
  required bool isLive,
  required DateTime startsAt,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw StateError('You must be signed in to edit an activity.');
  }
  final ref = FirebaseFirestore.instance
      .collection('activities')
      .doc(activityId);
  await FirebaseFirestore.instance.runTransaction((txn) async {
    final snap = await txn.get(ref);
    if (!snap.exists) {
      throw StateError('This activity no longer exists.');
    }
    final data = snap.data()!;
    if (data['hostUid'] != user.uid) {
      throw StateError('Only the host can edit this activity.');
    }
    final joined = (data['joinedCount'] as num?)?.toInt() ?? 0;
    if (minCapacity < 2 || minCapacity > 30) {
      throw StateError('Minimum attendees must be between 2 and 30.');
    }
    if (!capacityUnlimited) {
      if (capacity < joined) {
        throw StateError(
          'Max attendees cannot be below how many people already joined ($joined).',
        );
      }
      if (capacity < minCapacity) {
        throw StateError(
          'Max attendees must be at least your minimum ($minCapacity).',
        );
      }
    }
    txn.update(ref, {
      'title': title,
      'spot': spot,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'minCapacity': minCapacity,
      'capacity': capacity,
      'capacityUnlimited': capacityUnlimited,
      'isLive': isLive,
      'startsAt': Timestamp.fromDate(startsAt),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  });
}
