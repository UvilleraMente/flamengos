import 'package:flamengos/core/l10n/l10n.dart';
import 'package:flamengos/core/theme/app_theme.dart';
import 'package:flamengos/features/settings/presentation/delete_account_dialog.dart';
import 'package:flamengos/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('eliminar cuenta exige escribir la palabra de confirmación', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildFlamTheme(),
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDeleteAccountDialog(context),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    FlamButton deleteButton() => tester.widget<FlamButton>(
      find.widgetWithText(FlamButton, 'Eliminar para siempre'),
    );

    expect(deleteButton().onPressed, isNull);

    await tester.enterText(
      find.byType(TextField),
      'eliminar',
    ); // sin mayúsculas
    await tester.pump();
    expect(deleteButton().onPressed, isNotNull);

    await tester.enterText(find.byType(TextField), 'borrar');
    await tester.pump();
    expect(deleteButton().onPressed, isNull);
  });
}
