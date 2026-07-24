import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:lebondeal/core/di/injection.dart';
import 'package:lebondeal/core/services/notification_service.dart';
import 'package:lebondeal/features/auth/domain/domain.dart';
import 'package:lebondeal/features/profile/domain/domain.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();
    if (_user != null) _syncNotificationSubscriptions(_user!.uid);

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
      if (user != null) _syncNotificationSubscriptions(user.uid);
    });
  }

  // Réabonne l'appareil aux topics FCM des catégories suivies par
  // l'utilisateur — nécessaire car les abonnements aux topics sont propres à
  // l'installation et ne survivent pas à une réinstallation ou un nouvel
  // appareil. Best-effort : ne doit jamais bloquer le flux d'authentification.
  Future<void> _syncNotificationSubscriptions(String userId) async {
    try {
      final categoryIds = await GetFollowedCategoryIdsUseCase(
        getIt<ProfileRepository>(),
      )(userId).first;
      await NotificationService.instance.syncFollowedCategories(categoryIds);
    } catch (e) {
      debugPrint('FCM: échec de la resynchronisation des abonnements — $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _error = null;

      final result = await SignInWithEmailAndPassword(getIt<AuthRepository>())(
        email: email,
        password: password,
      );
      result.fold((error) {
        _error = error;
        throw Exception(error);
      }, (_) {});
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(String email, String password, String displayName) async {
    try {
      _setLoading(true);
      _error = null;

      final result = await SignUpWithEmailAndPassword(getIt<AuthRepository>())(
        email: email,
        password: password,
        displayName: displayName,
      );
      result.fold((error) {
        _error = error;
        throw Exception(error);
      }, (_) {});
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await SignOut(getIt<AuthRepository>())();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _error = null;

      final result = await SendPasswordResetEmail(getIt<AuthRepository>())(
        email,
      );
      result.fold((error) {
        _error = error;
        throw Exception(error);
      }, (_) {});
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _setLoading(true);
      _error = null;

      final result = await getIt<AuthRepository>().signInWithGoogle();
      result.fold((error) => _error = error, (_) {});
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInAnonymously() async {
    try {
      _setLoading(true);
      _error = null;

      final result = await SignInAnonymously(getIt<AuthRepository>())();
      result.fold((error) {
        _error = error;
        throw Exception(error);
      }, (_) {});
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
