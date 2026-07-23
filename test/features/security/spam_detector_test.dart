// SEC-006 à SEC-010 — Détection automatique de spam (SpamDetector)
// RNCP39583 — C2.2.2 : Tests automatisés
//
// Stratégie : logique pure, aucune dépendance Firestore — tests
// instantanés et déterministes.

import 'package:flutter_test/flutter_test.dart';
import 'package:lebondeal/features/deals/domain/services/spam_detector.dart';

void main() {
  group('SpamDetector —', () {
    // -------------------------------------------------------
    // SEC-006 : Un deal légitime n'est pas signalé
    // -------------------------------------------------------
    test(
      'SEC-006 : un titre et une description normaux ne sont pas suspects',
      () {
        final result = SpamDetector.check(
          title: 'iPhone 15 Pro à -20%',
          description: 'Bon plan repéré chez Apple Store, valable ce week-end.',
        );

        expect(result.isSuspicious, false);
        expect(result.reasons, isEmpty);
      },
    );

    // -------------------------------------------------------
    // SEC-007 : Une expression bannie est détectée
    // -------------------------------------------------------
    test('SEC-007 : une expression suspecte connue est détectée', () {
      final result = SpamDetector.check(
        title: 'Gagnez de l\'argent facile maintenant',
        description: 'Offre limitée',
      );

      expect(result.isSuspicious, true);
      expect(result.reasons, isNotEmpty);
    });

    // -------------------------------------------------------
    // SEC-008 : Un titre majoritairement en majuscules est détecté
    // -------------------------------------------------------
    test('SEC-008 : un titre majoritairement en majuscules est détecté', () {
      final result = SpamDetector.check(
        title: 'PROMO EXCEPTIONNELLE ACHETEZ MAINTENANT',
        description: 'Un deal normal.',
      );

      expect(result.isSuspicious, true);
      expect(result.reasons.any((r) => r.contains('majuscules')), true);
    });

    // -------------------------------------------------------
    // SEC-009 : Des caractères répétés de façon excessive sont détectés
    // -------------------------------------------------------
    test('SEC-009 : des caractères répétés (ex: "!!!!!") sont détectés', () {
      final result = SpamDetector.check(
        title: 'Super deal !!!!!!!',
        description: 'Dépêchez-vous',
      );

      expect(result.isSuspicious, true);
      expect(result.reasons.any((r) => r.contains('répétés')), true);
    });

    // -------------------------------------------------------
    // SEC-010 : Plusieurs signaux se cumulent dans les raisons
    // -------------------------------------------------------
    test('SEC-010 : plusieurs signaux suspects se cumulent', () {
      final result = SpamDetector.check(
        title: 'ARGENT FACILE GARANTI !!!!!',
        description: 'Cliquez ici pour gagner au loto',
      );

      expect(result.isSuspicious, true);
      expect(result.reasons.length, greaterThan(1));
    });
  });
}
