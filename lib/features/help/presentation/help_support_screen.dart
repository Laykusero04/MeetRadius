import 'package:flutter/material.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../../../shared/widgets/brand_gradient.dart';
import '../../settings/presentation/widgets/settings_info_tile.dart';
import '../../settings/presentation/widgets/settings_section.dart';
import '../data/contact_support.dart';
import '../domain/help_content.dart';
import 'widgets/help_faq_tile.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: p.scaffold,
      appBar: AppBar(
        title: const Text('Help & support'),
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
                Icon(Icons.support_agent_outlined, size: 40, color: p.liveAccent),
                const SizedBox(height: 12),
                Text(
                  'We are here to help',
                  style: textTheme.titleMedium?.copyWith(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Browse common questions, safety tips, or email our team.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(color: p.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SettingsSection(
            title: 'Common questions',
            children: [
              for (final item in kHelpFaqItems) HelpFaqTile(item: item),
            ],
          ),
          SettingsSection(
            title: 'Safety tips',
            children: [
              for (final tip in kSafetyTips)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: p.liveAccent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tip,
                          style: textTheme.bodyMedium?.copyWith(
                            color: p.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SettingsSection(
            title: 'Report & block',
            children: [
              SettingsInfoTile(
                icon: Icons.flag_outlined,
                title: 'How reporting works',
                subtitle: kReportGuidance.trim(),
              ),
            ],
          ),
          SettingsSection(
            title: 'Contact',
            subtitle: 'We typically reply within 1–2 business days.',
            children: [
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () => _contactSupport(context),
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
                          const Icon(Icons.mail_outline, color: Colors.white, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Email $kSupportEmail',
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<void> _contactSupport(BuildContext context) async {
    final launched = await launchSupportEmail();
    if (!context.mounted) return;
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open mail. Email us at $kSupportEmail'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
