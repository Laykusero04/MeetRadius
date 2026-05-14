import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../data/watch_activity_by_id.dart';
import '../domain/activity.dart';
import 'activity_members_screen.dart';
import 'host_activity_actions_sheet.dart';
import 'widgets/activity_detail_sections.dart';
import 'widgets/activity_location_preview_card.dart';

/// Opens the feed / browse activity detail screen (no chat-only actions).
void openFeedActivityDetail(
  BuildContext context, {
  required String activityId,
  required String activityTitle,
}) {
  Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => FeedActivityDetailScreen(
        activityId: activityId,
        activityTitle: activityTitle,
      ),
    ),
  );
}

/// Activity details for the feed, map, and profile: creator, facts, members.
/// Intentionally separate from [ActivityGroupInfoScreen] (no report / mute).
class FeedActivityDetailScreen extends StatelessWidget {
  const FeedActivityDetailScreen({
    super.key,
    required this.activityId,
    required this.activityTitle,
  });

  final String activityId;
  final String activityTitle;

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
              'Activity',
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
          body: _FeedActivityDetailBody(
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

class _FeedActivityDetailBody extends StatelessWidget {
  const _FeedActivityDetailBody({
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
    if (snap.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Could not load this activity.\n${snap.error}',
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Text(
          displayTitle,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: textTheme.headlineSmall?.copyWith(
            color: p.textPrimary,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '$count ${count == 1 ? 'person has' : 'people have'} joined',
          style: textTheme.bodyLarge?.copyWith(
            color: p.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 22),
        ActivityHostSummaryCard(
          hostUid: activity.hostUid,
          hostEmail: activity.hostEmail,
        ),
        const SizedBox(height: 16),
        ActivityDetailsSummaryCard(activity: activity, now: now),
        const SizedBox(height: 16),
        ActivityLocationPreviewCard(activity: activity),
        const SizedBox(height: 20),
        ActivityOutlineNavRow(
          icon: Icons.group_outlined,
          title: 'Who is going',
          subtitle: 'See everyone in this activity',
          accent: p.upcomingBlue,
          onTap: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => ActivityMembersScreen(activityId: activityId),
              ),
            );
          },
        ),
      ],
    );
  }
}
