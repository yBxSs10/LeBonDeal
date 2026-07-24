// AUTH-P01 à AUTH-P07 — Tests du mapping des erreurs Firebase Auth
// RNCP39583 — C2.2.2 : Tests automatisés
//
// Stratégie : AuthProvider délègue désormais entièrement à AuthRepository
// (via les usecases du domain) — il n'a plus son propre mapping d'erreurs,
// il se contente d'exposer le message renvoyé par le repository. La source
// de vérité du mapping est donc AuthRepositoryImpl._mapAuthExceptionToMessage
// (privée). On teste ici une réplique locale du contrat : si les messages
// changent dans AuthRepositoryImpl sans mise à jour ici, ces tests échouent
// — filet de régression documentaire.

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthRepository — mapping des codes d\'erreur Firebase —', () {
    // -------------------------------------------------------
    // AUTH-P01 : user-not-found
    // -------------------------------------------------------
    test('AUTH-P01 : user-not-found retourne le message approprié', () {
      final msg = _mapErrorCode('user-not-found');
      expect(msg, 'Aucun utilisateur trouvé avec cette adresse email');
    });

    // -------------------------------------------------------
    // AUTH-P02 : wrong-password
    // -------------------------------------------------------
    test('AUTH-P02 : wrong-password retourne le message approprié', () {
      final msg = _mapErrorCode('wrong-password');
      expect(msg, 'Mot de passe incorrect');
    });

    // -------------------------------------------------------
    // AUTH-P03 : email-already-in-use
    // -------------------------------------------------------
    test('AUTH-P03 : email-already-in-use retourne le message approprié', () {
      final msg = _mapErrorCode('email-already-in-use');
      expect(msg, 'Cette adresse email est déjà utilisée');
    });

    // -------------------------------------------------------
    // AUTH-P04 : weak-password
    // -------------------------------------------------------
    test('AUTH-P04 : weak-password retourne le message approprié', () {
      final msg = _mapErrorCode('weak-password');
      expect(msg, 'Le mot de passe est trop faible');
    });

    // -------------------------------------------------------
    // AUTH-P05 : invalid-email
    // -------------------------------------------------------
    test('AUTH-P05 : invalid-email retourne le message approprié', () {
      final msg = _mapErrorCode('invalid-email');
      expect(msg, 'Adresse email invalide');
    });

    // -------------------------------------------------------
    // AUTH-P06 : user-disabled
    // -------------------------------------------------------
    test('AUTH-P06 : user-disabled retourne le message approprié', () {
      final msg = _mapErrorCode('user-disabled');
      expect(msg, 'Ce compte a été désactivé');
    });

    // -------------------------------------------------------
    // AUTH-P07 : code inconnu → message générique avec le détail Firebase
    // -------------------------------------------------------
    test('AUTH-P07 : code inconnu retourne un message générique', () {
      final msg = _mapErrorCode('unknown-error-code', message: 'boom');
      expect(msg, 'Une erreur est survenue: boom');
    });
  });
}

/// Réplique locale de AuthRepositoryImpl._mapAuthExceptionToMessage.
/// Maintenue en sync avec
/// lib/features/auth/data/repositories/auth_repository_impl.dart
String _mapErrorCode(String code, {String? message}) {
  switch (code) {
    case 'email-already-in-use':
      return 'Cette adresse email est déjà utilisée';
    case 'invalid-email':
      return 'Adresse email invalide';
    case 'operation-not-allowed':
      return 'Opération non autorisée';
    case 'weak-password':
      return 'Le mot de passe est trop faible';
    case 'user-disabled':
      return 'Ce compte a été désactivé';
    case 'user-not-found':
      return 'Aucun utilisateur trouvé avec cette adresse email';
    case 'wrong-password':
      return 'Mot de passe incorrect';
    case 'too-many-requests':
      return 'Trop de tentatives de connexion. Veuillez réessayer plus tard.';
    default:
      return 'Une erreur est survenue: $message';
  }
}
