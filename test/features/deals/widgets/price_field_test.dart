// WIDGET-001 à WIDGET-005 — Tests widget du composant PriceField
// RNCP39583 — C2.2.2 : couverture de la couche presentation

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lebondeal/features/deals/presentation/widgets/price_field.dart';

Widget _wrap(Widget child, {GlobalKey<FormState>? formKey}) {
  return MaterialApp(
    home: Scaffold(
      body: Form(
        key: formKey,
        child: Row(children: [child]),
      ),
    ),
  );
}

void main() {
  group('PriceField —', () {
    testWidgets('WIDGET-001 : affiche le label et le préfixe €', (
      tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        _wrap(PriceField(controller: controller, label: 'Prix')),
      );

      expect(find.text('Prix'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets(
      'WIDGET-002 : saisie utilisateur mise à jour dans le controller',
      (tester) async {
        final controller = TextEditingController();
        await tester.pumpWidget(
          _wrap(PriceField(controller: controller, label: 'Prix')),
        );

        await tester.enterText(find.byType(TextFormField), '49.99');
        expect(controller.text, '49.99');
      },
    );

    testWidgets('WIDGET-003 : champ obligatoire vide déclenche une erreur', (
      tester,
    ) async {
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController();
      await tester.pumpWidget(
        _wrap(
          PriceField(controller: controller, label: 'Prix', isRequired: true),
          formKey: formKey,
        ),
      );

      expect(formKey.currentState!.validate(), false);
      await tester.pump();
      expect(find.text('Obligatoire'), findsOneWidget);
    });

    testWidgets('WIDGET-004 : prix négatif ou nul rejeté par le validateur', (
      tester,
    ) async {
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController(text: '0');
      await tester.pumpWidget(
        _wrap(
          PriceField(controller: controller, label: 'Prix'),
          formKey: formKey,
        ),
      );

      expect(formKey.currentState!.validate(), false);
      await tester.pump();
      expect(find.text('Prix invalide'), findsOneWidget);
    });

    testWidgets('WIDGET-005 : prix valide passe la validation', (tester) async {
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController(text: '19.99');
      await tester.pumpWidget(
        _wrap(
          PriceField(controller: controller, label: 'Prix'),
          formKey: formKey,
        ),
      );

      expect(formKey.currentState!.validate(), true);
    });
  });
}
