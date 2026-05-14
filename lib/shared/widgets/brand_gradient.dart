import 'package:flutter/material.dart';

import '../../core/theme/meet_radius_palette.dart';

/// Logo-style cyan → purple gradients.
abstract final class BrandGradient {
  static LinearGradient horizontal(MeetRadiusPalette p) {
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [p.brandCyan, p.brandPurple, p.brandPurpleDeep],
      stops: const [0.0, 0.55, 1.0],
    );
  }

  /// Slightly softer fill for buttons (still reads as gradient).
  static LinearGradient buttonFill(MeetRadiusPalette p) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        p.brandCyan.withValues(alpha: 0.92),
        p.brandPurple.withValues(alpha: 0.88),
      ],
    );
  }
}

/// Circular avatar with a cyan→purple gradient ring.
class GradientAvatar extends StatelessWidget {
  const GradientAvatar({
    super.key,
    required this.outerRadius,
    required this.backgroundColor,
    required this.child,
    this.strokeWidth = 2.5,
  });

  /// Half of outer diameter (matches [CircleAvatar.radius] sizing).
  final double outerRadius;
  final Color backgroundColor;
  final Widget child;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final innerRadius = (outerRadius - strokeWidth).clamp(4.0, outerRadius);
    final size = outerRadius * 2;
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: BrandGradient.horizontal(p),
        ),
        child: Padding(
          padding: EdgeInsets.all(strokeWidth),
          child: ClipOval(
            child: CircleAvatar(
              radius: innerRadius,
              backgroundColor: backgroundColor,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Primary CTA: gradient border ring + gradient fill, full-width, ink splash.
class GradientCtaButton extends StatelessWidget {
  const GradientCtaButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.borderRadius = 24,
    this.borderWidth = 1.5,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final enabled = onPressed != null;
    final outerR = borderRadius + borderWidth;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(outerR),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(outerR),
          onTap: onPressed,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(outerR),
              gradient: BrandGradient.horizontal(p),
            ),
            child: AnimatedOpacity(
              opacity: enabled ? 1 : 0.45,
              duration: const Duration(milliseconds: 150),
              child: Padding(
                padding: EdgeInsets.all(borderWidth),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    gradient: BrandGradient.buttonFill(p),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Padding(
                    padding: padding,
                    child: Center(
                      child: DefaultTextStyle.merge(
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        child: IconTheme.merge(
                          data: const IconThemeData(
                            color: Colors.white,
                            size: 22,
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
