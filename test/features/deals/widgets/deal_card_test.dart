// WIDGET-025 à WIDGET-030 — Tests widget du composant DealCard
// RNCP39583 — C2.2.2 : couverture de la couche presentation
//
// L'image réseau (Image.network) est court-circuitée via
// debugNetworkImageHttpClientProvider pour garder les tests
// déterministes et sans dépendance réseau.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lebondeal/features/deals/presentation/widgets/deal_card.dart';

import '../deal_entity_test.dart';

// 1x1 pixel PNG transparent — sert de réponse HTTP factice à Image.network.
final Uint8List _fakePngBytes = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

class _FakeHttpHeaders extends Fake implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _FakeHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _fakePngBytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_fakePngBytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

class _FakeHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  HttpHeaders get headers => _FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse();
}

class _FakeHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpClientRequest();
}

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

// Pompe le widget avec l'image réseau court-circuitée, puis restaure
// immédiatement le provider par défaut : la vérification d'invariants de
// flutter_test s'exécute avant tearDown(), donc la réinitialisation doit
// se faire à l'intérieur même du corps du test.
Future<void> _pumpWithFakeNetwork(WidgetTester tester, Widget child) async {
  debugNetworkImageHttpClientProvider = () => _FakeHttpClient();
  await tester.pumpWidget(child);
  await tester.pump();
  debugNetworkImageHttpClientProvider = null;
}

void main() {
  group('DealCard —', () {
    testWidgets('WIDGET-025 : affiche titre, enseigne et prix', (tester) async {
      final deal = makeDeal(title: 'MacBook Pro -30%');
      await _pumpWithFakeNetwork(tester, _wrap(DealCard(deal: deal)));

      expect(find.text('MacBook Pro -30%'), findsOneWidget);
      expect(find.text('Apple Store'), findsOneWidget);
      expect(find.text('799.99 €'), findsOneWidget);
    });

    testWidgets(
      'WIDGET-026 : affiche le prix barré et le badge de remise quand discountPercent > 0',
      (tester) async {
        final deal = makeDeal(discountPercent: 30);
        await _pumpWithFakeNetwork(tester, _wrap(DealCard(deal: deal)));

        expect(find.text('999.99 €'), findsOneWidget);
        expect(find.text('-30%'), findsOneWidget);
      },
    );

    testWidgets(
      'WIDGET-027 : masque le prix barré quand discountPercent == 0',
      (tester) async {
        final deal = makeDeal(discountPercent: 0);
        await _pumpWithFakeNetwork(tester, _wrap(DealCard(deal: deal)));

        expect(find.text('999.99 €'), findsNothing);
      },
    );

    testWidgets('WIDGET-028 : icône favori pleine et rouge quand isSaved=true', (
      tester,
    ) async {
      final deal = makeDeal();
      await _pumpWithFakeNetwork(
        tester,
        _wrap(DealCard(deal: deal, isSaved: true)),
      );

      // Le compteur de favoris (stats) affiche toujours un Icons.favorite_border
      // séparé du bouton toggle : on scope la recherche au bouton lui-même.
      final toggleIcon = find.descendant(
        of: find.byType(IconButton),
        matching: find.byIcon(Icons.favorite),
      );
      expect(toggleIcon, findsOneWidget);
    });

    testWidgets('WIDGET-029 : tapper sur le bouton favori déclenche onSave', (
      tester,
    ) async {
      var saved = false;
      final deal = makeDeal();
      await _pumpWithFakeNetwork(
        tester,
        _wrap(DealCard(deal: deal, onSave: () => saved = true)),
      );

      await tester.tap(find.byType(IconButton));
      expect(saved, true);
    });

    testWidgets(
      'WIDGET-030 : le badge (ex HOT) est affiché quand shouldShowBadge est vrai',
      (tester) async {
        final deal = makeDeal(badge: 'HOT', publishedHoursAgo: 888);
        await _pumpWithFakeNetwork(tester, _wrap(DealCard(deal: deal)));

        expect(find.text('HOT'), findsOneWidget);
      },
    );
  });
}
