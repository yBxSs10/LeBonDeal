// CAT-001 — Test du CategoryRepository
// RNCP39583 — C2.2.2 : Tests automatisés
//
// Les catégories sont une liste statique locale (pas de collection
// Firestore dédiée) : le repository ne dépend d'aucun service externe.

import 'package:flutter_test/flutter_test.dart';
import 'package:lebondeal/features/categories/data/repositories/category_repository_impl.dart';

void main() {
  group('CategoryRepository —', () {
    // -------------------------------------------------------
    // CAT-001 : getAllCategories retourne les 8 catégories statiques
    // -------------------------------------------------------
    test('CAT-001 : getAllCategories retourne les 8 catégories statiques', () {
      final repository = CategoryRepositoryImpl();

      final categories = repository.getAllCategories();

      expect(categories.length, 8);
      expect(categories.map((c) => c.id), contains('high-tech'));
      expect(categories.map((c) => c.id), contains('mode'));
      expect(categories.map((c) => c.id), contains('maison'));
    });
  });
}
