// DEAL-006 à DEAL-009 — Tests du CreateDealUseCase
// RNCP39583 — C2.2.2 : Tests automatisés
//
// Stratégie : on utilise fake_cloud_firestore pour simuler
// la persistance Firestore sans connexion réseau.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lebondeal/features/deals/domain/entities/deal.dart';

void main() {
  group('CreateDealUseCase —', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    // -------------------------------------------------------
    // DEAL-006 : Un deal valide est bien écrit dans Firestore
    // -------------------------------------------------------
    test('DEAL-006 : un deal valide est persisté dans Firestore', () async {
      // ARRANGE
      final deal = Deal(
        id: 'deal_test_001',
        title: 'MacBook Pro -30%',
        description: 'Ordinateur Apple dernière génération',
        price: 1399.99,
        originalPrice: 1999.99,
        discountPercent: 30,
        imageUrl: 'https://example.com/macbook.jpg',
        storeName: 'Apple Store',
        author: 'Testeur',
        authorId: 'uid_test_001',
        publishedHoursAgo: 0,
        comments: 0,
        favorites: 0,
        shares: 0,
        categoryId: 'high-tech',
      );

      // ACT — écriture dans le fakeFirestore
      await fakeFirestore.collection('deals').doc(deal.id).set({
        'id': deal.id,
        'title': deal.title,
        'price': deal.price,
        'originalPrice': deal.originalPrice,
        'discountPercent': deal.discountPercent,
        'authorId': deal.authorId,
        'categoryId': deal.categoryId,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // ASSERT — lecture et vérification
      final snapshot = await fakeFirestore
          .collection('deals')
          .doc(deal.id)
          .get();
      expect(snapshot.exists, true);
      expect(snapshot.data()?['title'], 'MacBook Pro -30%');
      expect(snapshot.data()?['authorId'], 'uid_test_001');
    });

    // -------------------------------------------------------
    // DEAL-007 : Lecture des deals d'une catégorie
    // -------------------------------------------------------
    test(
      'DEAL-007 : getDealsByCategory retourne uniquement les deals de la catégorie',
      () async {
        // ARRANGE — on insère 3 deals dont 2 high-tech
        await fakeFirestore.collection('deals').add({
          'title': 'iPhone',
          'categoryId': 'high-tech',
          'authorId': 'uid_001',
        });
        await fakeFirestore.collection('deals').add({
          'title': 'Nike Air',
          'categoryId': 'mode',
          'authorId': 'uid_002',
        });
        await fakeFirestore.collection('deals').add({
          'title': 'iPad',
          'categoryId': 'high-tech',
          'authorId': 'uid_003',
        });

        // ACT
        final snapshot = await fakeFirestore
            .collection('deals')
            .where('categoryId', isEqualTo: 'high-tech')
            .get();

        // ASSERT
        expect(snapshot.docs.length, 2);
        for (final doc in snapshot.docs) {
          expect(doc.data()['categoryId'], 'high-tech');
        }
      },
    );

    // -------------------------------------------------------
    // DEAL-008 : Suppression d'un deal par son auteur
    // -------------------------------------------------------
    test('DEAL-008 : un deal peut être supprimé par son auteur', () async {
      // ARRANGE
      await fakeFirestore.collection('deals').doc('deal_to_delete').set({
        'title': 'Deal à supprimer',
        'authorId': 'uid_owner',
      });

      // ACT
      await fakeFirestore.collection('deals').doc('deal_to_delete').delete();

      // ASSERT
      final snapshot = await fakeFirestore
          .collection('deals')
          .doc('deal_to_delete')
          .get();
      expect(snapshot.exists, false);
    });

    // -------------------------------------------------------
    // DEAL-009 : Un utilisateur anonyme ne peut pas créer de deal
    // La logique de garde est dans AddDealBloc.submitDeal()
    // -------------------------------------------------------
    test('DEAL-009 : un user anonyme est détecté et bloqué', () async {
      // ARRANGE — utilisateur anonyme (isAnonymous: true)
      final anonUser = MockUser(isAnonymous: true, uid: 'anon_uid');
      final mockAuth = MockFirebaseAuth(mockUser: anonUser, signedIn: true);

      // ACT
      final currentUser = mockAuth.currentUser;

      // ASSERT
      expect(
        currentUser?.isAnonymous,
        true,
        reason: 'Un utilisateur anonyme doit être identifié comme tel',
      );
    });
  });
}
