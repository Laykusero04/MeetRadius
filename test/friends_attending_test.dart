import 'package:flutter_test/flutter_test.dart';
import 'package:meet_radius/features/activity/domain/activity.dart';
import 'package:meet_radius/features/profile/domain/user_profile.dart';
import 'package:meet_radius/features/social/domain/friends_attending.dart';

Activity _activity({List<String> memberIds = const []}) {
  return Activity(
    id: 'a1',
    title: 'Coffee',
    spot: 'Park',
    category: 'Coffee',
    capacity: 10,
    joinedCount: memberIds.length,
    isLive: true,
    startsAt: DateTime(2026, 5, 15, 18),
    hostUid: 'host',
    memberIds: memberIds,
  );
}

void main() {
  test('formatFriendNamesLine handles one, two, and many', () {
    expect(formatFriendNamesLine(['Alex']), 'Alex is going');
    expect(
      formatFriendNamesLine(['Alex', 'Jordan']),
      'Alex, Jordan are going',
    );
    expect(
      formatFriendNamesLine(['Alex', 'Jordan', 'Sam']),
      'Alex, Jordan +1 are going',
    );
  });

  test('friendsAttendingForActivity lists followed members', () {
    const alex = UserProfile(email: 'a@test.com', firstName: 'Alex', lastName: 'Lee');
    const jordan = UserProfile(
      email: 'j@test.com',
      firstName: 'Jordan',
      lastName: 'Kim',
    );

    final display = friendsAttendingForActivity(
      activity: _activity(memberIds: ['host', 'u1', 'u2', 'other']),
      followingIds: {'u1', 'u2'},
      profiles: {
        'u1': alex,
        'u2': jordan,
      },
    );

    expect(display.hasLine, isTrue);
    expect(display.namesLine, 'Alex, Jordan are going');
    expect(display.initials, ['A', 'J']);
  });

  test('friendUidsOnActivities collects only followed members', () {
    final uids = friendUidsOnActivities(
      [
        _activity(memberIds: ['a', 'b']),
        _activity(memberIds: ['b', 'c']),
      ],
      {'b'},
    );
    expect(uids, {'b'});
  });
}
