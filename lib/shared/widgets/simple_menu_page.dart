import 'package:flutter/material.dart';

import '../../core/theme/meet_radius_palette.dart';

/// Lightweight placeholder for Settings, Help, etc.
class SimpleMenuPage extends StatelessWidget {
  const SimpleMenuPage({
    super.key,
    required this.title,
    this.message = 'Coming soon.',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.scaffold,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: p.scaffold,
        foregroundColor: p.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: p.textSecondary,
                ),
          ),
        ),
      ),
    );
  }
}
