import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../../../shared/widgets/brand_gradient.dart';
import '../../profile/data/watch_current_user_profile.dart';
import '../../settings/presentation/widgets/settings_section.dart';
import '../domain/invite_link.dart';

class InviteFriendsScreen extends StatelessWidget {
  const InviteFriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: p.scaffold,
      appBar: AppBar(
        title: const Text('Invite friends'),
        backgroundColor: p.scaffold,
        foregroundColor: p.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: user == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Sign in to get your personal invite link.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: p.textSecondary,
                  ),
                ),
              ),
            )
          : StreamBuilder(
              stream: watchCurrentUserProfile(),
              builder: (context, snap) {
                final profile = snap.data;
                final invite = buildInviteLink(
                  userId: user.uid,
                  inviterDisplayName: profile?.displayName,
                );

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: p.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: p.cardBorderSubtle),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.group_add_outlined,
                            size: 40,
                            color: p.liveAccent,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Bring friends to real meetups',
                            textAlign: TextAlign.center,
                            style: textTheme.titleMedium?.copyWith(
                              color: p.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Share your link so friends can join MeetRadius '
                            'and discover activities near you.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: p.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SettingsSection(
                      title: 'Your invite link',
                      subtitle:
                          'When they sign up with this link, we can connect you later.',
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: p.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: p.cardBorderSubtle),
                          ),
                          child: SelectableText(
                            invite.url,
                            style: textTheme.bodyMedium?.copyWith(
                              color: p.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _InviteActionButton(
                          icon: Icons.link,
                          label: 'Copy link',
                          onPressed: () => _copyLink(context, invite.url),
                        ),
                        const SizedBox(height: 8),
                        _InviteActionButton(
                          icon: Icons.share_outlined,
                          label: 'Share invite',
                          primary: true,
                          onPressed: () => _shareInvite(invite),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
    );
  }

  static Future<void> _copyLink(BuildContext context, String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Invite link copied'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Future<void> _shareInvite(InviteLink invite) async {
    await Share.share(
      invite.shareMessage,
      subject: 'Join me on MeetRadius',
    );
  }
}

class _InviteActionButton extends StatelessWidget {
  const _InviteActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    if (primary) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: BrandGradient.buttonFill(p),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: p.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.cardBorderSubtle),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: p.textPrimary, size: 22),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: p.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
