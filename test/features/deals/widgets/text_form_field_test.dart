// WIDGET-010 à WIDGET-014 — Tests widget du composant CustomTextFormField
// RNCP39583 — C2.2.2 : couverture de la couche presentation

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lebondeal/features/deals/presentation/widgets/text_form_field.dart';

Widget _wrap(Widget child, {GlobalKey<FormState>? formKey}) {
  return MaterialApp(
    home: Scaffold(
      body: Form(key: formKey, child: child),
    ),
  );
}

void main() {
  group('CustomTextFormField —', () {
    testWidgets('WIDGET-010 : label obligatoire affiché avec astérisque', (
      tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        _wrap(CustomTextFormField(controller: controller, label: 'Titre')),
      );

      expect(find.text('Titre *'), findsOneWidget);
    });

    testWidgets('WIDGET-011 : label facultatif affiché sans astérisque', (
      tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        _wrap(
          CustomTextFormField(
            controller: controller,
            label: 'Complément',
            isRequired: false,
          ),
        ),
      );

      expect(find.text('Complément'), findsOneWidget);
      expect(find.text('Complément *'), findsNothing);
    });

    testWidgets('WIDGET-012 : champ obligatoire vide déclenche une erreur', (
      tester,
    ) async {
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController();
      await tester.pumpWidget(
        _wrap(
          CustomTextFormField(controller: controller, label: 'Titre'),
          formKey: formKey,
        ),
      );

      expect(formKey.currentState!.validate(), false);
      await tester.pump();
      expect(find.text('Ce champ est obligatoire'), findsOneWidget);
    });

    testWidgets(
      'WIDGET-013 : champ facultatif vide ne déclenche pas d\'erreur',
      (tester) async {
        final formKey = GlobalKey<FormState>();
        final controller = TextEditingController();
        await tester.pumpWidget(
          _wrap(
            CustomTextFormField(
              controller: controller,
              label: 'Complément',
              isRequired: false,
            ),
            formKey: formKey,
          ),
        );

        expect(formKey.currentState!.validate(), true);
      },
    );

    testWidgets('WIDGET-014 : obscureText masque la saisie (mot de passe)', (
      tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        _wrap(
          CustomTextFormField(
            controller: controller,
            label: 'Mot de passe',
            obscureText: true,
          ),
        ),
      );

      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.obscureText, true);
    });
  });
}
