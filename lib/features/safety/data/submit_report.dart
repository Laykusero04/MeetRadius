import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Saves a user report for manual review.
Future<void> submitActivityReport({
  required String activityId,
  required String reason,
  String details = '',
  String? reportedUserUid,
  String reportType = 'activity',
  String? messageId,
  String? messageText,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw StateError('Sign in to submit a report.');
  }

  final trimmedReason = reason.trim();
  if (trimmedReason.isEmpty) {
    throw StateError('Choose a reason for your report.');
  }

  var snippet = messageText?.trim() ?? '';
  if (snippet.length > 500) {
    snippet = '${snippet.substring(0, 500)}…';
  }

  await FirebaseFirestore.instance.collection('reports').add({
    'reporterUid': user.uid,
    'activityId': activityId,
    'reportType': reportType,
    if (reportedUserUid != null && reportedUserUid.isNotEmpty)
      'reportedUserUid': reportedUserUid,
    if (messageId != null && messageId.isNotEmpty) 'messageId': messageId,
    if (snippet.isNotEmpty) 'messageText': snippet,
    'reason': trimmedReason,
    'details': details.trim(),
    'createdAt': FieldValue.serverTimestamp(),
    'status': 'pending',
  });
}
