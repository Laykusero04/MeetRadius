import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../../../shared/widgets/brand_gradient.dart';
import '../../activity/data/watch_hosted_activities.dart';
import '../../activity/domain/activity.dart';
import '../../activity/domain/activity_capacity_labels.dart';
import '../../activity/presentation/host_activity_actions_sheet.dart';
import '../../activity/presentation/feed_activity_detail_screen.dart';
import '../../feed/presentation/widgets/activity_feed_labels.dart';
import '../data/watch_current_user_profile.dart';
import '../data/watch_my_gallery.dart';
import '../domain/gallery_post.dart';
import '../domain/user_profile.dart';

/// Profile: TikTok-style header + two tabs (hosted activities / image posts).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile?>(
      stream: watchCurrentUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not load profile.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.palette.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.data == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        final profile = snapshot.data;
        if (profile == null) {
          return Center(
            child: Text(
              'Sign in to see your profile.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
          );
        }
        return _ProfileTikTokLayout(profile: profile);
      },
    );
  }
}

class _ProfileTikTokLayout extends StatefulWidget {
  const _ProfileTikTokLayout({required this.profile});

  final UserProfile profile;

  @override
  State<_ProfileTikTokLayout> createState() => _ProfileTikTokLayoutState();
}

class _ProfileTikTokLayoutState extends State<_ProfileTikTokLayout>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final profile = widget.profile;
    final textTheme = Theme.of(context).textTheme;
    final p = context.palette;
    final first = profile.firstName?.trim() ?? '';
    final last = profile.lastName?.trim() ?? '';
    final showDetails = first.isNotEmpty || last.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradientAvatar(
                outerRadius: 40,
                backgroundColor: p.avatarPurple,
                child: Text(
                  profile.initials,
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: textTheme.titleLarge?.copyWith(
                        color: p.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.memberSinceLine,
                      style: textTheme.bodyMedium?.copyWith(
                        color: p.textSecondary,
                      ),
                    ),
                    if (profile.email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        profile.email,
                        style: textTheme.bodySmall?.copyWith(
                          color: p.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: StreamBuilder<List<Activity>>(
                  stream: watchHostedActivities(uid),
                  builder: (context, snap) {
                    final n = snap.hasData ? snap.data!.length : null;
                    return _StatCell(
                      value: n,
                      label: 'Activities',
                      palette: p,
                      textTheme: textTheme,
                    );
                  },
                ),
              ),
              Container(width: 1, height: 36, color: p.cardBorderSubtle),
              Expanded(
                child: StreamBuilder<List<GalleryPost>>(
                  stream: watchMyGallery(uid),
                  builder: (context, snap) {
                    final n = snap.hasData ? snap.data!.length : null;
                    return _StatCell(
                      value: n,
                      label: 'Posts',
                      palette: p,
                      textTheme: textTheme,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (showDetails) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                title: Text(
                  'Account details',
                  style: textTheme.titleSmall?.copyWith(
                    color: p.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                children: [
                  if (first.isNotEmpty)
                    _DetailRow(label: 'First name', value: first),
                  if (first.isNotEmpty && last.isNotEmpty)
                    const SizedBox(height: 10),
                  if (last.isNotEmpty)
                    _DetailRow(label: 'Last name', value: last),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 4),
        TabBar(
          controller: _tabController,
          labelColor: p.textPrimary,
          unselectedLabelColor: p.textMuted,
          indicatorColor: p.brandCyan,
          indicatorWeight: 2.5,
          tabs: const [
            Tab(
              height: 44,
              icon: Icon(Icons.view_list_rounded, size: 22),
              text: 'Activities',
            ),
            Tab(
              height: 44,
              icon: Icon(Icons.photo_library_outlined, size: 22),
              text: 'Photos',
            ),
          ],
        ),
        Divider(height: 1, thickness: 1, color: p.cardBorderSubtle),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _HostedActivitiesTab(uid: uid),
              _GalleryPhotosTab(uid: uid),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    required this.palette,
    required this.textTheme,
  });

  final int? value;
  final String label;
  final MeetRadiusPalette palette;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final text = value == null ? '—' : '$value';
    return Column(
      children: [
        Text(
          text,
          style: textTheme.titleLarge?.copyWith(
            color: palette.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: palette.textMuted,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _HostedActivitiesTab extends StatelessWidget {
  const _HostedActivitiesTab({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return StreamBuilder<List<Activity>>(
      stream: watchHostedActivities(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Could not load activities.',
              style: textTheme.bodyMedium?.copyWith(color: p.textSecondary),
              textAlign: TextAlign.center,
            ),
          );
        }
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: p.brandCyan,
            ),
          );
        }
        final list = snapshot.data!;
        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note_outlined, size: 52, color: p.textMuted),
                  const SizedBox(height: 16),
                  Text(
                    'No activities yet',
                    style: textTheme.titleMedium?.copyWith(
                      color: p.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use the + button on Feed → Activity to create one — it will show up in this list.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: p.textSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) =>
              _HostedActivityListCard(activity: list[i]),
        );
      },
    );
  }
}

IconData _hostingCategoryIcon(String category) {
  return switch (category) {
    'Sports' => Icons.sports_basketball,
    'Coffee' => Icons.local_cafe_outlined,
    'Social' => Icons.groups_2_outlined,
    'Outdoor' => Icons.terrain_outlined,
    'Gym' => Icons.fitness_center,
    'Study' => Icons.menu_book_outlined,
    'Food' => Icons.restaurant_outlined,
    'Music' => Icons.music_note_outlined,
    'Other' => Icons.more_horiz,
    _ => Icons.event,
  };
}

Future<void> _showHostedActivitySheet(BuildContext context, Activity a) {
  return showHostActivityActionsSheet(context, a);
}

class _HostedActivityListCard extends StatelessWidget {
  const _HostedActivityListCard({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final schedule = activitySchedulePill(activity.startsAt);
    final title = activity.title.isEmpty ? activity.category : activity.title;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.cardBorderSubtle),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => openFeedActivityDetail(
                    context,
                    activityId: activity.id,
                    activityTitle: activity.title,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: BrandGradient.buttonFill(p),
                            border: Border.all(
                              color: p.chipBorder.withValues(alpha: 0.45),
                            ),
                          ),
                          child: Icon(
                            _hostingCategoryIcon(activity.category),
                            color: Colors.white.withValues(alpha: 0.95),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: textTheme.titleSmall?.copyWith(
                                        color: p.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _HostingStatusChip(isLive: activity.isLive),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.schedule, size: 15, color: p.textMuted),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      schedule,
                                      style: textTheme.labelMedium?.copyWith(
                                        color: p.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.place_outlined,
                                    size: 15,
                                    color: p.textMuted,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      activity.spot.isEmpty
                                          ? 'Location TBD'
                                          : activity.spot,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: p.textMuted,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                activityGoingLabel(activity),
                                style: textTheme.labelSmall?.copyWith(
                                  color: p.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 2, top: 10),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: p.textMuted,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Edit or delete',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                icon: Icon(Icons.more_vert_rounded, color: p.textMuted),
                onPressed: () => _showHostedActivitySheet(context, activity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HostingStatusChip extends StatelessWidget {
  const _HostingStatusChip({required this.isLive});

  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    if (isLive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: p.liveAccent.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: p.liveBorder.withValues(alpha: 0.55)),
        ),
        child: Text(
          'LIVE',
          style: textTheme.labelSmall?.copyWith(
            color: p.liveAccent,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            fontSize: 10,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: p.upcomingBlue.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.upcomingBlue.withValues(alpha: 0.35)),
      ),
      child: Text(
        'Soon',
        style: textTheme.labelSmall?.copyWith(
          color: p.upcomingBlue,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _GalleryPhotosTab extends StatelessWidget {
  const _GalleryPhotosTab({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return StreamBuilder<List<GalleryPost>>(
      stream: watchMyGallery(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not load photos. Check Firestore rules for users/{you}/gallery.',
                style: textTheme.bodyMedium?.copyWith(color: p.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: p.brandCyan,
            ),
          );
        }
        final list = snapshot.data!;
        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 52,
                    color: p.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No photo posts yet',
                    style: textTheme.titleMedium?.copyWith(
                      color: p.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'When you save images to Firestore at users/your-uid/gallery with an imageUrl field, they appear here in a grid.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: p.textSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(2, 6, 2, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            childAspectRatio: 1,
          ),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final post = list[i];
            return Material(
              color: p.surface,
              child: InkWell(
                onTap: () {},
                child: Image.network(
                  post.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: p.brandCyan,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => ColoredBox(
                    color: p.card,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: p.textMuted,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: context.palette.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: context.palette.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
