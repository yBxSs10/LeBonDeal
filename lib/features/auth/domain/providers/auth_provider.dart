import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:lebondeal/core/di/injection.dart';
import 'package:lebondeal/core/services/notification_service.dart';
import 'package:lebondeal/features/deals/data/datasources/remote/firestore_service.dart';

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
      final categoryIds = await getIt<FirestoreService>()
          .getFollowedCategoryIdsStream(userId)
          .first;
      await NotificationService.instance.syncFollowedCategories(categoryIds);
    } catch (e) {
      debugPrint('FCM: échec de la resynchronisation des abonnements — $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _error = null;

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      _setLoading(true);
      _error = null;

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _error = null;
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInAnonymously() async {
    try {
      _setLoading(true);
      _error = null;

      await FirebaseAuth.instance.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      default:
        return 'Une erreur est survenue. Veuillez réessayer.';
    }
  }
}
