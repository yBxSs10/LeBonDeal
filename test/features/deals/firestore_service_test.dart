// DEAL-010 à DEAL-015 — Tests de FirestoreService (instance injectable)
// RNCP39583 — C2.2.2 : Tests automatisés
//
// Stratégie : FirestoreService reçoit un FakeFirebaseFirestore via son
// constructeur, ce qui permet de tester les vraies méthodes de la classe
// sans connexion réseau ni Firebase initialisé.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lebondeal/features/comments/data/models/comment.dart';
import 'package:lebondeal/features/deals/data/datasources/remote/firestore_service.dart';
import 'package:lebondeal/features/deals/domain/entities/deal.dart';

void main() {
  group('FirestoreService (injectable) —', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FirestoreService service;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      service = FirestoreService(db: fakeFirestore);
    });

    // -------------------------------------------------------
    // DEAL-010 : addComment crée le commentaire ET incrémente
    //            le compteur comments du deal (batch atomique)
    // -------------------------------------------------------
    test(
      'DEAL-010 : addComment persiste le commentaire et incrémente le compteur du deal',
      () async {
        // ARRANGE — deal existant avec comments: 0
        await fakeFirestore.collection('deals').doc('deal_abc').set({
          'title': 'Deal test',
          'price': 50.0,
          'originalPrice': 100.0,
          'discountPercent': 50,
          'authorId': 'uid_1',
          'categoryId': 'mode',
          'comments': 0,
          'favorites': 0,
          'shares': 0,
          'isTrending': false,
          'isPopular': false,
        });

        final comment = Comment(
          id: '',
          dealId: 'deal_abc',
          author: 'Alice',
          content: 'Super deal !',
          createdAt: DateTime.now(),
        );

        // ACT
        await service.addComment(comment, 'uid_alice');

        // ASSERT — le commentaire est présent
        final commentSnap = await fakeFirestore
            .collection('comments')
            .where('dealId', isEqualTo: 'deal_abc')
            .get();
        expect(commentSnap.docs.length, 1);
        expect(commentSnap.docs.first.data()['content'], 'Super deal !');
        expect(commentSnap.docs.first.data()['authorId'], 'uid_alice');

        // ASSERT — le compteur a été incrémenté
        final dealSnap = await fakeFirestore
            .collection('deals')
            .doc('deal_abc')
            .get();
        expect(dealSnap.data()?['comments'], 1);
      },
    );

    // -------------------------------------------------------
    // DEAL-011 : toggleSavedDeal ajoute puis retire un deal
    //            des favoris d'un utilisateur
    // -------------------------------------------------------
    test(
      'DEAL-011 : toggleSavedDeal ajoute et retire un dealId des favoris',
      () async {
        const userId = 'uid_bob';
        const dealId = 'deal_xyz';

        // ACT — sauvegarde (currentlySaved: false → arrayUnion)
        await service.toggleSavedDeal(userId, dealId, false);
        final afterSave = await fakeFirestore
            .collection('users')
            .doc(userId)
            .get();
        expect(afterSave.data()?['savedDealIds'], contains(dealId));

        // ACT — désauvegarde (currentlySaved: true → arrayRemove)
        await service.toggleSavedDeal(userId, dealId, true);
        final afterRemove = await fakeFirestore
            .collection('users')
            .doc(userId)
            .get();
        expect(afterRemove.data()?['savedDealIds'], isNot(contains(dealId)));
      },
    );

    // -------------------------------------------------------
    // DEAL-012 : getTrendingDealsStream retourne uniquement
    //            les deals marqués isTrending: true
    // -------------------------------------------------------
    test(
      'DEAL-012 : getTrendingDealsStream retourne uniquement les deals trending',
      () async {
        // ARRANGE — 1 trending + 1 non-trending
        await fakeFirestore.collection('deals').doc('t1').set({
          'title': 'Trending deal',
          'price': 10.0,
          'originalPrice': 20.0,
          'discountPercent': 50,
          'author': 'A',
          'authorId': 'uid_1',
          'categoryId': 'high-tech',
          'comments': 0,
          'favorites': 0,
          'shares': 0,
          'isTrending': true,
          'isPopular': false,
        });
        await fakeFirestore.collection('deals').doc('t2').set({
          'title': 'Normal deal',
          'price': 5.0,
          'originalPrice': 10.0,
          'discountPercent': 50,
          'author': 'B',
          'authorId': 'uid_2',
          'categoryId': 'mode',
          'comments': 0,
          'favorites': 0,
          'shares': 0,
          'isTrending': false,
          'isPopular': false,
        });

        // ACT
        final deals = await service.getTrendingDealsStream().first;

        // ASSERT
        expect(deals.length, 1);
        expect(deals.first.title, 'Trending deal');
        expect(deals.first.isTrending, true);
      },
    );

    // -------------------------------------------------------
    // DEAL-013 : getSavedDealsStream retourne les deals dont
    //            les IDs sont dans savedDealIds de l'utilisateur
    // -------------------------------------------------------
    test(
      'DEAL-013 : getSavedDealsStream retourne les deals sauvegardés par l\'utilisateur',
      () async {
        // ARRANGE — 2 deals dans Firestore
        await fakeFirestore.collection('deals').doc('deal_A').set({
          'title': 'Deal A',
          'price': 20.0,
          'originalPrice': 40.0,
          'discountPercent': 50,
          'author': 'X',
          'authorId': 'uid_x',
          'categoryId': 'maison',
          'comments': 0,
          'favorites': 0,
          'shares': 0,
          'isTrending': false,
          'isPopular': false,
        });
        await fakeFirestore.collection('deals').doc('deal_B').set({
          'title': 'Deal B',
          'price': 30.0,
          'originalPrice': 60.0,
          'discountPercent': 50,
          'author': 'Y',
          'authorId': 'uid_y',
          'categoryId': 'sports',
          'comments': 0,
          'favorites': 0,
          'shares': 0,
          'isTrending': false,
          'isPopular': false,
        });

        // L'utilisateur a uniquement sauvegardé deal_A
        await fakeFirestore.collection('users').doc('uid_carol').set({
          'savedDealIds': ['deal_A'],
        });

        // ACT
        final saved = await service.getSavedDealsStream('uid_carol').first;

        // ASSERT
        expect(saved.length, 1);
        expect(saved.first.id, 'deal_A');
        expect(saved.first.title, 'Deal A');
      },
    );

    // -------------------------------------------------------
    // DEAL-014 : voteOnDeal — upvote incrémente la température
    //            et downvote la décrémente (transaction atomique)
    // -------------------------------------------------------
    test(
      'DEAL-014 : voteOnDeal modifie la température de façon atomique',
      () async {
        // ARRANGE — deal avec température initiale 50
        await fakeFirestore.collection('deals').doc('deal_vote').set({
          'title': 'Deal votable',
          'price': 10.0,
          'originalPrice': 20.0,
          'discountPercent': 50,
          'author': 'Z',
          'authorId': 'uid_z',
          'categoryId': 'high-tech',
          'comments': 0,
          'favorites': 0,
          'shares': 0,
          'temperature': 50,
          'isTrending': false,
          'isPopular': false,
        });

        // ACT — upvote
        await service.voteOnDeal('uid_dave', 'deal_vote', 1);

        // ASSERT — température passe à 51
        final afterUpvote = await fakeFirestore
            .collection('deals')
            .doc('deal_vote')
            .get();
        expect(afterUpvote.data()?['temperature'], 51);

        // ASSERT — vote enregistré dans la sous-collection
        final voteDoc = await fakeFirestore
            .collection('deals')
            .doc('deal_vote')
            .collection('votes')
            .doc('uid_dave')
            .get();
        expect(voteDoc.data()?['value'], 1);

        // ACT — downvote (changement de sens : -2 au total)
        await service.voteOnDeal('uid_dave', 'deal_vote', -1);

        final afterDownvote = await fakeFirestore
            .collection('deals')
            .doc('deal_vote')
            .get();
        expect(afterDownvote.data()?['temperature'], 49);
      },
    );

    // -------------------------------------------------------
    // DEAL-015 : voteOnDeal — revoter dans le même sens annule
    //            le vote (toggle) et restaure la température
    // -------------------------------------------------------
    test(
      'DEAL-015 : revoter dans le même sens annule le vote (toggle)',
      () async {
        // ARRANGE
        await fakeFirestore.collection('deals').doc('deal_toggle').set({
          'title': 'Deal toggle',
          'price': 5.0,
          'originalPrice': 10.0,
          'discountPercent': 50,
          'author': 'W',
          'authorId': 'uid_w',
          'categoryId': 'mode',
          'comments': 0,
          'favorites': 0,
          'shares': 0,
          'temperature': 50,
          'isTrending': false,
          'isPopular': false,
        });

        // ACT — premier upvote → 51
        await service.voteOnDeal('uid_eve', 'deal_toggle', 1);
        final after1 = await fakeFirestore
            .collection('deals')
            .doc('deal_toggle')
            .get();
        expect(after1.data()?['temperature'], 51);

        // ACT — même upvote → annulation → revient à 50
        await service.voteOnDeal('uid_eve', 'deal_toggle', 1);
        final after2 = await fakeFirestore
            .collection('deals')
            .doc('deal_toggle')
            .get();
        expect(after2.data()?['temperature'], 50);

        // ASSERT — le vote est supprimé de la sous-collection
        final voteDoc = await fakeFirestore
            .collection('deals')
            .doc('deal_toggle')
            .collection('votes')
            .doc('uid_eve')
            .get();
        expect(voteDoc.exists, false);
      },
    );

    // -------------------------------------------------------
    // DEAL-016 : addDeal écrit le document dans Firestore
    // -------------------------------------------------------
    test(
      'DEAL-016 : addDeal persiste un deal dans la collection deals',
      () async {
        // ARRANGE
        const deal = Deal(
          id: '',
          title: 'Test Deal',
          description: 'Description test',
          price: 99.99,
          originalPrice: 149.99,
          discountPercent: 33,
          imageUrl: 'https://example.com/img.jpg',
          storeName: 'Test Store',
          author: 'Testeur',
          authorId: 'uid_test',
          publishedHoursAgo: 0,
          comments: 0,
          favorites: 0,
          shares: 0,
          categoryId: 'high-tech',
        );

        // ACT
        final ref = await service.addDeal(deal);

        // ASSERT
        final snap = await fakeFirestore.collection('deals').doc(ref.id).get();
        expect(snap.exists, true);
        expect(snap.data()?['title'], 'Test Deal');
        expect(snap.data()?['authorId'], 'uid_test');
        expect(snap.data()?['price'], 99.99);
        expect(snap.data()?['temperature'], 50);
      },
    );

    // -------------------------------------------------------
    // DEAL-017 : getAllDealsStream émet la liste complète
    // -------------------------------------------------------
    test('DEAL-017 : getAllDealsStream émet tous les deals', () async {
      // ARRANGE — seed 2 deals
      await fakeFirestore.collection('deals').add({
        'title': 'Deal A',
        'description': '',
        'price': 10.0,
        'originalPrice': 20.0,
        'discountPercent': 50,
        'imageUrl': '',
        'storeName': 'Store',
        'author': 'User',
        'authorId': 'uid_a',
        'badge': null,
        'comments': 0,
        'favorites': 0,
        'shares': 0,
        'categoryId': 'mode',
        'isTrending': false,
        'isPopular': false,
        'temperature': 50,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
      await fakeFirestore.collection('deals').add({
        'title': 'Deal B',
        'description': '',
        'price': 20.0,
        'originalPrice': 40.0,
        'discountPercent': 50,
        'imageUrl': '',
        'storeName': 'Store',
        'author': 'User',
        'authorId': 'uid_b',
        'badge': null,
        'comments': 0,
        'favorites': 0,
        'shares': 0,
        'categoryId': 'high-tech',
        'isTrending': true,
        'isPopular': false,
        'temperature': 50,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });

      // ACT
      final deals = await service.getAllDealsStream().first;

      // ASSERT
      expect(deals.length, 2);
    });

    // -------------------------------------------------------
    // DEAL-018 : getAllCategories retourne 8 catégories
    // -------------------------------------------------------
    test('DEAL-018 : getAllCategories retourne les 8 catégories statiques', () {
      final categories = service.getAllCategories();
      expect(categories.length, 8);
      expect(categories.map((c) => c.id), contains('high-tech'));
      expect(categories.map((c) => c.id), contains('mode'));
      expect(categories.map((c) => c.id), contains('maison'));
    });
  });
}
