import 'package:firebase_auth/firebase_auth.dart';

import 'follow_user.dart';
import 'pending_inviter_ref.dart';

/// After sign-in, auto-follow someone who shared an invite link (once).
Future<String?> applyPendingInviterFollow() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;

  final inviter = await peekPendingInviterRef();
  if (inviter == null || inviter.isEmpty || inviter == uid) {
    await clearPendingInviterRef();
    return null;
  }

  await clearPendingInviterRef();
  try {
    await followUser(inviter);
    return inviter;
  } catch (_) {
    return null;
  }
}
