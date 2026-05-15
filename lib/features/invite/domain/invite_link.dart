/// Personal invite URL and pre-filled share text for a user.
final class InviteLink {
  const InviteLink({
    required this.url,
    required this.shareMessage,
  });

  final String url;
  final String shareMessage;
}

/// Builds invite URLs until a dedicated referral backend ships.
InviteLink buildInviteLink({
  required String userId,
  String? inviterDisplayName,
}) {
  final ref = Uri.encodeComponent(userId);
  final url = 'https://meetradius.app/invite?ref=$ref';
  final name = inviterDisplayName?.trim();
  final message = name != null && name.isNotEmpty
      ? '$name invited you to MeetRadius — discover local activities near you.\n$url'
      : 'Join me on MeetRadius — discover local activities near you.\n$url';
  return InviteLink(url: url, shareMessage: message);
}

/// Deep link to open one activity (join / detail flow).
InviteLink buildActivityInviteLink({
  required String activityId,
  required String activityTitle,
  String? inviterDisplayName,
}) {
  final id = Uri.encodeComponent(activityId);
  final url = 'https://meetradius.app/activity?id=$id';
  final customScheme = 'meetradius://activity?id=$id';
  final name = inviterDisplayName?.trim();
  final title = activityTitle.trim().isEmpty ? 'an activity' : activityTitle.trim();
  final message = name != null && name.isNotEmpty
      ? '$name invited you to "$title" on MeetRadius.\n$url'
      : 'Join "$title" on MeetRadius.\n$url';
  return InviteLink(
    url: url,
    shareMessage: '$message\n\nOpen in app: $customScheme',
  );
}
