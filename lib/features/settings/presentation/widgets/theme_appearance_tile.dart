import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/meet_radius_palette.dart';
import '../../../../core/theme/theme_cubit.dart';

class ThemeAppearanceTile extends StatelessWidget {
  const ThemeAppearanceTile({super.key});

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
