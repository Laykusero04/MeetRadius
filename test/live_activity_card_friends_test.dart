import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meet_radius/core/theme/app_theme.dart';
import 'package:meet_radius/features/feed/presentation/widgets/live_activity_card.dart';

void main() {
  testWidgets('LiveActivityCard shows friends attending row', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: LiveActivityCard(
            title: 'Run club',
            startsIn: 'Now',
            distance: '2 mi away',
            joinedLabel: '4 going',
            socialLine: '',
            friendInitials: const ['A', 'J'],
            friendNamesLine: 'Alex, Jordan are going',
            onJoin: () {},
          ),
        ),
      ),
    );

    expect(find.text('Alex, Jordan are going'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('J'), findsOneWidget);
  });
}
