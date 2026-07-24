// WIDGET-006 à WIDGET-009 — Tests widget du composant DescriptionField
// RNCP39583 — C2.2.2 : couverture de la couche presentation

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lebondeal/features/deals/presentation/widgets/description_field.dart';

Widget _wrap(Widget child, {GlobalKey<FormState>? formKey}) {
  return MaterialApp(
    home: Scaffold(
      body: Form(key: formKey, child: child),
    ),
  );
}

void main() {
  group('DescriptionField —', () {
    testWidgets('WIDGET-006 : affiche le label par défaut avec astérisque', (
      tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(_wrap(DescriptionField(controller: controller)));

      expect(find.text('Description *'), findsOneWidget);
    });

    testWidgets('WIDGET-007 : label personnalisé pris en compte', (
      tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        _wrap(DescriptionField(controller: controller, label: 'Détails')),
      );

      expect(find.text('Détails *'), findsOneWidget);
    });

    testWidgets(
      'WIDGET-008 : champ vide déclenche "Ce champ est obligatoire"',
      (tester) async {
        final formKey = GlobalKey<FormState>();
        final controller = TextEditingController();
        await tester.pumpWidget(
          _wrap(DescriptionField(controller: controller), formKey: formKey),
        );

        expect(formKey.currentState!.validate(), false);
        await tester.pump();
        expect(find.text('Ce champ est obligatoire'), findsOneWidget);
      },
    );

    testWidgets(
      'WIDGET-009 : validateur personnalisé appelé si champ non vide',
      (tester) async {
        final formKey = GlobalKey<FormState>();
        final controller = TextEditingController(text: 'Un texte valide');
        await tester.pumpWidget(
          _wrap(
            DescriptionField(
              controller: controller,
              validator: (value) => value == 'interdit' ? 'Refusé' : null,
            ),
            formKey: formKey,
          ),
        );

        expect(formKey.currentState!.validate(), true);
      },
    );
  });
}
