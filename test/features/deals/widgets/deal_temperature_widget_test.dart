// WIDGET-015 à WIDGET-020 — Tests widget du composant DealTemperatureWidget
// RNCP39583 — C2.2.2 : couverture de la couche presentation

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lebondeal/features/deals/presentation/widgets/deal_temperature_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('DealTemperatureWidget —', () {
    testWidgets('WIDGET-015 : affiche la température avec le symbole °', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          DealTemperatureWidget(
            temperature: 42,
            userVote: 0,
            onUpvote: () {},
            onDownvote: () {},
            canVote: true,
          ),
        ),
      );

      expect(find.text('42°'), findsOneWidget);
    });

    testWidgets(
      'WIDGET-016 : icône flamme au-dessus de 50°, flocon en dessous',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            DealTemperatureWidget(
              temperature: 80,
              userVote: 0,
              onUpvote: () {},
              onDownvote: () {},
              canVote: true,
            ),
          ),
        );
        expect(find.byIcon(Icons.local_fire_department), findsWidgets);

        await tester.pumpWidget(
          _wrap(
            DealTemperatureWidget(
              temperature: 10,
              userVote: 0,
              onUpvote: () {},
              onDownvote: () {},
              canVote: true,
            ),
          ),
        );
        expect(find.byIcon(Icons.ac_unit), findsWidgets);
      },
    );

    testWidgets('WIDGET-017 : tapper sur le bouton upvote déclenche onUpvote', (
      tester,
    ) async {
      var upvoted = false;
      await tester.pumpWidget(
        _wrap(
          DealTemperatureWidget(
            temperature: 10,
            userVote: 0,
            onUpvote: () => upvoted = true,
            onDownvote: () {},
            canVote: true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.local_fire_department).last);
      expect(upvoted, true);
    });

    testWidgets(
      'WIDGET-018 : tapper sur le bouton downvote déclenche onDownvote',
      (tester) async {
        var downvoted = false;
        await tester.pumpWidget(
          _wrap(
            DealTemperatureWidget(
              temperature: 10,
              userVote: 0,
              onUpvote: () {},
              onDownvote: () => downvoted = true,
              canVote: true,
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.ac_unit).first);
        expect(downvoted, true);
      },
    );

    testWidgets('WIDGET-019 : canVote=false désactive les boutons de vote', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          DealTemperatureWidget(
            temperature: 10,
            userVote: 0,
            onUpvote: () => tapped = true,
            onDownvote: () => tapped = true,
            canVote: false,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.local_fire_department).last);
      expect(tapped, false);
    });

    testWidgets(
      'WIDGET-020 : le tooltip invite à se connecter si canVote=false',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            DealTemperatureWidget(
              temperature: 10,
              userVote: 0,
              onUpvote: () {},
              onDownvote: () {},
              canVote: false,
            ),
          ),
        );

        final tooltips = tester.widgetList<Tooltip>(find.byType(Tooltip));
        expect(
          tooltips.every((t) => t.message == 'Connectez-vous pour voter'),
          true,
        );
      },
    );
  });
}
