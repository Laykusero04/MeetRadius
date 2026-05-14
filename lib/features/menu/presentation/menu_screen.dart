import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../shared/widgets/simple_menu_page.dart';
import '../../../shared/widgets/brand_gradient.dart';
import '../../feed/presentation/widgets/feed_create_speed_dial.dart';
import '../../profile/data/watch_current_user_profile.dart';
import '../../profile/domain/user_profile.dart';
import '../../profile/presentation/profile_screen.dart';

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
        const _ThemeAppearanceTile(),
        const SizedBox(height: 8),
        _MenuTile(
          icon: Icons.settings_outlined,
          label: 'Settings',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SimpleMenuPage(
                  title: 'Settings',
                  message:
                      'Notifications, privacy, and blocked users will live here.',
                ),
              ),
            );
          },
        ),
        _MenuTile(
          icon: Icons.person_add_outlined,
          label: 'Invite friends',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SimpleMenuPage(
                  title: 'Invite friends',
                  message:
                      'Share your invite link or contacts flow will go here.',
                ),
              ),
            );
          },
        ),
        _MenuTile(
          icon: Icons.help_outline,
          label: 'Help & support',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SimpleMenuPage(
                  title: 'Help & support',
                  message:
                      'FAQs, safety tips, and contact support will be linked here.',
                ),
              ),
            );
          },
        ),
        _MenuTile(
          icon: Icons.description_outlined,
          label: 'Terms & privacy',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SimpleMenuPage(
                  title: 'Terms & privacy',
                  message: 'Legal pages placeholder.',
                ),
              ),
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(),
        ),
        _MenuTile(
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

class _ThemeAppearanceTile extends StatelessWidget {
  const _ThemeAppearanceTile();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final mode = context.watch<ThemeCubit>().state;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.cardBorderSubtle),
      ),
      child: Row(
        children: [
          Icon(Icons.contrast, color: p.textSecondary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance',
                  style: textTheme.titleSmall?.copyWith(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mode == ThemeMode.dark ? 'Dark theme' : 'Light theme',
                  style: textTheme.bodySmall?.copyWith(color: p.textMuted),
                ),
              ],
            ),
          ),
          SegmentedButton<ThemeMode>(
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
            showSelectedIcon: false,
            segments: const [
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode_outlined, size: 20),
                tooltip: 'Light',
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode_outlined, size: 20),
                tooltip: 'Dark',
              ),
            ],
            selected: {mode},
            onSelectionChanged: (selection) {
              if (selection.isEmpty) return;
              context.read<ThemeCubit>().setThemeMode(selection.first);
            },
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = destructive ? p.liveDot : p.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: p.card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
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
  }
}
