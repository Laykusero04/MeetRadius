import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Marks an activity thread as read for the signed-in user.
Future<void> markChatThreadRead(String activityId) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null || activityId.isEmpty) return;

  final ref = FirebaseFirestore.instance.collection('users').doc(uid);
  try {
    await ref.update({
      'chatReadAt.$activityId': FieldValue.serverTimestamp(),
    });
  } on FirebaseException catch (e) {
    if (e.code != 'not-found') rethrow;
    await ref.set(
      {
        'chatReadAt': {activityId: FieldValue.serverTimestamp()},
      },
      SetOptions(merge: true),
    );
  }
}
