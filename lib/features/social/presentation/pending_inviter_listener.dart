import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/apply_pending_inviter_follow.dart';

/// Runs once after sign-in to follow someone from a stored invite link.
class PendingInviterListener extends StatefulWidget {
  const PendingInviterListener({super.key, required this.child});

  final Widget child;

  @override
  State<PendingInviterListener> createState() => _PendingInviterListenerState();
}

class _PendingInviterListenerState extends State<PendingInviterListener> {
  bool _applied = false;

  Future<void> _maybeApply() async {
    if (_applied || FirebaseAuth.instance.currentUser == null) return;
    _applied = true;
    final followed = await applyPendingInviterFollow();
    if (!mounted || followed == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You are now following the friend who invited you.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _maybeApply());
        }
        return widget.child;
      },
    );
  }
}
