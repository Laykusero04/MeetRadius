import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meet_radius/core/theme/app_theme.dart';
import 'package:meet_radius/core/theme/theme_cubit.dart';
import 'package:meet_radius/features/feed/presentation/home_feed_screen.dart';
import 'package:meet_radius/features/settings/application/settings_cubit.dart';
import 'package:meet_radius/features/settings/data/settings_repository.dart';
import 'package:meet_radius/features/help/presentation/help_support_screen.dart';
import 'package:meet_radius/features/legal/presentation/legal_document_screen.dart';
import 'package:meet_radius/features/legal/presentation/terms_privacy_screen.dart';
import 'package:meet_radius/features/invite/presentation/invite_friends_screen.dart';
import 'package:meet_radius/features/settings/presentation/settings_screen.dart';
import 'package:meet_radius/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on FirebaseException catch (e) {
      if (e.code != 'duplicate-app') rethrow;
    }
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpShell(WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    final themeCubit = ThemeCubit(prefs);
    final settingsCubit = SettingsCubit(SettingsRepository(prefs))..load();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: themeCubit),
          BlocProvider.value(value: settingsCubit),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          buildWhen: (a, b) => a != b,
          builder: (context, themeMode) {
            return MaterialApp(
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeMode,
              home: const HomeFeedScreen(),
            );
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
  }

  testWidgets('Home feed shows static content', (WidgetTester tester) async {
    await pumpShell(tester);

    expect(find.textContaining('15 mi'), findsOneWidget);
    expect(find.text('Live now'), findsOneWidget);
    expect(find.text('Upcoming', skipOffstage: false), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Feed'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Map tab shows flutter map', (WidgetTester tester) async {
    await pumpShell(tester);

    await tester.tap(find.text('Map'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.textContaining('15 mi'), findsWidgets);
  });

  testWidgets('Chats tab shows thread list', (WidgetTester tester) async {
    await pumpShell(tester);

    await tester.tap(find.text('Chats'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Chats'), findsWidgets);
  });

  testWidgets('Feed FAB opens create menu', (WidgetTester tester) async {
    await pumpShell(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Text post'), findsOneWidget);
    expect(find.text('Photo'), findsOneWidget);
    expect(find.text('Activity'), findsOneWidget);
  });

  testWidgets('Menu tab lists account actions', (WidgetTester tester) async {
    await pumpShell(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Menu'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Menu'),
      ),
      findsOneWidget,
    );
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Invite friends'), findsOneWidget);
    expect(find.text('Appearance'), findsNothing);

    await tester.tap(find.text('Settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('PREFERENCES'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Activity reminders'), findsOneWidget);
  });

  testWidgets('Settings screen renders preference toggles',
      (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    final themeCubit = ThemeCubit(prefs);
    final settingsCubit = SettingsCubit(SettingsRepository(prefs))..load();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: themeCubit),
          BlocProvider.value(value: settingsCubit),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Activity reminders'), findsOneWidget);

    await tester.tap(find.text('Activity reminders'));
    await tester.pump();

    expect(settingsCubit.state.notifyActivity, isFalse);
  });

  testWidgets('Invite friends screen prompts sign-in when logged out',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const InviteFriendsScreen(),
      ),
    );
    await tester.pump();

    expect(
      find.text('Sign in to get your personal invite link.'),
      findsOneWidget,
    );
  });

  testWidgets('Help support screen shows FAQs and contact',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const HelpSupportScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('COMMON QUESTIONS'), findsOneWidget);
    expect(find.text('How do I join an activity?'), findsOneWidget);
    expect(find.text('SAFETY TIPS'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Email support@meetradius.app'),
      120,
    );
    expect(find.text('Email support@meetradius.app'), findsOneWidget);
  });

  testWidgets('Terms privacy screen opens legal documents',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const TermsPrivacyScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('LEGAL DOCUMENTS'), findsOneWidget);
    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);

    await tester.tap(find.text('Terms of Service'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(LegalDocumentScreen), findsOneWidget);
    expect(find.text('Agreement'), findsOneWidget);
    expect(find.textContaining('Last updated'), findsWidgets);
  });

  testWidgets('Menu opens invite friends screen', (WidgetTester tester) async {
    await pumpShell(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Menu'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Invite friends'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Invite friends'), findsWidgets);
    expect(
      find.text('Sign in to get your personal invite link.'),
      findsOneWidget,
    );
  });
}
