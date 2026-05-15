import 'package:flutter/material.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../../profile/data/fetch_public_user_profile.dart';
import '../../profile/domain/user_profile.dart';
import '../../safety/data/block_user.dart';

class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: p.scaffold,
      appBar: AppBar(
        title: const Text('Blocked users'),
        backgroundColor: p.scaffold,
        foregroundColor: p.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: StreamBuilder<List<String>>(
        stream: watchBlockedUserIds(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Text(
                'Could not load blocked users.',
                style: textTheme.bodyMedium?.copyWith(color: p.textSecondary),
              ),
            );
          }
          final ids = snap.data;
          if (ids == null) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          if (ids.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.block_outlined, size: 48, color: p.textMuted),
                    const SizedBox(height: 16),
                    Text(
                      'No blocked users',
                      style: textTheme.titleMedium?.copyWith(
                        color: p.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Block someone from an activity chat’s group info. '
                      'Their activities will be hidden from your feed.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: p.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: ids.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: p.cardBorderSubtle),
            itemBuilder: (context, i) {
              return _BlockedUserTile(blockedUid: ids[i]);
            },
          );
        },
      ),
    );
  }
}

class _BlockedUserTile extends StatelessWidget {
  const _BlockedUserTile({required this.blockedUid});

  final String blockedUid;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder<UserProfile?>(
      future: fetchPublicUserProfile(blockedUid),
      builder: (context, snap) {
        final profile = snap.data;
        final name = profile?.displayName ?? 'User';
        final subtitle = profile?.email ?? blockedUid;

        return ListTile(
          title: Text(
            name,
            style: textTheme.titleSmall?.copyWith(
              color: p.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(color: p.textMuted),
          ),
          trailing: TextButton(
            onPressed: () async {
              try {
                await unblockUser(blockedUid);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User unblocked.')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$e')),
                );
              }
            },
            child: const Text('Unblock'),
          ),
        );
      },
    );
  }
}
