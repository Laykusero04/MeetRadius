import 'package:flutter/material.dart';

import '../../../../core/theme/meet_radius_palette.dart';
import '../../domain/help_content.dart';

class HelpFaqTile extends StatelessWidget {
  const HelpFaqTile({super.key, required this.item});

  final HelpFaqItem item;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: p.card,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            iconColor: p.textMuted,
            collapsedIconColor: p.textMuted,
            title: Text(
              item.question,
              style: textTheme.titleSmall?.copyWith(
                color: p.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item.answer,
                  style: textTheme.bodyMedium?.copyWith(
                    color: p.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
