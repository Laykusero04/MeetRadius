import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/bloc/meet_radius_bloc_observer.dart';
import 'core/theme/theme_cubit.dart';
import 'features/notifications/data/push_notification_service.dart';
import 'features/settings/application/settings_cubit.dart';
import 'features/settings/data/settings_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PushNotificationService.initialize();
  Bloc.observer = MeetRadiusBlocObserver();
  final prefs = await SharedPreferences.getInstance();
  final themeCubit = ThemeCubit(prefs);
  final settingsRepo = SettingsRepository(prefs);
  final settingsCubit = SettingsCubit(settingsRepo)..load();
  runApp(
    MyApp(
      themeCubit: themeCubit,
      settingsCubit: settingsCubit,
    ),
  );
}
