import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../activity/presentation/host_activity_screen.dart';
import '../../chat/presentation/chats_hub_screen.dart';
import '../../map/presentation/activity_map_screen.dart';
import '../../menu/presentation/menu_screen.dart';
import 'widgets/feed_body.dart';

/// Main shell: app bar + bottom nav (feed, map, host, chats, menu).
class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  int _navIndex = 0;

  static const _titles = ['Feed', 'Map', 'Host', 'Chats', 'Menu'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.scaffold,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _titles[_navIndex],
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _navIndex,
          children: const [
            FeedBody(),
            ActivityMapScreen(),
            HostActivityScreen(),
            ChatsHubScreen(),
            MenuScreen(),
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
          currentIndex: _navIndex,
          onTap: (i) => setState(() => _navIndex = i),
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
  }
}
