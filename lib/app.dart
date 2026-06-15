import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'core/navigation/main_navigation.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';

class LebonDealApp extends StatelessWidget {
  const LebonDealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LebonDeal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: GetIt.I<FirebaseAuth>().authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Erreur Firebase: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return snapshot.hasData ? const MainNavigation() : const LoginPage();
      },
    );
  }
}
