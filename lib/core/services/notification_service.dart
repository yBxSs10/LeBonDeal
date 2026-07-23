import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Handler background — doit être une fonction top-level
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase est déjà initialisé avant cet appel
  debugPrint('FCM background: ${message.messageId}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // FCM non supporté sur Windows/Linux/macOS desktop
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      debugPrint('FCM: plateforme non supportée ($defaultTargetPlatform)');
      return;
    }

    // 1. Enregistrer le handler background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Demander la permission (iOS + Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('FCM permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // 3. Récupérer le token FCM
    final token = await _messaging.getToken();
    debugPrint('FCM token: $token');

    // 4. Écouter les messages reçus en foreground
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('FCM foreground: ${message.notification?.title}');
      _showInAppBanner(message);
    });

    // 5. Notification tapée depuis background → app ouverte
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('FCM opened from background: ${message.notification?.title}');
    });

    // 6. Notification tapée depuis terminated → app lancée
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      debugPrint('FCM opened from terminated: ${initial.notification?.title}');
    }
  }

  void _showInAppBanner(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    // Utilise le ScaffoldMessenger global via la clé navigateur
    // Le SnackBar s'affiche sur n'importe quel écran actif
    _scaffoldKey?.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.title != null)
              Text(
                notification.title!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            if (notification.body != null) Text(notification.body!),
          ],
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Clé globale pour afficher les SnackBar depuis n'importe où
  ScaffoldMessengerState? _scaffoldKey;
  void setScaffoldMessenger(ScaffoldMessengerState state) {
    _scaffoldKey = state;
  }
}
