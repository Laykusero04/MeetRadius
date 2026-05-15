import 'package:flutter/material.dart';

import '../../../../core/theme/meet_radius_palette.dart';

class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: p.cardBorderSubtle),
        ),
          child: SwitchListTile.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: p.liveAccent,
            activeTrackColor: p.liveAccent.withValues(alpha: 0.35),
            secondary: Icon(icon, color: p.textSecondary, size: 22),
            title: Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                color: p.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: subtitle != null
                ? Text(
                    subtitle!,
                    style: textTheme.bodySmall?.copyWith(color: p.textMuted),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
    );
  }
}
