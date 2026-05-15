import 'package:flutter/material.dart';

import '../../../../shared/widgets/menu_list_tile.dart';

/// Settings navigation row (chevron).
class SettingsNavTile extends StatelessWidget {
  const SettingsNavTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return MenuListTile(
      icon: icon,
      label: label,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}
