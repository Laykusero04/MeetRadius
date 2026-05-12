import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/navigation/main_shell_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../activity/presentation/host_activity_screen.dart';
import '../../chat/presentation/chats_hub_screen.dart';
import '../../map/presentation/activity_map_screen.dart';
import '../../menu/presentation/menu_screen.dart';
import '../application/feed_filter_cubit.dart';
import 'widgets/feed_body.dart';

/// Main shell: app bar + bottom nav (feed, map, host, chats, menu).
class HomeFeedScreen extends StatelessWidget {
  const HomeFeedScreen({super.key});

  static const _titles = ['Feed', 'Map', 'Host', 'Chats', 'Menu'];

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
        return Scaffold(
          backgroundColor: AppColors.scaffold,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.scaffold,
            foregroundColor: AppColors.textPrimary,
            surfaceTintColor: Colors.transparent,
            title: Text(
              HomeFeedScreen._titles[shell.currentIndex],
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
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
                const HostActivityScreen(),
                const ChatsHubScreen(),
                const MenuScreen(),
              ],
            ),
          ),
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
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
                  icon: Icon(Icons.add_circle_outline),
                  label: 'Host',
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
          ),
        );
      },
    );
  }
}
