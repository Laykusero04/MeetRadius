import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import '../../chat/data/post_activity_system_message.dart';
import '../../chat/domain/chat_message.dart' show kChatEventKindMemberCheckedIn;
import '../../notifications/data/create_notification.dart';
import '../domain/activity.dart';
import '../domain/activity_check_in.dart';

/// Verifies GPS proximity and appends the user to [Activity.checkedInMemberIds].
Future<void> checkInToActivity(Activity activity) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw StateError('Sign in to check in.');
  }
  final uid = user.uid;

  if (!activityCanCheckIn(activity, uid)) {
    throw StateError('Check-in is not available for this activity right now.');
  }

  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw StateError('Turn on location services to check in.');
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    throw StateError('Location permission is required to check in.');
  }

  final position = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 20),
    ),
  );

  if (!isWithinCheckInGeofence(
    activity,
    position.latitude,
    position.longitude,
  )) {
    final meters = distanceToActivityMeters(
      activity,
      position.latitude,
      position.longitude,
    );
    final m = meters?.round() ?? 0;
    throw StateError(
      'You are about ${m}m away. Move within ${kCheckInGeofenceMeters.round()}m of the meeting spot.',
    );
  }

  final ref =
      FirebaseFirestore.instance.collection('activities').doc(activity.id);

  await FirebaseFirestore.instance.runTransaction((txn) async {
    final snap = await txn.get(ref);
    if (!snap.exists) {
      throw StateError('This activity no longer exists.');
    }
    final data = snap.data()!;
    final members = List<String>.from(
      (data['memberIds'] as List<dynamic>?)?.map((e) => e.toString()) ?? const [],
    );
    if (!members.contains(uid)) {
      throw StateError('Join this activity before checking in.');
    }

    final checked = List<String>.from(
      (data['checkedInMemberIds'] as List<dynamic>?)
              ?.map((e) => e.toString()) ??
          const [],
    );
    if (checked.contains(uid)) {
      throw StateError('You already checked in.');
    }
    checked.add(uid);
    txn.update(ref, {
      'checkedInMemberIds': checked,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  });

  final displayName = user.displayName?.trim().isNotEmpty == true
      ? user.displayName!.trim()
      : (user.email ?? 'Member');
  await postActivitySystemMessage(
    activityId: activity.id,
    text: '$displayName checked in at the meeting spot.',
    eventKind: kChatEventKindMemberCheckedIn,
  );

  final hostUid = activity.hostUid;
  if (hostUid.isNotEmpty && hostUid != uid) {
    final title = activity.title.trim();
    final activityTitle = title.isNotEmpty ? title : 'Activity';
    await createAppNotification(
      recipientUid: hostUid,
      type: 'check_in',
      activityId: activity.id,
      activityTitle: activityTitle,
      body: '$displayName checked in.',
    );
  }
}
