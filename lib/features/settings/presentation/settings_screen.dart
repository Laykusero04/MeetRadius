import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../application/settings_cubit.dart';
import '../domain/user_settings.dart';
import 'blocked_users_screen.dart';
import 'widgets/settings_info_tile.dart';
import 'widgets/settings_nav_tile.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_switch_tile.dart';
import 'widgets/theme_appearance_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _versionLabel = 'MeetRadius';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _versionLabel = 'MeetRadius ${info.version} (${info.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.scaffold,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: p.scaffold,
        foregroundColor: p.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocBuilder<SettingsCubit, UserSettings>(
        builder: (context, settings) {
          final cubit = context.read<SettingsCubit>();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              SettingsSection(
                title: 'Preferences',
                children: [
                  const ThemeAppearanceTile(),
                  const SizedBox(height: 8),
                  const SettingsInfoTile(
                    icon: Icons.radar_outlined,
                    title: 'Discovery radius',
                    subtitle:
                        'Activities within 15 miles of your discovery anchor (MVP maximum).',
                  ),
                  SettingsSwitchTile(
                    icon: Icons.my_location_outlined,
                    title: 'Use GPS for discovery',
                    subtitle:
                        'When off, feed and map use your saved discovery anchor.',
                    value: settings.useGpsForDiscovery,
                    onChanged: cubit.setUseGpsForDiscovery,
                  ),
                  SettingsNavTile(
                    icon: Icons.refresh_outlined,
                    label: 'Refresh discovery location',
                    subtitle: settings.useGpsForDiscovery
                        ? 'Updates your GPS anchor for feed and map sorting.'
                        : 'Saves your current GPS position as the manual anchor.',
                    onTap: () async {
                      try {
                        await cubit.saveCurrentLocationAsAnchor();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Discovery location updated.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not update location: $e'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: 'Notifications',
                subtitle:
                    'Synced to your account. In-app inbox always; push when enabled on device.',
                children: [
                  SettingsSwitchTile(
                    icon: Icons.event_outlined,
                    title: 'Activity reminders',
                    value: settings.notifyActivity,
                    onChanged: cubit.setNotifyActivity,
                  ),
                  SettingsSwitchTile(
                    icon: Icons.chat_bubble_outline,
                    title: 'Chat messages',
                    value: settings.notifyChat,
                    onChanged: cubit.setNotifyChat,
                  ),
                  SettingsSwitchTile(
                    icon: Icons.bolt_outlined,
                    title: 'Live nearby activities',
                    value: settings.notifyLiveNearby,
                    onChanged: cubit.setNotifyLiveNearby,
                  ),
                ],
              ),
              SettingsSection(
                title: 'Privacy & safety',
                children: [
                  const SettingsInfoTile(
                    icon: Icons.location_on_outlined,
                    title: 'Location',
                    subtitle:
                        'MeetRadius uses GPS or a manual city and ZIP to rank nearby activities. '
                        'We do not share your precise location on your profile.',
                  ),
                  SettingsNavTile(
                    icon: Icons.block_outlined,
                    label: 'Blocked users',
                    onTap: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const BlockedUsersScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: 'About',
                children: [
                  SettingsInfoTile(
                    icon: Icons.info_outline,
                    title: _versionLabel,
                    subtitle: 'Local activities, real-world meetups.',
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
