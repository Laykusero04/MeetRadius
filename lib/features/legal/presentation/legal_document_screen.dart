import 'package:flutter/material.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../data/open_legal_url.dart';
import '../domain/legal_section.dart';

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({super.key, required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: p.scaffold,
      appBar: AppBar(
        title: Text(document.title),
        backgroundColor: p.scaffold,
        foregroundColor: p.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            'Last updated ${document.lastUpdated}',
            style: textTheme.labelLarge?.copyWith(color: p.textMuted),
          ),
          if (document.webUrl != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _openWeb(context, document.webUrl!),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('View on meetradius.app'),
            ),
          ],
          const SizedBox(height: 16),
          for (final section in document.sections) ...[
            Text(
              section.title,
              style: textTheme.titleMedium?.copyWith(
                color: p.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            for (final paragraph in section.paragraphs) ...[
              Text(
                paragraph,
                style: textTheme.bodyMedium?.copyWith(
                  color: p.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  static Future<void> _openWeb(BuildContext context, String url) async {
    final ok = await openLegalWebUrl(url);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open $url'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
