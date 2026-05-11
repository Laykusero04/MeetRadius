import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/feed/presentation/home_feed_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeetRadius',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const HomeFeedScreen(),
    );
  }
}
