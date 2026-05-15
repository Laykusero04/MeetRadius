import 'package:shared_preferences/shared_preferences.dart';

const _kPendingInviterUidKey = 'meet_radius_pending_inviter_uid';

/// Stores inviter from an invite deep link until the user signs up or signs in.
Future<void> savePendingInviterRef(String inviterUid) async {
  if (inviterUid.isEmpty) return;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kPendingInviterUidKey, inviterUid);
}

Future<String?> peekPendingInviterRef() async {
  final prefs = await SharedPreferences.getInstance();
  final value = prefs.getString(_kPendingInviterUidKey);
  if (value == null || value.isEmpty) return null;
  return value;
}

Future<void> clearPendingInviterRef() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_kPendingInviterUidKey);
}
