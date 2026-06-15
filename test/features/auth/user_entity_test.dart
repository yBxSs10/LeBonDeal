// Tests de l'entité UserEntity
// RNCP39583 — C2.2.2 : Tests automatisés

import 'package:flutter_test/flutter_test.dart';
import 'package:lebondeal/features/auth/domain/entities/user_entity.dart';

void main() {
  group('UserEntity —', () {
    const user = UserEntity(
      id: 'uid_001',
      email: 'test@lebondeal.fr',
      displayName: 'Testeur LBD',
      photoUrl: 'https://example.com/avatar.jpg',
    );

    // -------------------------------------------------------
    // USER-001 : Création avec tous les champs
    // -------------------------------------------------------
    test('USER-001 : crée une entité avec tous les champs requis', () {
      expect(user.id, 'uid_001');
      expect(user.email, 'test@lebondeal.fr');
      expect(user.displayName, 'Testeur LBD');
      expect(user.photoUrl, 'https://example.com/avatar.jpg');
    });

    // -------------------------------------------------------
    // USER-002 : Champs optionnels null par défaut
    // -------------------------------------------------------
    test('USER-002 : les champs optionnels sont null par défaut', () {
      const minimal = UserEntity(id: 'uid_002', email: 'a@b.fr');
      expect(minimal.displayName, isNull);
      expect(minimal.photoUrl, isNull);
    });

    // -------------------------------------------------------
    // USER-003 : copyWith préserve les champs non modifiés
    // -------------------------------------------------------
    test('USER-003 : copyWith préserve les champs non modifiés', () {
      final updated = user.copyWith(displayName: 'Nouveau Nom');
      expect(updated.id, 'uid_001');
      expect(updated.email, 'test@lebondeal.fr');
      expect(updated.displayName, 'Nouveau Nom');
      expect(updated.photoUrl, 'https://example.com/avatar.jpg');
    });

    // -------------------------------------------------------
    // USER-004 : toJson sérialise tous les champs
    // -------------------------------------------------------
    test('USER-004 : toJson retourne un Map avec tous les champs', () {
      final json = user.toJson();
      expect(json['id'], 'uid_001');
      expect(json['email'], 'test@lebondeal.fr');
      expect(json['displayName'], 'Testeur LBD');
      expect(json['photoUrl'], 'https://example.com/avatar.jpg');
    });

    // -------------------------------------------------------
    // USER-005 : fromJson désérialise correctement
    // -------------------------------------------------------
    test('USER-005 : fromJson reconstruit l\'entité depuis un Map', () {
      final json = {
        'id': 'uid_003',
        'email': 'from@json.fr',
        'displayName': 'JSON User',
        'photoUrl': null,
      };
      final entity = UserEntity.fromJson(json);
      expect(entity.id, 'uid_003');
      expect(entity.email, 'from@json.fr');
      expect(entity.displayName, 'JSON User');
      expect(entity.photoUrl, isNull);
    });

    // -------------------------------------------------------
    // USER-006 : Équalité via Equatable
    // -------------------------------------------------------
    test('USER-006 : deux entités avec les mêmes valeurs sont égales', () {
      const user2 = UserEntity(
        id: 'uid_001',
        email: 'test@lebondeal.fr',
        displayName: 'Testeur LBD',
        photoUrl: 'https://example.com/avatar.jpg',
      );
      expect(user, equals(user2));
    });

    // -------------------------------------------------------
    // USER-007 : toJson / fromJson — aller-retour sans perte
    // -------------------------------------------------------
    test('USER-007 : toJson puis fromJson donne la même entité', () {
      final roundTrip = UserEntity.fromJson(user.toJson());
      expect(roundTrip, equals(user));
    });
  });
}
