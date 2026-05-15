import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../../../shared/widgets/menu_list_tile.dart';
import '../../invite/presentation/invite_friends_screen.dart';
import '../../profile/data/fetch_public_user_profile.dart';
import '../../profile/domain/user_profile.dart';
import '../data/follow_user.dart';
import '../data/search_users_by_name.dart';
import 'widgets/social_user_list_tile.dart';

/// Strava-style friends hub: people you follow + name search + invite link.
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _searchController = TextEditingController();
  List<({String uid, UserProfile profile})> _searchResults = const [];
  bool _searching = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim();
    if (q == _lastQuery) return;
    _lastQuery = q;
    if (q.length < 2) {
      setState(() {
        _searchResults = const [];
        _searching = false;
      });
      return;
    }
    _runSearch(q);
  }

  Future<void> _runSearch(String query) async {
    setState(() => _searching = true);
    try {
      final results = await searchUsersByName(query);
      if (!mounted || _lastQuery != query) return;
      setState(() {
        _searchResults = results;
        _searching = false;
      });
    } catch (_) {
      if (!mounted || _lastQuery != query) return;
      setState(() {
        _searchResults = const [];
        _searching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: p.scaffold,
      appBar: AppBar(
        title: const Text('Friends'),
        backgroundColor: p.scaffold,
        foregroundColor: p.textPrimary,
        surfaceTintColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabs,
          labelColor: p.textPrimary,
          unselectedLabelColor: p.textMuted,
          indicatorColor: p.liveAccent,
          tabs: const [
            Tab(text: 'Following'),
            Tab(text: 'Find people'),
          ],
        ),
      ),
      body: user == null
          ? Center(
              child: Text(
                'Sign in to manage friends.',
                style: textTheme.bodyLarge?.copyWith(color: p.textSecondary),
              ),
            )
          : TabBarView(
              controller: _tabs,
              children: [
                _FollowingTab(textTheme: textTheme),
                _FindPeopleTab(
                  textTheme: textTheme,
                  searchController: _searchController,
                  searching: _searching,
                  results: _searchResults,
                ),
              ],
            ),
    );
  }
}

class _FollowingTab extends StatelessWidget {
  const _FollowingTab({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return StreamBuilder<List<String>>(
      stream: watchFollowingIds(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Text(
              'Could not load friends.',
              style: textTheme.bodyMedium?.copyWith(color: p.textSecondary),
            ),
          );
        }
        final ids = snap.data;
        if (ids == null) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        if (ids.isEmpty) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _InviteFriendsCard(),
              const SizedBox(height: 20),
              Icon(Icons.people_outline, size: 48, color: p.textMuted),
              const SizedBox(height: 12),
              Text(
                'No one yet',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  color: p.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Follow people you meet at activities, search by name, '
                'or invite friends with your link.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: p.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _InviteFriendsCard(),
            const SizedBox(height: 16),
            Text(
              '${ids.length} following',
              style: textTheme.labelLarge?.copyWith(
                color: p.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...ids.map(
              (uid) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _FollowingUserTile(uid: uid),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FollowingUserTile extends StatelessWidget {
  const _FollowingUserTile({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: fetchPublicUserProfile(uid),
      builder: (context, snap) {
        final profile = snap.data;
        if (profile == null) {
          return const SizedBox(
            height: 64,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        return SocialUserListTile(
          uid: uid,
          profile: profile,
          subtitle: profile.email,
        );
      },
    );
  }
}

class _FindPeopleTab extends StatelessWidget {
  const _FindPeopleTab({
    required this.textTheme,
    required this.searchController,
    required this.searching,
    required this.results,
  });

  final TextTheme textTheme;
  final TextEditingController searchController;
  final bool searching;
  final List<({String uid, UserProfile profile})> results;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search by name',
            prefixIcon: Icon(Icons.search, color: p.textMuted),
            filled: true,
            fillColor: p.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: p.cardBorderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: p.cardBorderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: p.liveAccent, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _InviteFriendsCard(),
        const SizedBox(height: 16),
        if (searchController.text.trim().length < 2)
          Text(
            'Type at least 2 characters to search members.',
            style: textTheme.bodySmall?.copyWith(color: p.textMuted),
          )
        else if (searching)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (results.isEmpty)
          Text(
            'No members found for "${searchController.text.trim()}".',
            style: textTheme.bodyMedium?.copyWith(color: p.textSecondary),
          )
        else
          ...results.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SocialUserListTile(
                uid: row.uid,
                profile: row.profile,
                subtitle: row.profile.email,
              ),
            ),
          ),
      ],
    );
  }
}

class _InviteFriendsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MenuListTile(
      icon: Icons.link,
      label: 'Invite friends',
      subtitle: 'Share your link — we connect you when they join',
      onTap: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const InviteFriendsScreen(),
          ),
        );
      },
    );
  }
}
