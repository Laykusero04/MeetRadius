import 'package:flutter/material.dart';

import '../../../../core/theme/meet_radius_palette.dart';
import '../../../profile/domain/user_profile.dart';
import 'follow_user_button.dart';

class SocialUserListTile extends StatelessWidget {
  const SocialUserListTile({
    super.key,
    required this.uid,
    required this.profile,
    this.subtitle,
    this.showFollowButton = true,
  });

  final String uid;
  final UserProfile profile;
  final String? subtitle;
  final bool showFollowButton;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: p.card,
      borderRadius: BorderRadius.circular(14),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: p.brandPurple.withValues(alpha: 0.35),
          foregroundColor: p.textPrimary,
          child: Text(
            profile.initials,
            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        title: Text(
          profile.displayName,
          style: textTheme.titleSmall?.copyWith(
            color: p.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: subtitle == null || subtitle!.isEmpty
            ? null
            : Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(color: p.textMuted),
              ),
        trailing: showFollowButton
            ? FollowUserButton(targetUid: uid)
            : null,
      ),
    );
  }
}
