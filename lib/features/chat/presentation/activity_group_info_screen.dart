import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../../activity/data/watch_activity_by_id.dart';
import '../../activity/domain/activity.dart';
import '../../activity/presentation/activity_members_screen.dart';
import '../../activity/presentation/host_activity_actions_sheet.dart';
import '../../activity/presentation/widgets/activity_detail_sections.dart';
import '../../activity/presentation/widgets/activity_location_preview_card.dart';
import '../../safety/data/block_user.dart';
import '../../safety/presentation/report_activity_dialog.dart';
import '../data/mute_activity_chat.dart';
import '../data/user_chat_prefs.dart';

/// Opens [ActivityGroupInfoScreen] from chat (report / mute / members).
void openActivityGroupInfo(
  BuildContext context, {
  required String activityId,
  required String activityTitle,
  String appBarTitle = 'Group info',
}) {
  Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => ActivityGroupInfoScreen(
        activityId: activityId,
        activityTitle: activityTitle,
        appBarTitle: appBarTitle,
      ),
    ),
  );
}

/// Group chat info: activity summary, host, members, and chat-only actions.
class ActivityGroupInfoScreen extends StatelessWidget {
  const ActivityGroupInfoScreen({
    super.key,
    required this.activityId,
    required this.activityTitle,
    this.appBarTitle = 'Group info',
  });

  final String activityId;
  final String activityTitle;
  final String appBarTitle;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return StreamBuilder<Activity?>(
      stream: watchActivityById(activityId),
      builder: (context, snap) {
        final activity = snap.data;
        final self = FirebaseAuth.instance.currentUser?.uid;
        final isHost =
            self != null && activity != null && self == activity.hostUid;

        return Scaffold(
          backgroundColor: p.scaffold,
          appBar: AppBar(
            title: Text(
              appBarTitle,
              style: textTheme.titleMedium?.copyWith(
                color: p.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            backgroundColor: p.scaffold,
            foregroundColor: p.textPrimary,
            surfaceTintColor: Colors.transparent,
            actions: [
              if (isHost)
                IconButton(
                  tooltip: 'Edit or delete',
                  icon: const Icon(Icons.more_vert_rounded),
                  onPressed: () {
                    final a = snap.data;
                    if (a != null) {
                      showHostActivityActionsSheet(context, a);
                    }
                  },
                ),
            ],
          ),
          body: _ActivityGroupInfoBody(
            snap: snap,
            activityId: activityId,
            activityTitle: activityTitle,
            palette: p,
            textTheme: textTheme,
          ),
        );
      },
    );
  }
}

class _ActivityGroupInfoBody extends StatelessWidget {
  const _ActivityGroupInfoBody({
    required this.snap,
    required this.activityId,
    required this.activityTitle,
    required this.palette,
    required this.textTheme,
  });

  final AsyncSnapshot<Activity?> snap;
  final String activityId;
  final String activityTitle;
  final MeetRadiusPalette palette;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final self = FirebaseAuth.instance.currentUser?.uid;
    if (snap.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Could not load group.\n${snap.error}',
            style: textTheme.bodyMedium?.copyWith(color: p.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final activity = snap.data;
    if (snap.connectionState == ConnectionState.waiting && activity == null) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (activity == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'This activity is no longer available.',
            style: textTheme.bodyMedium?.copyWith(color: p.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final count = activity.memberIds.length;
    final displayTitle = activity.title.trim().isNotEmpty
        ? activity.title.trim()
        : activityTitle;
    final now = DateTime.now();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text(
          displayTitle,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleLarge?.copyWith(
            color: p.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$count ${count == 1 ? 'member' : 'members'} in chat',
          style: textTheme.bodyMedium?.copyWith(color: p.textSecondary),
        ),
        const SizedBox(height: 18),
        ActivityHostSummaryCard(
          hostUid: activity.hostUid,
          hostEmail: activity.hostEmail,
        ),
        const SizedBox(height: 22),
        ActivityDetailsSummaryCard(activity: activity, now: now),
        const SizedBox(height: 16),
        ActivityLocationPreviewCard(activity: activity),
        const SizedBox(height: 24),
        Text(
          'CHAT',
          style: textTheme.labelLarge?.copyWith(
            color: p.textMuted,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        ActivityOutlineNavRow(
          icon: Icons.group_outlined,
          title: 'Members',
          subtitle: 'Who is in this activity right now',
          accent: p.upcomingBlue,
          onTap: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => ActivityMembersScreen(activityId: activityId),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        StreamBuilder<UserChatPrefs>(
          stream: watchUserChatPrefs(),
          builder: (context, prefsSnap) {
            final muted =
                prefsSnap.data?.isActivityMuted(activityId) ?? false;
            return ActivityOutlineNavRow(
              icon: muted ? Icons.notifications_off_outlined : Icons.notifications_outlined,
              title: muted ? 'Unmute notifications' : 'Mute notifications',
              subtitle: muted
                  ? 'You will get chat alerts for this thread again'
                  : 'Stop in-app alerts for new messages in this chat',
              accent: p.textSecondary,
              onTap: () async {
                try {
                  await setActivityChatMuted(
                    activityId: activityId,
                    muted: !muted,
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        muted
                            ? 'Chat notifications unmuted.'
                            : 'Chat notifications muted for this activity.',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$e')),
                  );
                }
              },
            );
          },
        ),
        const SizedBox(height: 10),
        ActivityOutlineNavRow(
          icon: Icons.flag_outlined,
          title: 'Report activity',
          subtitle: 'Send to our review team',
          accent: p.textSecondary,
          onTap: () {
            showReportActivityDialog(
              context,
              activityId: activityId,
              reportedUserUid: activity.hostUid,
            );
          },
        ),
        if (self != null &&
            activity.hostUid.isNotEmpty &&
            self != activity.hostUid) ...[
          const SizedBox(height: 10),
          ActivityOutlineNavRow(
            icon: Icons.person_off_outlined,
            title: 'Report host',
            subtitle: 'Flag this person to our review team',
            accent: p.textSecondary,
            onTap: () {
              showReportActivityDialog(
                context,
                activityId: activityId,
                reportedUserUid: activity.hostUid,
              );
            },
          ),
        ],
        if (self != null &&
            activity.hostUid.isNotEmpty &&
            self != activity.hostUid) ...[
          const SizedBox(height: 10),
          ActivityOutlineNavRow(
            icon: Icons.block_outlined,
            title: 'Block host',
            subtitle: 'Hide their activities from your feed',
            accent: p.textSecondary,
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (dialogCtx) {
                  return AlertDialog(
                    backgroundColor: p.card,
                    title: Text(
                      'Block this host?',
                      style: TextStyle(
                        color: p.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    content: Text(
                      'You will not see activities they host. You can unblock later in Settings.',
                      style: TextStyle(color: p.textSecondary, height: 1.4),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx, false),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: p.textSecondary),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx, true),
                        child: Text(
                          'Block',
                          style: TextStyle(
                            color: p.liveAccent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
              if (ok != true || !context.mounted) return;
              try {
                await blockUser(activity.hostUid);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Host blocked.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.of(context).pop();
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$e')),
                );
              }
            },
          ),
        ],
      ],
    );
  }
}
