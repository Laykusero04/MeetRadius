import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/deep_links/deep_link_listener.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/settings/application/settings_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.themeCubit,
    required this.settingsCubit,
  });

  final ThemeCubit themeCubit;
  final SettingsCubit settingsCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: themeCubit),
        BlocProvider.value(value: settingsCubit),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'MeetRadius',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            home: DeepLinkListener(
              child: const AuthGate(),
            ),
            routes: {
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
            },
          );
        },
      ),
    );
  }
}
