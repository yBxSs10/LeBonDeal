// PROF-001 à PROF-002 — Tests du ProfileRepository
// RNCP39583 — C2.2.2 : Tests automatisés

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lebondeal/features/deals/data/datasources/remote/firestore_service.dart';
import 'package:lebondeal/features/profile/data/repositories/profile_repository_impl.dart';

void main() {
  group('ProfileRepository —', () {
    late ProfileRepositoryImpl repository;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = ProfileRepositoryImpl(FirestoreService(db: fakeFirestore));
    });

    // -------------------------------------------------------
    // PROF-001 : toggleFollowedCategory ajoute puis retire une catégorie
    // -------------------------------------------------------
    test(
      'PROF-001 : toggleFollowedCategory ajoute et retire une catégorie suivie',
      () async {
        const userId = 'uid_1';
        const categoryId = 'mode';

        final addResult = await repository.toggleFollowedCategory(
          userId,
          categoryId,
          false,
        );
        expect(addResult.isRight(), true);
        var followed = await repository
            .getFollowedCategoryIdsStream(userId)
            .first;
        expect(followed, contains(categoryId));

        final removeResult = await repository.toggleFollowedCategory(
          userId,
          categoryId,
          true,
        );
        expect(removeResult.isRight(), true);
        followed = await repository.getFollowedCategoryIdsStream(userId).first;
        expect(followed, isNot(contains(categoryId)));
      },
    );

    // -------------------------------------------------------
    // PROF-002 : getUserRoleStream retourne le rôle stocké
    // -------------------------------------------------------
    test(
      'PROF-002 : getUserRoleStream retourne le rôle du document users/{uid}',
      () async {
        await fakeFirestore.collection('users').doc('uid_mod').set({
          'role': 'moderator',
        });

        final role = await repository.getUserRoleStream('uid_mod').first;

        expect(role, 'moderator');
      },
    );
  });
}
