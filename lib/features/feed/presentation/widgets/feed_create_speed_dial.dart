import 'package:flutter/material.dart';
import '../../../../core/theme/meet_radius_palette.dart';
import '../../../activity/presentation/host_activity_screen.dart';
import '../add_gallery_photo_screen.dart';
import '../compose_text_post_screen.dart';

/// Expandable FAB: text post, gallery photo URL, or host new activity (pushed route).
class FeedCreateSpeedDial extends StatefulWidget {
  const FeedCreateSpeedDial({super.key});

  @override
  State<FeedCreateSpeedDial> createState() => _FeedCreateSpeedDialState();
}

class _FeedCreateSpeedDialState extends State<FeedCreateSpeedDial> {
  bool _open = false;

  void _close() => setState(() => _open = false);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: Alignment.bottomRight,
          child: _open
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _DialChild(
                      label: 'Text post',
                      icon: Icons.edit_outlined,
                      backgroundColor: p.surface,
                      foregroundColor: p.textPrimary,
                      heroTag: 'feed_speed_post',
                      onTap: () {
                        _close();
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => const ComposeTextPostScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _DialChild(
                      label: 'Photo',
                      icon: Icons.photo_camera_outlined,
                      backgroundColor: p.surface,
                      foregroundColor: p.textPrimary,
                      heroTag: 'feed_speed_photo',
                      onTap: () {
                        _close();
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => const AddGalleryPhotoScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _DialChild(
                      label: 'Activity',
                      icon: Icons.event_available_outlined,
                      backgroundColor: p.brandCyan,
                      foregroundColor: Colors.white,
                      heroTag: 'feed_speed_activity',
                      onTap: () async {
                        _close();
                        final posted = await Navigator.of(context).push<bool>(
                          MaterialPageRoute<bool>(
                            builder: (ctx) {
                              final p = ctx.palette;
                              return Scaffold(
                                backgroundColor: p.scaffold,
                                appBar: AppBar(
                                  title: const Text('New activity'),
                                  backgroundColor: p.scaffold,
                                  foregroundColor: p.textPrimary,
                                  surfaceTintColor: Colors.transparent,
                                ),
                                body: SafeArea(
                                  child: const HostActivityScreen(),
                                ),
                              );
                            },
                          ),
                        );
                        if (!context.mounted) return;
                        if (posted == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Activity posted.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        FloatingActionButton(
          heroTag: 'feed_speed_main',
          onPressed: () => setState(() => _open = !_open),
          tooltip: _open ? 'Close' : 'Create',
          backgroundColor: p.brandPurple,
          foregroundColor: Colors.white,
          child: Icon(_open ? Icons.close : Icons.add),
        ),
      ],
    );
  }
}

class _DialChild extends StatelessWidget {
  const _DialChild({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.heroTag,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Object heroTag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: p.cardBorderSubtle),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: p.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.small(
            heroTag: heroTag,
            onPressed: onTap,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            elevation: 3,
            child: Icon(icon),
          ),
        ],
      ),
    );
  }
}
