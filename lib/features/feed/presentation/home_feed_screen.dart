import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/navigation/main_shell_cubit.dart';
import '../../../core/theme/meet_radius_palette.dart';
import '../../../shared/widgets/brand_gradient.dart';
import '../../chat/presentation/chats_hub_screen.dart';
import '../../map/presentation/activity_map_screen.dart';
import '../../menu/presentation/menu_screen.dart';
import '../application/feed_filter_cubit.dart';
import 'notifications_screen.dart';
import 'widgets/feed_body.dart';
import 'widgets/feed_create_speed_dial.dart';

/// Main shell: app bar + bottom nav (feed, map, chats, menu).
class HomeFeedScreen extends StatelessWidget {
  const HomeFeedScreen({super.key});

  static const _titles = ['Feed', 'Map', 'Chats', 'Menu'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MainShellCubit(),
      child: const _HomeFeedView(),
    );
  }
}

class _HomeFeedView extends StatelessWidget {
  const _HomeFeedView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainShellCubit, ({int currentIndex})>(
      builder: (context, shell) {
        final p = context.palette;
        return Scaffold(
          backgroundColor: p.scaffold,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: p.scaffold,
            foregroundColor: p.textPrimary,
            surfaceTintColor: Colors.transparent,
            title: Text(
              HomeFeedScreen._titles[shell.currentIndex],
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              IconButton(
                tooltip: 'Notifications',
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_outlined),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: IndexedStack(
              index: shell.currentIndex,
              children: [
                BlocProvider(
                  create: (_) => FeedFilterCubit(),
                  child: const FeedBody(),
                ),
                const ActivityMapScreen(),
                const ChatsHubScreen(),
                const MenuScreen(),
              ],
            ),
          ),
          floatingActionButton:
              shell.currentIndex == 0 ? const FeedCreateSpeedDial() : null,
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 2,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: BrandGradient.horizontal(p),
                  ),
                ),
                BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: shell.currentIndex,
              onTap: context.read<MainShellCubit>().selectTab,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Feed',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map_outlined),
                  label: 'Map',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline),
                  label: 'Chats',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  activeIcon: Icon(Icons.menu_open),
                  label: 'Menu',
                ),
              ],
            ),
              ],
            ),
          ),
        );
      },
    );
  }
}
