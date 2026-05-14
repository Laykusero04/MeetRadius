import 'package:flutter/material.dart';

import '../../../core/theme/meet_radius_palette.dart';

/// Photo uploads from the feed are not available yet.
class AddGalleryPhotoScreen extends StatelessWidget {
  const AddGalleryPhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: p.scaffold,
      appBar: AppBar(
        title: const Text('Photo'),
        backgroundColor: p.scaffold,
        foregroundColor: p.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_camera_outlined,
                  size: 56,
                  color: p.textMuted,
                ),
                const SizedBox(height: 20),
                Text(
                  'Coming soon',
                  style: textTheme.headlineSmall?.copyWith(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Sharing photos from here will be available in a future update.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: p.textSecondary,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
