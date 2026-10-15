import 'package:flamengos/core/theme/app_theme.dart';
import 'package:flamengos/core/theme/appearance.dart';
import 'package:flamengos/core/theme/tokens.dart';
import 'package:flamengos/l10n/app_localizations_es.dart';
import 'package:flamengos/l10n/cased_localizations.dart';
import 'package:flamengos/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => FlamColors.palette = FlamPalette.firefly);

  group('applyTextCase', () {
    test('cada formato', () {
      expect(applyTextCase(TextCase.normal, 'Pedir pareja'), 'Pedir pareja');
      expect(applyTextCase(TextCase.upper, 'Pedir pareja'), 'PEDIR PAREJA');
      expect(applyTextCase(TextCase.lower, 'Pedir Pareja'), 'pedir pareja');
      expect(applyTextCase(TextCase.title, 'pedir PAREJA'), 'Pedir Pareja');
    });

    test('respeta acentos y emojis', () {
      expect(applyTextCase(TextCase.upper, 'contraseña 🦩'), 'CONTRASEÑA 🦩');
    });
  });

  test('CasedLocalizations transforma textos y textos con parámetros', () {
    final t = CasedLocalizations(
      AppLocalizationsEs(),
      (s) => applyTextCase(TextCase.upper, s),
    );
    expect(t.discoverRequest, 'PEDIR PAREJA');
    expect(t.coupleTogetherSince(0), 'JUNTOS DESDE HOY');
    expect(t.requestsAcceptTitle('Ana'), '¿EMPAREJARTE CON ANA?');
  });

  for (final theme in FlamTheme.values) {
    testWidgets('el tema ${theme.name} se construye y pinta', (tester) async {
      FlamColors.palette = FlamPalette.of(theme);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildFlamTheme(fontFamily: FlamFont.lora.family),
          home: FlamingoBackground(
            child: Scaffold(
              body: Column(
                children: [
                  const Glass(child: Text('vidrio')),
                  FlamButton(label: 'botón', onPressed: () {}),
                  const TextField(),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.text('vidrio'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
