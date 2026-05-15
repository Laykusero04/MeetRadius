import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../features/activity/presentation/feed_activity_detail_screen.dart';
import '../../features/social/data/apply_pending_inviter_follow.dart';
import '../../features/social/data/follow_user.dart';
import '../../features/social/data/pending_inviter_ref.dart';
import 'app_deep_link.dart';

/// Listens for invite / activity URIs and navigates when the user is signed in.
class DeepLinkListener extends StatefulWidget {
  const DeepLinkListener({super.key, required this.child});

  final Widget child;

  @override
  State<DeepLinkListener> createState() => _DeepLinkListenerState();
}

class _DeepLinkListenerState extends State<DeepLinkListener> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  AppDeepLink? _pending;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  Future<void> _listen() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) _queue(parseAppDeepLink(initial));

      _sub = _appLinks.uriLinkStream.listen((uri) {
        _queue(parseAppDeepLink(uri));
      });
    } catch (_) {
      // app_links may be unavailable on some platforms in tests.
    }
  }

  void _queue(AppDeepLink? link) {
    if (link == null) return;
    if (link is UserInviteDeepLink) {
      _handleInviteLink(link);
      return;
    }
    _pending = link;
    _tryNavigate();
  }

  Future<void> _handleInviteLink(UserInviteDeepLink link) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await savePendingInviterRef(link.inviterUserId);
      return;
    }
    if (link.inviterUserId == user.uid) return;
    try {
      await followUser(link.inviterUserId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are now following your friend.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      await applyPendingInviterFollow();
    }
  }

  void _tryNavigate() {
    final link = _pending;
    if (link == null || !mounted) return;
    if (FirebaseAuth.instance.currentUser == null) return;

    _pending = null;
    switch (link) {
      case ActivityDeepLink(:final activityId):
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => FeedActivityDetailScreen(
              activityId: activityId,
              activityTitle: 'Activity',
            ),
          ),
        );
      case UserInviteDeepLink():
        break;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _tryNavigate());
        }
        return widget.child;
      },
    );
  }
}
