import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../data/watch_activity_by_id.dart';
import '../domain/activity.dart';
import '../../../features/profile/data/fetch_public_user_profile.dart';
import '../../../features/profile/domain/user_profile.dart';

List<String> orderedMemberUids(Activity a) {
  final host = a.hostUid;
  final others = a.memberIds.where((id) => id != host).toList()..sort();
  if (host.isEmpty) return others;
  return [host, ...others];
}

/// Full-screen member list for one activity (current [memberIds] only).
class ActivityMembersScreen extends StatelessWidget {
  const ActivityMembersScreen({super.key, required this.activityId});

  final String activityId;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final self = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: p.scaffold,
      appBar: AppBar(
        title: Text(
          'Members',
          style: textTheme.titleMedium?.copyWith(
            color: p.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: p.scaffold,
        foregroundColor: p.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: StreamBuilder<Activity?>(
        stream: watchActivityById(activityId),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load members.\n${snap.error}',
                  style: textTheme.bodyMedium?.copyWith(color: p.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (snap.connectionState == ConnectionState.waiting &&
              snap.data == null) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          final activity = snap.data;
          if (activity == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'This activity is no longer available.',
                  style: textTheme.bodyMedium?.copyWith(color: p.textSecondary),
                ),
              ),
            );
          }

          final ordered = orderedMemberUids(activity);
          final key = ordered.join('|');

          return FutureBuilder<Map<String, UserProfile?>>(
            key: ValueKey<String>(key),
            future: fetchPublicUserProfiles(ordered),
            builder: (context, profileSnap) {
              if (profileSnap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Could not load names.\n${profileSnap.error}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: p.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              if (!profileSnap.hasData) {
                return const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              final profiles = profileSnap.data!;

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: ordered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, i) {
                  final uid = ordered[i];
                  final isHost = uid == activity.hostUid;
                  final isSelf = self != null && uid == self;
                  final profile = profiles[uid];
                  final title = profile?.displayName ??
                      (isHost && (activity.hostEmail ?? '').isNotEmpty
                          ? activity.hostEmail!.split('@').first
                          : 'Member');
                  final subtitle = isHost
                      ? 'Host${isSelf ? ' · You' : ''}'
                      : (isSelf ? 'You' : (profile?.email ?? ''));

                  return Material(
                    color: p.card,
                    borderRadius: BorderRadius.circular(14),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: p.brandPurple.withValues(alpha: 0.35),
                        foregroundColor: p.textPrimary,
                        child: Text(
                          profile?.initials ??
                              (uid.length >= 2 ? uid.substring(0, 2) : uid)
                                  .toUpperCase(),
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      title: Text(
                        title,
                        style: textTheme.titleSmall?.copyWith(
                          color: p.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: subtitle.isEmpty
                          ? null
                          : Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: p.textMuted,
                              ),
                            ),
                      trailing: isHost
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: p.liveAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'HOST',
                                style: textTheme.labelSmall?.copyWith(
                                  color: p.liveAccent,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            )
                          : null,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
