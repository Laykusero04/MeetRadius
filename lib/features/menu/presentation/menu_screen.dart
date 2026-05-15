import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../../../shared/widgets/brand_gradient.dart';
import '../../../shared/widgets/menu_list_tile.dart';
import '../../feed/presentation/widgets/feed_create_speed_dial.dart';
import '../../profile/data/watch_current_user_profile.dart';
import '../../profile/domain/user_profile.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../help/presentation/help_support_screen.dart';
import '../../legal/presentation/terms_privacy_screen.dart';
import '../../invite/presentation/invite_friends_screen.dart';
import '../../social/presentation/friends_screen.dart';
import '../../settings/presentation/settings_screen.dart';

void _pushUserProfileRoute(BuildContext context) {
  Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (ctx) {
        final p = ctx.palette;
        return Scaffold(
          backgroundColor: p.scaffold,
          appBar: AppBar(
            title: const Text('Profile'),
            backgroundColor: p.scaffold,
            foregroundColor: p.textPrimary,
            surfaceTintColor: Colors.transparent,
          ),
          body: const ProfileScreen(),
          floatingActionButton: const FeedCreateSpeedDial(),
        );
      },
    ),
  );
}

/// More tab: profile header (opens profile), settings, support, sign out.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        StreamBuilder<UserProfile?>(
          stream: watchCurrentUserProfile(),
          builder: (context, snap) {
            final profile = snap.data;
            final initials = profile?.initials ?? '…';
            final name = profile?.displayName ?? 'Loading…';
            final email = profile?.email ?? '';
            final p = context.palette;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: p.card,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () => _pushUserProfileRoute(context),
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        GradientAvatar(
                          outerRadius: 28,
                          backgroundColor: p.avatarPurple,
                          child: Text(
                            initials,
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: textTheme.titleMedium?.copyWith(
                                  color: p.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              if (email.isNotEmpty)
                                Text(
                                  email,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: p.textMuted,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: p.textMuted,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        MenuListTile(
          icon: Icons.settings_outlined,
          label: 'Settings',
          onTap: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const SettingsScreen(),
              ),
            );
          },
        ),
        MenuListTile(
          icon: Icons.people_outline,
          label: 'Friends',
          subtitle: 'Following, search, and invites',
          onTap: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const FriendsScreen(),
              ),
            );
          },
        ),
        MenuListTile(
          icon: Icons.person_add_outlined,
          label: 'Invite friends',
          onTap: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const InviteFriendsScreen(),
              ),
            );
          },
        ),
        MenuListTile(
          icon: Icons.help_outline,
          label: 'Help & support',
          onTap: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const HelpSupportScreen(),
              ),
            );
          },
        ),
        MenuListTile(
          icon: Icons.description_outlined,
          label: 'Terms & privacy',
          onTap: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const TermsPrivacyScreen(),
              ),
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(),
        ),
        MenuListTile(
          icon: Icons.logout,
          label: 'Log out',
          destructive: true,
          onTap: () {
            final nav = Navigator.of(context);
            final shellContext = context;
            showDialog<void>(
              context: context,
              builder: (ctx) {
                final d = ctx.palette;
                return AlertDialog(
                  backgroundColor: d.card,
                  title: Text(
                    'Log out?',
                    style: textTheme.titleLarge?.copyWith(
                      color: d.textPrimary,
                    ),
                  ),
                  content: Text(
                    'You will need to sign in again to use your account.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: d.textSecondary,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await FirebaseAuth.instance.signOut();
                        if (!shellContext.mounted) return;
                        nav.popUntil((route) => route.isFirst);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            d.liveDot.withValues(alpha: 0.85),
                        foregroundColor: d.textPrimary,
                      ),
                      child: const Text('Log out'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
