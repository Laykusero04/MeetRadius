import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/meet_radius_palette.dart';
import '../../../settings/application/settings_cubit.dart';
import '../../../settings/presentation/settings_screen.dart';

/// Shown when activities exist in Firestore but GPS anchor filters all of them out.
class FeedLocationEmptyHint extends StatelessWidget {
  const FeedLocationEmptyHint({
    super.key,
    required this.activityCount,
    required this.nearestMiles,
    required this.usedRegionalFallback,
  });

  final int activityCount;
  final double? nearestMiles;
  final bool usedRegionalFallback;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final miles = nearestMiles;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: p.liveAccent.withValues(alpha: 0.35)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_off_outlined, color: p.liveAccent, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      usedRegionalFallback
                          ? 'Showing activities near Davao'
                          : 'Nothing within 15 miles',
                      style: textTheme.titleSmall?.copyWith(
                        color: p.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                usedRegionalFallback
                    ? 'GPS is far from $activityCount activities in the app '
                        '(emulator default is California). Browse the regional feed '
                        'or fix location below.'
                    : miles != null
                    ? 'There are $activityCount activities, but the nearest is '
                        '${miles.toStringAsFixed(0)} mi away. Turn off GPS discovery '
                        'or set your emulator/device location near the meetup area.'
                    : 'There are $activityCount activities outside your discovery radius. '
                        'Turn off GPS in Settings or move your device location.',
                style: textTheme.bodySmall?.copyWith(
                  color: p.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      await context
                          .read<SettingsCubit>()
                          .setUseGpsForDiscovery(false);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Using saved discovery anchor (GPS off)'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text('Turn off GPS'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                    child: const Text('Settings'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
