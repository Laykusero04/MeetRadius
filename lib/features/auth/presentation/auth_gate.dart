import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../../feed/presentation/home_feed_screen.dart';
import 'login_screen.dart';

/// Routes to [HomeFeedScreen] when Firebase has a session, otherwise [LoginScreen].
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          final p = context.palette;
          return Scaffold(
            backgroundColor: p.scaffold,
            body: Center(
              child: SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: p.liveAccent.withValues(alpha: 0.9),
                ),
              ),
            ),
          );
        }
        if (snapshot.data != null) {
          return const HomeFeedScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
