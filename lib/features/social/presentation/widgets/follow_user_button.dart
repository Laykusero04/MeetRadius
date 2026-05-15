import 'package:flutter/material.dart';

import '../../../../core/theme/meet_radius_palette.dart';
import '../../../../shared/widgets/brand_gradient.dart';
import '../../data/follow_user.dart';

/// Compact Follow / Following control (Strava-style).
class FollowUserButton extends StatefulWidget {
  const FollowUserButton({
    super.key,
    required this.targetUid,
    this.compact = true,
  });

  final String targetUid;
  final bool compact;

  @override
  State<FollowUserButton> createState() => _FollowUserButtonState();
}

class _FollowUserButtonState extends State<FollowUserButton> {
  bool? _following;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant FollowUserButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetUid != widget.targetUid) {
      _following = null;
      _load();
    }
  }

  Future<void> _load() async {
    final value = await isFollowingUser(widget.targetUid);
    if (!mounted) return;
    setState(() => _following = value);
  }

  Future<void> _toggle() async {
    if (_busy || _following == null) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (_following!) {
        await unfollowUser(widget.targetUid);
      } else {
        await followUser(widget.targetUid);
      }
      if (!mounted) return;
      setState(() => _following = !_following!);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('StateError: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (_following == null) {
      return SizedBox(
        width: widget.compact ? 88 : 120,
        height: 36,
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final following = _following!;
    if (following) {
      return OutlinedButton(
        onPressed: _busy ? null : _toggle,
        style: OutlinedButton.styleFrom(
          foregroundColor: p.textSecondary,
          side: BorderSide(color: p.cardBorderSubtle),
          minimumSize: Size(widget.compact ? 96 : 120, 36),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: _busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                'Following',
                style: TextStyle(
                  fontSize: widget.compact ? 13 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
      );
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: _busy ? null : _toggle,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: BrandGradient.buttonFill(p),
          ),
          child: SizedBox(
            width: widget.compact ? 88 : 120,
            height: 36,
            child: Center(
              child: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Follow',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widget.compact ? 13 : 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
