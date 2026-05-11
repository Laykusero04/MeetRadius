import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/simple_menu_page.dart';
import '../../profile/presentation/profile_screen.dart';

/// More tab: account shortcuts (profile, settings, support, sign out).
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorderSubtle),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.avatarPurple,
                child: Text(
                  'M',
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Matt',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'matt@meetradius.app',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _MenuTile(
          icon: Icons.person_outline,
          label: 'Profile',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (ctx) => Scaffold(
                  backgroundColor: AppColors.scaffold,
                  appBar: AppBar(
                    title: const Text('Profile'),
                    backgroundColor: AppColors.scaffold,
                    foregroundColor: AppColors.textPrimary,
                    surfaceTintColor: Colors.transparent,
                  ),
                  body: const ProfileScreen(),
                ),
              ),
            );
          },
        ),
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
          child: Divider(color: AppColors.cardBorderSubtle),
        ),
        _MenuTile(
          icon: Icons.logout,
          label: 'Log out',
          destructive: true,
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.card,
                title: Text(
                  'Log out?',
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                content: Text(
                  'Auth is not wired yet — this is a static demo.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          AppColors.liveDot.withValues(alpha: 0.85),
                      foregroundColor: AppColors.textPrimary,
                    ),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
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
    final color = destructive ? AppColors.liveDot : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.card,
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
                  color: AppColors.textMuted,
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
