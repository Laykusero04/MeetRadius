import 'package:flutter_test/flutter_test.dart';
import 'package:meet_radius/features/invite/domain/invite_link.dart';

void main() {
  test('buildInviteLink encodes uid and includes name', () {
    final link = buildInviteLink(
      userId: 'abc/123',
      inviterDisplayName: 'Alex Kim',
    );

    expect(link.url, 'https://meetradius.app/invite?ref=abc%2F123');
    expect(link.shareMessage, contains('Alex Kim invited you'));
    expect(link.shareMessage, contains(link.url));
  });

  test('buildInviteLink works without display name', () {
    final link = buildInviteLink(userId: 'uid1');

    expect(link.url, 'https://meetradius.app/invite?ref=uid1');
    expect(link.shareMessage, startsWith('Join me on MeetRadius'));
  });
}
