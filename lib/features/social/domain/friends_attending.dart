import '../../activity/domain/activity.dart';
import '../../profile/domain/user_profile.dart';

/// Card subtitle when people you follow are on the activity.
class FriendsAttendingDisplay {
  const FriendsAttendingDisplay({
    this.initials = const [],
    this.namesLine,
  });

  final List<String> initials;
  final String? namesLine;

  bool get hasLine =>
      namesLine != null && namesLine!.trim().isNotEmpty && initials.isNotEmpty;
}

/// First names of followed members on [activity], e.g. "Alex, Jordan" or "Alex +2".
FriendsAttendingDisplay friendsAttendingForActivity({
  required Activity activity,
  required Set<String> followingIds,
  required Map<String, UserProfile?> profiles,
  String? excludeUid,
}) {
  final friendIds = activity.memberIds
      .where((id) => followingIds.contains(id))
      .where((id) => excludeUid == null || id != excludeUid)
      .toList();
  if (friendIds.isEmpty) {
    return const FriendsAttendingDisplay();
  }

  final firstNames = <String>[];
  final initials = <String>[];
  for (final id in friendIds) {
    final profile = profiles[id];
    final display = profile?.displayName ?? 'Member';
    firstNames.add(_firstName(display));
    final letter = profile?.initials.isNotEmpty == true
        ? profile!.initials[0]
        : display[0].toUpperCase();
    initials.add(letter);
  }

  return FriendsAttendingDisplay(
    initials: initials.take(4).toList(),
    namesLine: formatFriendNamesLine(firstNames),
  );
}

String _firstName(String displayName) {
  final parts = displayName.trim().split(RegExp(r'\s+'));
  return parts.isNotEmpty ? parts.first : displayName;
}

String formatFriendNamesLine(List<String> firstNames) {
  if (firstNames.isEmpty) return '';
  if (firstNames.length == 1) {
    return '${firstNames.first} is going';
  }
  if (firstNames.length == 2) {
    return '${firstNames[0]}, ${firstNames[1]} are going';
  }
  final head = firstNames.take(2).join(', ');
  final extra = firstNames.length - 2;
  return '$head +$extra are going';
}

/// UIDs to load profiles for when rendering the feed.
Set<String> friendUidsOnActivities(
  Iterable<Activity> activities,
  Set<String> followingIds,
) {
  final out = <String>{};
  for (final activity in activities) {
    for (final id in activity.memberIds) {
      if (followingIds.contains(id)) out.add(id);
    }
  }
  return out;
}
