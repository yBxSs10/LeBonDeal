// WIDGET-021 à WIDGET-024 — Tests widget du composant CategoryChip
// RNCP39583 — C2.2.2 : couverture de la couche presentation

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lebondeal/features/categories/domain/entities/category.dart';
import 'package:lebondeal/features/categories/presentation/widgets/category_chip.dart';

const _category = Category(
  id: 'high-tech',
  name: 'High-Tech',
  icon: Icons.computer,
  color: Colors.blue,
);

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('CategoryChip —', () {
    testWidgets('WIDGET-021 : affiche le nom de la catégorie', (tester) async {
      await tester.pumpWidget(_wrap(const CategoryChip(category: _category)));

      expect(find.text('High-Tech'), findsOneWidget);
    });

    testWidgets('WIDGET-022 : tapper sur le chip déclenche onTap', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(CategoryChip(category: _category, onTap: () => tapped = true)),
      );

      await tester.tap(find.byType(GestureDetector));
      expect(tapped, true);
    });

    testWidgets(
      'WIDGET-023 : le libellé sémantique mentionne "sélectionné" quand actif',
      (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          _wrap(const CategoryChip(category: _category, isSelected: true)),
        );

        expect(find.bySemanticsLabel(RegExp('sélectionné')), findsOneWidget);
        handle.dispose();
      },
    );

    testWidgets('WIDGET-024 : pas de mention "sélectionné" quand inactif', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _wrap(const CategoryChip(category: _category, isSelected: false)),
      );

      expect(find.bySemanticsLabel(RegExp('High-Tech')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('sélectionné')), findsNothing);
      handle.dispose();
    });
  });
}
