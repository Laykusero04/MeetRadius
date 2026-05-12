import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../map/data/activity_geo.dart';

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

  await FirebaseFirestore.instance.collection('activities').add({
    'title': title.trim(),
    'spot': spot.trim(),
    'category': category,
    'capacity': capacity,
    'joinedCount': 1,
    'isLive': isLive,
    'startsAt': Timestamp.fromDate(startsAt),
    'hostUid': user.uid,
    if (user.email != null) 'hostEmail': user.email,
    'createdAt': FieldValue.serverTimestamp(),
    'participantIds': [user.uid],
    'latitude': pin.latitude,
    'longitude': pin.longitude,
  });
}
