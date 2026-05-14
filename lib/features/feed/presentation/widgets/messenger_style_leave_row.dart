import 'package:flutter/material.dart';

import '../../../../core/theme/meet_radius_palette.dart';

/// Facebook Messenger–style footer: soft bar, status copy, and a plain text
/// action (not a chat bubble or outlined “message” chip).
class MessengerStyleLeaveRow extends StatelessWidget {
  const MessengerStyleLeaveRow({
    super.key,
    required this.onLeave,
    this.enabled = true,
  });

  final VoidCallback? onLeave;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Messenger-like neutral strip (light gray / dark elevated surface).
    final barFill = isDark
        ? p.navBar.withValues(alpha: 0.92)
        : const Color(0xFFF0F2F5);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: barFill,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? p.chipBorder.withValues(alpha: 0.55)
              : const Color(0xFFE4E6EB),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded, size: 22, color: p.brandCyan),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "You're going",
                style: textTheme.bodyMedium?.copyWith(
                  color: p.textPrimary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.15,
                ),
              ),
            ),
            TextButton(
              onPressed: enabled ? onLeave : null,
              style: TextButton.styleFrom(
                foregroundColor: enabled
                    ? (isDark ? p.textSecondary : const Color(0xFF65676B))
                    : p.textMuted,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Leave',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
