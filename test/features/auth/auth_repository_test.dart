// AUTH-001 à AUTH-005 — Tests du repository d'authentification
// RNCP39583 — C2.2.2 : Tests automatisés
//
// Stratégie : on injecte un MockFirebaseAuth pour ne pas dépendre
// du réseau Firebase — les tests sont déterministes et rapides.

import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lebondeal/features/auth/data/repositories/auth_repository_impl.dart';

void main() {
  group('AuthRepository —', () {
    // -------------------------------------------------------
    // AUTH-001 : Connexion avec des identifiants valides
    // -------------------------------------------------------
    test('AUTH-001 : signIn avec email/password valides retourne UserEntity', () async {
      // ARRANGE — utilisateur pré-enregistré dans le mock
      final mockUser = MockUser(
        uid: 'uid_test_001',
        email: 'test@lebondeal.fr',
        displayName: 'Testeur LBD',
      );
      final mockAuth = MockFirebaseAuth(mockUser: mockUser);
      final repo = AuthRepositoryImpl(firebaseAuth: mockAuth);

      // ACT
      final result = await repo.signInWithEmailAndPassword(
        email: 'test@lebondeal.fr',
        password: 'password123',
      );

      // ASSERT
      expect(result.isRight(), true);
      result.fold(
        (error) => fail('Ne devrait pas retourner une erreur'),
        (user) {
          expect(user.email, 'test@lebondeal.fr');
          expect(user.id, 'uid_test_001');
          expect(user.displayName, 'Testeur LBD');
        },
      );
    });

    // -------------------------------------------------------
    // AUTH-002 : Inscription crée un nouveau compte
    // -------------------------------------------------------
    test('AUTH-002 : createUser retourne un UserEntity avec displayName', () async {
      // ARRANGE
      final mockAuth = MockFirebaseAuth();
      final repo = AuthRepositoryImpl(firebaseAuth: mockAuth);

      // ACT
      final result = await repo.createUserWithEmailAndPassword(
        email: 'nouveau@lebondeal.fr',
        password: 'securePass456',
        displayName: 'Nouveau Utilisateur',
      );

      // ASSERT
      expect(result.isRight(), true);
      result.fold(
        (error) => fail('Ne devrait pas retourner une erreur'),
        (user) {
          expect(user.email, 'nouveau@lebondeal.fr');
          expect(user.id, isNotEmpty);
        },
      );
    });

    // -------------------------------------------------------
    // AUTH-003 : Déconnexion vide la session
    // -------------------------------------------------------
    test('AUTH-003 : signOut retourne Right(unit) et déconnecte', () async {
      // ARRANGE
      final mockUser = MockUser(uid: 'uid_test_003', email: 'user@test.fr');
      final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      final repo = AuthRepositoryImpl(firebaseAuth: mockAuth);

      // ACT
      final result = await repo.signOut();

      // ASSERT
      expect(result.isRight(), true);
      expect(repo.currentUser, isNull);
    });

    // -------------------------------------------------------
    // AUTH-004 : currentUser retourne null si non connecté
    // -------------------------------------------------------
    test('AUTH-004 : currentUser est null quand non authentifié', () async {
      // ARRANGE
      final mockAuth = MockFirebaseAuth(signedIn: false);
      final repo = AuthRepositoryImpl(firebaseAuth: mockAuth);

      // ASSERT
      expect(repo.currentUser, isNull);
    });

    // -------------------------------------------------------
    // AUTH-005 : authStateChanges émet l'utilisateur connecté
    // -------------------------------------------------------
    test('AUTH-005 : authStateChanges émet un UserEntity après connexion', () async {
      // ARRANGE
      final mockUser = MockUser(
        uid: 'uid_test_005',
        email: 'stream@lebondeal.fr',
      );
      // signedIn: true → le stream émet directement l'utilisateur connecté
      final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      final repo = AuthRepositoryImpl(firebaseAuth: mockAuth);

      // ASSERT — le stream doit émettre au moins un UserEntity non null
      expect(
        repo.authStateChanges,
        emitsThrough(isNotNull),
      );
    });
  });
}
