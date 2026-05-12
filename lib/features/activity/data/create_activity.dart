import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../map/data/activity_geo.dart';

/// Persists a new document under `activities/{autoId}` for the signed-in host.
///
/// Firestore rules must allow: authenticated create with `hostUid == request.auth.uid`,
/// and reads for the feed. Example:
/// `match /activities/{id} { allow read: if request.auth != null; allow create: if request.auth != null && request.resource.data.hostUid == request.auth.uid; allow update: if request.auth != null; }`
/// Tighten `update` for production (e.g. only `memberIds` / `joinedCount` changes for joins).
Future<void> createActivity({
  required String title,
  required String spot,
  required String category,
  required int capacity,
  required bool isLive,
  required DateTime startsAt,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw StateError('You must be signed in to post an activity.');
  }

  final pin = ActivityGeo.randomNearDavao();
  final doc = FirebaseFirestore.instance.collection('activities').doc();

  await doc.set({
    'title': title,
    'spot': spot,
    'category': category,
    'capacity': capacity,
    'joinedCount': 1,
    'memberIds': <String>[user.uid],
    'isLive': isLive,
    'startsAt': Timestamp.fromDate(startsAt),
    'hostUid': user.uid,
    if (user.email != null) 'hostEmail': user.email,
    'createdAt': FieldValue.serverTimestamp(),
    'latitude': pin.latitude,
    'longitude': pin.longitude,
  });
}
