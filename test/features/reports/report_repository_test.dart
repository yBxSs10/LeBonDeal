// REP-001 à REP-003 — Tests du ReportRepository
// RNCP39583 — C2.2.2 : Tests automatisés
//
// Stratégie : fake_cloud_firestore, comme pour les autres repositories.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lebondeal/features/deals/data/datasources/remote/firestore_service.dart';
import 'package:lebondeal/features/reports/data/repositories/report_repository_impl.dart';

void main() {
  group('ReportRepository —', () {
    late ReportRepositoryImpl repository;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = ReportRepositoryImpl(FirestoreService(db: fakeFirestore));
    });

    // -------------------------------------------------------
    // REP-001 : createReport crée un signalement en statut pending
    // -------------------------------------------------------
    test(
      'REP-001 : createReport retourne Right et crée un signalement pending',
      () async {
        final result = await repository.createReport(
          targetId: 'deal_1',
          targetType: 'deal',
          targetTitle: 'Deal suspect',
          reason: 'Deal frauduleux',
          authorId: 'uid_reporter',
        );

        expect(result.isRight(), true);
        final snap = await fakeFirestore.collection('reports').get();
        expect(snap.docs.length, 1);
        expect(snap.docs.first.data()['status'], 'pending');
      },
    );

    // -------------------------------------------------------
    // REP-002 : resolveReport passe le statut à resolved
    // -------------------------------------------------------
    test(
      'REP-002 : resolveReport passe le signalement en statut resolved',
      () async {
        final doc = await fakeFirestore.collection('reports').add({
          'targetId': 'deal_1',
          'targetType': 'deal',
          'targetTitle': 'Deal suspect',
          'reason': 'Deal frauduleux',
          'authorId': 'uid_reporter',
          'status': 'pending',
          'createdAt': DateTime.now(),
        });

        final result = await repository.resolveReport(doc.id);

        expect(result.isRight(), true);
        final snap = await fakeFirestore
            .collection('reports')
            .doc(doc.id)
            .get();
        expect(snap.data()?['status'], 'resolved');
      },
    );

    // -------------------------------------------------------
    // REP-003 : getReportsStream retourne les ReportEntity mappées
    // -------------------------------------------------------
    test(
      'REP-003 : getReportsStream retourne les signalements mappés en entités',
      () async {
        await repository.createReport(
          targetId: 'deal_2',
          targetType: 'deal',
          targetTitle: 'Deal test',
          reason: 'Deal expiré',
          authorId: 'uid_reporter',
        );

        final reports = await repository.getReportsStream().first;

        expect(reports.length, 1);
        expect(reports.first.targetTitle, 'Deal test');
        expect(reports.first.isPending, true);
      },
    );
  });
}
