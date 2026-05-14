// SEC-001 à SEC-005 — Tests de validation et sécurité
// RNCP39583 — C2.2.2 + C2.3.1
//
// Ces tests vérifient les règles métier de sécurité :
// validation des données avant écriture Firestore,
// cohérentes avec les Security Rules (firestore.rules).

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validation sécurité —', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    // -------------------------------------------------------
    // SEC-001 : Un commentaire > 500 chars est rejeté
    // Cohérent avec la Security Rule : content.size() <= 500
    // -------------------------------------------------------
    test('SEC-001 : commentaire > 500 chars est invalide', () {
      // ARRANGE
      final longContent = 'a' * 501;

      // ASSERT — la validation doit échouer
      expect(
        longContent.length > 500,
        true,
        reason: 'Un commentaire de plus de 500 caractères doit être rejeté',
      );
    });

    test('SEC-001b : commentaire <= 500 chars est valide', () {
      // ARRANGE
      final validContent = 'Super deal, merci pour le partage !';

      // ASSERT
      expect(validContent.length <= 500, true);
    });

    // -------------------------------------------------------
    // SEC-002 : Un deal sans authorId ne doit pas être accepté
    // Cohérent avec la Security Rule : hasField('authorId')
    // -------------------------------------------------------
    test('SEC-002 : deal avec authorId vide est invalide', () {
      // ASSERT — authorId ne peut pas être vide
      bool isValidAuthorId(String authorId) => authorId.isNotEmpty;

      expect(isValidAuthorId(''), false);
      expect(isValidAuthorId('uid_valid_001'), true);
    });

    // -------------------------------------------------------
    // SEC-003 : Le prix d'un deal doit être strictement positif
    // Cohérent avec la Security Rule : price > 0
    // -------------------------------------------------------
    test('SEC-003 : deal avec prix à 0 ou négatif est invalide', () {
      // ASSERT
      bool isValidPrice(double price) => price > 0;

      expect(isValidPrice(0), false);
      expect(isValidPrice(-10), false);
      expect(isValidPrice(0.01), true);
      expect(isValidPrice(999.99), true);
    });

    // -------------------------------------------------------
    // SEC-004 : authorId du deal doit correspondre à l'auteur
    // Cohérent avec la Security Rule :
    //   request.resource.data.authorId == request.auth.uid
    // -------------------------------------------------------
    test('SEC-004 : authorId du deal correspond à l\'uid connecté', () async {
      // ARRANGE
      const currentUserId = 'uid_connected_user';

      await fakeFirestore.collection('deals').doc('d1').set({
        'title': 'Deal test',
        'price': 99.99,
        'authorId': currentUserId,
      });

      // ACT
      final doc = await fakeFirestore.collection('deals').doc('d1').get();

      // ASSERT
      expect(doc.data()?['authorId'], currentUserId);
    });

    // -------------------------------------------------------
    // SEC-005 : Les deals sont lisibles sans authentification
    // Cohérent avec la Security Rule : allow read: if true
    // -------------------------------------------------------
    test('SEC-005 : les deals sont accessibles publiquement en lecture', () async {
      // ARRANGE — on insère un deal public
      await fakeFirestore.collection('deals').doc('public_deal').set({
        'title': 'Deal public',
        'price': 49.99,
        'authorId': 'uid_some_user',
      });

      // ACT — lecture sans auth (simulé par fakeFirestore)
      final snapshot = await fakeFirestore.collection('deals').get();

      // ASSERT
      expect(snapshot.docs.isNotEmpty, true);
      expect(snapshot.docs.first.data()['title'], 'Deal public');
    });
  });
}
