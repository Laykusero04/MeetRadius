import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../settings/application/settings_cubit.dart';
import '../data/sync_due_hosted_activities.dart';

/// Runs client-side scheduled-end sync when the app resumes (no Cloud Functions).
class ActivityLifecycleListener extends StatefulWidget {
  const ActivityLifecycleListener({super.key, required this.child});

  final Widget child;

  @override
  State<ActivityLifecycleListener> createState() =>
      _ActivityLifecycleListenerState();
}

class _ActivityLifecycleListenerState extends State<ActivityLifecycleListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    syncDueHostedActivities();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SettingsCubit>().syncNotificationPrefsFromState();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      syncDueHostedActivities();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
