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
    await tester.pumpWidget(
      BlocProvider.value(
        value: themeCubit,
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

    expect(find.text('Davao City · 15 mi'), findsOneWidget);
    expect(find.textContaining('LIVE NOW'), findsOneWidget);
    expect(find.text('UPCOMING', skipOffstage: false), findsOneWidget);
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
    expect(find.textContaining('Davao City'), findsWidgets);
  });

  testWidgets('Chats tab shows thread list', (WidgetTester tester) async {
    await pumpShell(tester);

    await tester.tap(find.text('Chats'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Chats'), findsWidgets);
  });

  testWidgets('Host tab shows host form', (WidgetTester tester) async {
    await pumpShell(tester);

    await tester.tap(find.text('Host'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Host'), findsWidgets);
    expect(find.text('New activity'), findsOneWidget);
    expect(find.textContaining('Step 1 of 3'), findsOneWidget);
    expect(find.text('ACTIVITY TYPE'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
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

    await tester.tap(find.text('Profile'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Profile'), findsWidgets);
  });
}
