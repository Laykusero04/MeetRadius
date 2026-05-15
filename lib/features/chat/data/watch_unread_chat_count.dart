import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../activity/domain/activity.dart';
import '../../safety/data/filter_blocked_activities.dart';
import 'user_chat_prefs.dart';
import 'watch_my_chat_threads.dart';

int _countUnreadThreads(
  List<Activity> threads,
  UserChatPrefs prefs,
  List<String> blockedHostIds,
) {
  final visible = filterBlockedActivities(threads, blockedHostIds);
  var count = 0;
  for (final a in visible) {
    if (prefs.isActivityMuted(a.id)) continue;
    if (prefs.isThreadUnread(a.id, a.lastMessageAt)) {
      count++;
    }
  }
  return count;
}

/// Count of activity threads with messages newer than the user's last read time.
Stream<int> watchUnreadChatCount({List<String> blockedHostIds = const []}) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    return Stream<int>.value(0);
  }

  final controller = StreamController<int>.broadcast();
  List<Activity> latestThreads = const [];
  UserChatPrefs latestPrefs = const UserChatPrefs();

  void emit() {
    if (!controller.isClosed) {
      controller.add(
        _countUnreadThreads(latestThreads, latestPrefs, blockedHostIds),
      );
    }
  }

  final threadsSub = watchMyChatThreads().listen(
    (threads) {
      latestThreads = threads;
      emit();
    },
    onError: controller.addError,
  );
  final prefsSub = watchUserChatPrefs().listen(
    (prefs) {
      latestPrefs = prefs;
      emit();
    },
    onError: controller.addError,
  );

  controller.onCancel = () async {
    await threadsSub.cancel();
    await prefsSub.cancel();
  };

  return controller.stream;
}
