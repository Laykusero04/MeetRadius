import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meet_radius/app.dart';

void main() {
  testWidgets('Home feed shows static content', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Davao City · 15 mi'), findsOneWidget);
    expect(find.textContaining('LIVE NOW'), findsOneWidget);
    expect(find.text('UPCOMING', skipOffstage: false), findsOneWidget);
    expect(find.text('Need 2 basketball players'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Feed'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Map tab shows flutter map', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Map'));
    await tester.pumpAndSettle();

    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.textContaining('Davao City'), findsWidgets);
  });

  testWidgets('Chats tab shows thread list', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Chats'));
    await tester.pumpAndSettle();

    expect(find.text('Chats'), findsWidgets);
    expect(find.textContaining('Pickup basketball'), findsOneWidget);
    expect(find.textContaining('Coffee meetup'), findsOneWidget);
  });

  testWidgets('Host tab shows host form', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Host'));
    await tester.pumpAndSettle();

    expect(find.text('Host'), findsWidgets);
    expect(find.text('Post activity'), findsOneWidget);
    expect(find.text('ACTIVITY TYPE'), findsOneWidget);
  });

  testWidgets('Menu tab lists account actions', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Menu'),
      ),
    );
    await tester.pumpAndSettle();

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
    await tester.pumpAndSettle();

    expect(find.text('Matt'), findsOneWidget);
    expect(find.text('Member since Jan 2025'), findsOneWidget);
    expect(find.text('6-week streak'), findsOneWidget);
    expect(find.text('BADGES'), findsOneWidget);
  });
}
