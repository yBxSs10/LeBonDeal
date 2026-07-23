// DEAL-001 à DEAL-004 — Tests de l'entité Deal
// RNCP39583 — C2.2.2 : Tests automatisés
//
// Stratégie : tests purement unitaires sur l'entité — aucune
// dépendance externe, exécution instantanée.

import 'package:flutter_test/flutter_test.dart';
import 'package:lebondeal/features/deals/domain/entities/deal.dart';

// Fixture réutilisable dans tous les tests
Deal makeDeal({
  String id = '1',
  String title = 'iPhone 15 -20%',
  double price = 799.99,
  double originalPrice = 999.99,
  int discountPercent = 20,
  String categoryId = 'high-tech',
  String authorId = 'uid_test_001',
  bool isTrending = false,
  bool isPopular = false,
  int publishedHoursAgo = 1,
  String? badge,
}) {
  return Deal(
    id: id,
    title: title,
    description: 'Description du deal',
    price: price,
    originalPrice: originalPrice,
    discountPercent: discountPercent,
    imageUrl: 'https://example.com/image.jpg',
    storeName: 'Apple Store',
    author: 'Testeur',
    authorId: authorId,
    publishedHoursAgo: publishedHoursAgo,
    badge: badge,
    comments: 0,
    favorites: 0,
    shares: 0,
    categoryId: categoryId,
    isTrending: isTrending,
    isPopular: isPopular,
  );
}

void main() {
  group('Deal entity —', () {
    // -------------------------------------------------------
    // DEAL-001 : Création d'un deal avec données valides
    // -------------------------------------------------------
    test('DEAL-001 : crée un deal avec tous les champs requis', () {
      // ACT
      final deal = makeDeal();

      // ASSERT
      expect(deal.id, '1');
      expect(deal.title, 'iPhone 15 -20%');
      expect(deal.price, 799.99);
      expect(deal.originalPrice, 999.99);
      expect(deal.discountPercent, 20);
      expect(deal.authorId, 'uid_test_001');
    });

    // -------------------------------------------------------
    // DEAL-002 : copyWith préserve les champs non modifiés
    // -------------------------------------------------------
    test('DEAL-002 : copyWith ne modifie que les champs spécifiés', () {
      // ARRANGE
      final original = makeDeal(title: 'Deal original', price: 100.0);

      // ACT
      final modified = original.copyWith(price: 80.0);

      // ASSERT
      expect(modified.title, 'Deal original'); // inchangé
      expect(modified.price, 80.0); // modifié
      expect(modified.authorId, original.authorId); // inchangé
      expect(modified.id, original.id); // inchangé
    });

    // -------------------------------------------------------
    // DEAL-003 : priceLabel formate correctement le prix
    // -------------------------------------------------------
    test('DEAL-003 : priceLabel retourne le prix formaté avec symbole', () {
      // ARRANGE
      final deal = makeDeal(price: 49.99);

      // ASSERT
      expect(deal.priceLabel, '49.99 €');
      expect(deal.originalPriceLabel, '999.99 €');
    });

    // -------------------------------------------------------
    // DEAL-004 : isTrending et isPopular sont false par défaut
    // -------------------------------------------------------
    test('DEAL-004 : isTrending et isPopular valent false par défaut', () {
      // ACT
      final deal = makeDeal();

      // ASSERT
      expect(deal.isTrending, false);
      expect(deal.isPopular, false);
    });

    // -------------------------------------------------------
    // DEAL-005 : copyWith avec isTrending=true
    // -------------------------------------------------------
    test('DEAL-005 : copyWith peut passer un deal en trending', () {
      // ARRANGE
      final deal = makeDeal(isTrending: false);

      // ACT
      final trending = deal.copyWith(isTrending: true);

      // ASSERT
      expect(trending.isTrending, true);
      expect(trending.isPopular, false); // non touché
    });

    // -------------------------------------------------------
    // DEAL-019 : timeAgoLabel formate l'ancienneté par unité adaptée
    // -------------------------------------------------------
    test('DEAL-019 : timeAgoLabel bascule heures/jours/semaines/mois', () {
      expect(makeDeal(publishedHoursAgo: 0).timeAgoLabel, "à l'instant");
      expect(makeDeal(publishedHoursAgo: 5).timeAgoLabel, 'il y a 5h');
      expect(makeDeal(publishedHoursAgo: 48).timeAgoLabel, 'il y a 2j');
      expect(
        makeDeal(publishedHoursAgo: 24 * 10).timeAgoLabel,
        'il y a 1 semaine',
      );
      expect(
        makeDeal(publishedHoursAgo: 24 * 20).timeAgoLabel,
        'il y a 2 semaines',
      );
      expect(makeDeal(publishedHoursAgo: 888).timeAgoLabel, 'il y a 1 mois');
    });

    // -------------------------------------------------------
    // DEAL-020 : shouldShowBadge expire l'étiquette "NEW" après 24h
    // -------------------------------------------------------
    test('DEAL-020 : le badge NEW expire après 24h, HOT reste affiché', () {
      expect(
        makeDeal(badge: 'NEW', publishedHoursAgo: 5).shouldShowBadge,
        true,
      );
      expect(
        makeDeal(badge: 'NEW', publishedHoursAgo: 888).shouldShowBadge,
        false,
      );
      expect(
        makeDeal(badge: 'HOT', publishedHoursAgo: 888).shouldShowBadge,
        true,
      );
      expect(makeDeal(badge: null).shouldShowBadge, false);
    });
  });
}
