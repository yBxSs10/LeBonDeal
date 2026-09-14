import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'core/navigation/main_navigation.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/domain.dart';
import 'features/auth/presentation/pages/login_page.dart';

class LebonDealApp extends StatefulWidget {
  const LebonDealApp({super.key});

  @override
  State<LebonDealApp> createState() => _LebonDealAppState();
}

class _LebonDealAppState extends State<LebonDealApp> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = _scaffoldMessengerKey.currentState;
      if (state != null) {
        NotificationService.instance.setScaffoldMessenger(state);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LebonDeal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserEntity?>(
      stream: getIt<AuthRepository>().authStateChanges,
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
