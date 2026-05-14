import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Deletes an activity document. Only the host may delete.
///
/// Firestore rules should allow delete when `resource.data.hostUid == request.auth.uid`.
Future<void> deleteActivity(String activityId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw StateError('You must be signed in to delete an activity.');
  }
  final ref = FirebaseFirestore.instance
      .collection('activities')
      .doc(activityId);
  await FirebaseFirestore.instance.runTransaction((txn) async {
    final snap = await txn.get(ref);
    if (!snap.exists) {
      return;
    }
    final data = snap.data()!;
    if (data['hostUid'] != user.uid) {
      throw StateError('Only the host can delete this activity.');
    }
    txn.delete(ref);
  });
}
