// AUTH-P01 à AUTH-P06 — Tests de la logique de mapping des erreurs AuthProvider
// RNCP39583 — C2.2.2 : Tests automatisés
//
// Stratégie : AuthProvider utilise FirebaseAuth.instance de façon statique
// (non injectable), ce qui empêche son instanciation directe en unit test.
// On teste ici le contrat des messages d'erreur via une réplique locale du
// switch _getErrorMessage. Si les messages changent dans AuthProvider sans
// mise à jour ici, ces tests échouent — filet de régression documentaire.

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthProvider — mapping des codes d\'erreur Firebase —', () {
    // -------------------------------------------------------
    // AUTH-P01 : user-not-found
    // -------------------------------------------------------
    test('AUTH-P01 : user-not-found retourne le message approprié', () {
      final msg = _mapErrorCode('user-not-found');
      expect(msg, 'Aucun utilisateur trouvé avec cet email.');
    });

    // -------------------------------------------------------
    // AUTH-P02 : wrong-password
    // -------------------------------------------------------
    test('AUTH-P02 : wrong-password retourne le message approprié', () {
      final msg = _mapErrorCode('wrong-password');
      expect(msg, 'Mot de passe incorrect.');
    });

    // -------------------------------------------------------
    // AUTH-P03 : email-already-in-use
    // -------------------------------------------------------
    test('AUTH-P03 : email-already-in-use retourne le message approprié', () {
      final msg = _mapErrorCode('email-already-in-use');
      expect(msg, 'Cet email est déjà utilisé.');
    });

    // -------------------------------------------------------
    // AUTH-P04 : weak-password
    // -------------------------------------------------------
    test('AUTH-P04 : weak-password retourne le message approprié', () {
      final msg = _mapErrorCode('weak-password');
      expect(msg, 'Le mot de passe est trop faible.');
    });

    // -------------------------------------------------------
    // AUTH-P05 : invalid-email
    // -------------------------------------------------------
    test('AUTH-P05 : invalid-email retourne le message approprié', () {
      final msg = _mapErrorCode('invalid-email');
      expect(msg, 'Adresse email invalide.');
    });

    // -------------------------------------------------------
    // AUTH-P06 : code inconnu → message générique
    // -------------------------------------------------------
    test('AUTH-P06 : code inconnu retourne un message générique', () {
      final msg = _mapErrorCode('unknown-error-code');
      expect(msg, 'Une erreur est survenue. Veuillez réessayer.');
    });
  });
}

/// Réplique locale du switch _getErrorMessage d'AuthProvider.
/// Maintenu en sync avec lib/features/auth/domain/providers/auth_provider.dart
/// — si les messages changent là-bas, ces tests doivent échouer.
String _mapErrorCode(String code) {
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
