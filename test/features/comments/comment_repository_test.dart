// COM-001 à COM-002 — Tests du CommentRepository
// RNCP39583 — C2.2.2 : Tests automatisés
//
// Stratégie : on utilise fake_cloud_firestore pour simuler la persistance
// Firestore sans connexion réseau, comme pour les autres repositories.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lebondeal/features/comments/data/repositories/comment_repository_impl.dart';
import 'package:lebondeal/features/deals/data/datasources/remote/firestore_service.dart';

void main() {
  group('CommentRepository —', () {
    late CommentRepositoryImpl repository;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = CommentRepositoryImpl(FirestoreService(db: fakeFirestore));
    });

    // -------------------------------------------------------
    // COM-001 : addComment persiste le commentaire dans Firestore
    // -------------------------------------------------------
    test(
      'COM-001 : addComment retourne Right et persiste le commentaire',
      () async {
        // ARRANGE — deal existant pour le compteur comments
        await fakeFirestore.collection('deals').doc('deal_abc').set({
          'title': 'Deal test',
          'comments': 0,
        });

        // ACT
        final result = await repository.addComment(
          dealId: 'deal_abc',
          authorId: 'uid_alice',
          authorName: 'Alice',
          content: 'Super deal !',
        );

        // ASSERT
        expect(result.isRight(), true);
        final snap = await fakeFirestore
            .collection('comments')
            .where('dealId', isEqualTo: 'deal_abc')
            .get();
        expect(snap.docs.length, 1);
        expect(snap.docs.first.data()['content'], 'Super deal !');
        expect(snap.docs.first.data()['authorId'], 'uid_alice');
      },
    );

    // -------------------------------------------------------
    // COM-002 : getCommentsStream retourne les CommentEntity du deal
    // -------------------------------------------------------
    test(
      'COM-002 : getCommentsStream retourne les commentaires mappés en entités',
      () async {
        // ARRANGE
        await repository.addComment(
          dealId: 'deal_xyz',
          authorId: 'uid_bob',
          authorName: 'Bob',
          content: 'Top !',
        );

        // ACT
        final comments = await repository.getCommentsStream('deal_xyz').first;

        // ASSERT
        expect(comments.length, 1);
        expect(comments.first.author, 'Bob');
        expect(comments.first.content, 'Top !');
        expect(comments.first.dealId, 'deal_xyz');
      },
    );
  });
}
