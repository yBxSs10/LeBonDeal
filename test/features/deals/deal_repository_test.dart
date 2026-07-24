// DEAL-021 à DEAL-024 — Tests du DealRepository
// RNCP39583 — C2.2.2 : Tests automatisés
//
// FirestoreService est déjà testé en détail (firestore_service_test.dart).
// Ici on vérifie que DealRepositoryImpl délègue correctement et adapte le
// résultat au contrat du domain (Either<String, T>, pas d'exception qui fuit).

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lebondeal/features/deals/data/datasources/remote/firestore_service.dart';
import 'package:lebondeal/features/deals/data/repositories/deal_repository_impl.dart';
import 'package:lebondeal/features/deals/domain/entities/deal.dart';

void main() {
  group('DealRepository —', () {
    late DealRepositoryImpl repository;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = DealRepositoryImpl(FirestoreService(db: fakeFirestore));
    });

    Deal buildDeal({String authorId = 'uid_1', String categoryId = 'mode'}) {
      return Deal(
        id: '',
        title: 'Deal test',
        description: 'Description',
        price: 10,
        originalPrice: 20,
        discountPercent: 50,
        imageUrl: 'https://example.com/img.jpg',
        storeName: 'Boutique',
        author: 'Auteur',
        authorId: authorId,
        publishedHoursAgo: 0,
        comments: 0,
        favorites: 0,
        shares: 0,
        categoryId: categoryId,
      );
    }

    // -------------------------------------------------------
    // DEAL-021 : addDeal retourne Right(Deal) avec l'id généré
    // -------------------------------------------------------
    test(
      'DEAL-021 : addDeal retourne Right avec le deal et son id généré',
      () async {
        final result = await repository.addDeal(buildDeal());

        expect(result.isRight(), true);
        result.fold((_) => fail('Ne devrait pas échouer'), (deal) {
          expect(deal.id, isNotEmpty);
          expect(deal.title, 'Deal test');
        });
      },
    );

    // -------------------------------------------------------
    // DEAL-022 : deleteDeal retourne Right(unit) et supprime le document
    // -------------------------------------------------------
    test('DEAL-022 : deleteDeal retourne Right et supprime le deal', () async {
      final created = await repository.addDeal(buildDeal());
      final id = created.fold((_) => fail('setup échoué'), (d) => d.id);

      final result = await repository.deleteDeal(id);

      expect(result.isRight(), true);
      final snap = await fakeFirestore.collection('deals').doc(id).get();
      expect(snap.exists, false);
    });

    // -------------------------------------------------------
    // DEAL-023 : voteOnDeal retourne Right(unit)
    // -------------------------------------------------------
    test('DEAL-023 : voteOnDeal retourne Right après un vote valide', () async {
      final created = await repository.addDeal(buildDeal());
      final id = created.fold((_) => fail('setup échoué'), (d) => d.id);

      final result = await repository.voteOnDeal('uid_voter', id, 1);

      expect(result.isRight(), true);
    });

    // -------------------------------------------------------
    // DEAL-024 : getAllDealsStream délègue et retourne les deals persistés
    // -------------------------------------------------------
    test('DEAL-024 : getAllDealsStream retourne les deals persistés', () async {
      await repository.addDeal(buildDeal());
      await repository.addDeal(buildDeal());

      final deals = await repository.getAllDealsStream().first;

      expect(deals.length, 2);
    });
  });
}
