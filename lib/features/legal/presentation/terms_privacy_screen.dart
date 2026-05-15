import 'package:flutter/material.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../settings/presentation/widgets/settings_section.dart';
import '../../../shared/widgets/menu_list_tile.dart';
import '../domain/legal_section.dart';
import '../domain/privacy_policy.dart';
import '../domain/terms_of_service.dart';
import 'legal_document_screen.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: p.scaffold,
      appBar: AppBar(
        title: const Text('Terms & privacy'),
        backgroundColor: p.scaffold,
        foregroundColor: p.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
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
                Icon(Icons.gavel_outlined, size: 40, color: p.liveAccent),
                const SizedBox(height: 12),
                Text(
                  'Policies',
                  style: textTheme.titleMedium?.copyWith(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Read how MeetRadius works and how we handle your data. '
                  'These summaries are provided in-app; the web versions apply when published.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(color: p.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SettingsSection(
            title: 'Legal documents',
            children: [
              MenuListTile(
                icon: Icons.article_outlined,
                label: 'Terms of Service',
                subtitle: 'Updated $kTermsLastUpdated',
                onTap: () => _openDocument(context, kTermsOfService),
              ),
              MenuListTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                subtitle: 'Updated $kPrivacyLastUpdated',
                onTap: () => _openDocument(context, kPrivacyPolicy),
              ),
            ],
          ),
          SettingsSection(
            title: 'Your controls',
            children: [
              MenuListTile(
                icon: Icons.settings_outlined,
                label: 'App settings',
                subtitle: 'Notifications, privacy, and blocked users',
                onTap: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void _openDocument(BuildContext context, LegalDocument document) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => LegalDocumentScreen(document: document),
      ),
    );
  }
}
