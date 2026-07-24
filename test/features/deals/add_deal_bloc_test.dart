// BLOC-001 à BLOC-005 — Tests de AddDealBloc (gestion d'état)
// RNCP39583 — C2.2.2 : Tests automatisés
//
// Stratégie : on enregistre un FirestoreService avec FakeFirebaseFirestore
// dans GetIt avant chaque test pour isoler la logique du bloc
// sans connexion réseau ni Firebase initialisé.
//
// Note : submitDeal() et _buildDeal() font appel à
// FirebaseAuth.instance.currentUser (static) → testés via DEAL-009
// (auth_guard) et les Security Rules (SEC-004). Les tests ici couvrent
// exclusivement la gestion d'état du ChangeNotifier.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lebondeal/core/di/injection.dart';
import 'package:lebondeal/features/categories/data/repositories/category_repository_impl.dart';
import 'package:lebondeal/features/categories/domain/repositories/category_repository.dart';
import 'package:lebondeal/features/deals/data/datasources/remote/firestore_service.dart';
import 'package:lebondeal/features/deals/presentation/bloc/add_deal_bloc.dart';

void main() {
  group('AddDealBloc —', () {
    late AddDealBloc bloc;

    setUp(() {
      // Enregistrer FirestoreService avec FakeFirebaseFirestore dans GetIt
      if (!getIt.isRegistered<FirestoreService>()) {
        getIt.registerLazySingleton<FirestoreService>(
          () => FirestoreService(db: FakeFirebaseFirestore()),
        );
      }
      if (!getIt.isRegistered<CategoryRepository>()) {
        getIt.registerLazySingleton<CategoryRepository>(
          () => CategoryRepositoryImpl(),
        );
      }
      bloc = AddDealBloc();
    });

    tearDown(() {
      bloc.dispose();
      getIt.reset();
    });

    // -------------------------------------------------------
    // BLOC-001 : Catégories chargées à l'initialisation
    // -------------------------------------------------------
    test('BLOC-001 : les catégories sont chargées à l\'initialisation', () {
      expect(bloc.categories, isNotEmpty);
      expect(bloc.categories.length, 8);
    });

    // -------------------------------------------------------
    // BLOC-002 : Première catégorie présélectionnée par défaut
    // -------------------------------------------------------
    test('BLOC-002 : la première catégorie est présélectionnée par défaut', () {
      expect(bloc.selectedCategoryId, isNotNull);
      expect(bloc.selectedCategoryId, bloc.categories.first.id);
    });

    // -------------------------------------------------------
    // BLOC-003 : updateCategory change la sélection
    // -------------------------------------------------------
    test('BLOC-003 : updateCategory met à jour la catégorie sélectionnée', () {
      // ARRANGE — on prend la dernière catégorie (différente de la première)
      expect(bloc.categories.length, greaterThan(1));
      final newCategoryId = bloc.categories.last.id;
      expect(newCategoryId, isNot(equals(bloc.selectedCategoryId)));

      // ACT
      bloc.updateCategory(newCategoryId);

      // ASSERT
      expect(bloc.selectedCategoryId, newCategoryId);
    });

    // -------------------------------------------------------
    // BLOC-004 : updateCategory notifie les listeners
    // -------------------------------------------------------
    test('BLOC-004 : updateCategory notifie les listeners', () {
      // ARRANGE
      var notified = false;
      bloc.addListener(() => notified = true);

      // ACT
      bloc.updateCategory(bloc.categories.last.id);

      // ASSERT
      expect(notified, true);
    });

    // -------------------------------------------------------
    // BLOC-005 : setSubmitting met à jour isSubmitting et notifie
    // -------------------------------------------------------
    test(
      'BLOC-005 : setSubmitting met à jour isSubmitting et notifie les listeners',
      () {
        // ARRANGE
        expect(bloc.isSubmitting, false);
        var notifyCount = 0;
        bloc.addListener(() => notifyCount++);

        // ACT — passage à true
        bloc.setSubmitting(true);
        expect(bloc.isSubmitting, true);
        expect(notifyCount, 1);

        // ACT — retour à false
        bloc.setSubmitting(false);
        expect(bloc.isSubmitting, false);
        expect(notifyCount, 2);
      },
    );
  });
}
