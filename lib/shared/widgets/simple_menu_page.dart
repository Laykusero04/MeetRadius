import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

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
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.scaffold,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
      ),
    );
  }
}
