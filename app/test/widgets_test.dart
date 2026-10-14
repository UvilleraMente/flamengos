import 'package:flamengos/core/theme/app_theme.dart';
import 'package:flamengos/core/l10n/l10n.dart';
import 'package:flamengos/features/profile/domain/profile.dart';
import 'package:flamengos/features/discover/presentation/swipe_deck.dart';
import 'package:flamengos/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Profile _profile(String id) => Profile(
  id: id,
  displayName: 'Flamengo $id',
  birthdate: DateTime(2000, 1, 1),
  gender: Gender.woman,
  interestedIn: {Gender.man},
  bio: '',
  city: 'Santo Domingo',
  photos: const [], // sin fotos: no necesita Supabase
  currentMatchId: null,
);

Widget _app(Widget child) => MaterialApp(
  theme: buildFlamTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: FlamingoBackground(child: Scaffold(body: child)),
);

void main() {
  testWidgets('FlamButton no responde mientras carga', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _app(
        Center(
          child: FlamButton(
            label: 'Entrar',
            loading: true,
            onPressed: () => taps++,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(FlamButton));
    expect(taps, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('GlassNavBar avisa la pestaña tocada', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      _app(
        Align(
          alignment: Alignment.bottomCenter,
          child: GlassNavBar(
            index: 0,
            onTap: (i) => tapped = i,
            items: const [
              GlassNavItem(icon: Icons.explore, label: 'Descubrir'),
              GlassNavItem(icon: Icons.mail, label: 'Solicitudes', badge: 2),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.mail));
    expect(tapped, 1);
    expect(find.text('2'), findsOneWidget);
  });

  group('SwipeDeck', () {
    late List<Profile> profiles;
    late List<(String, Swipe)> calls;

    Widget deck({bool ok = true, bool canLike = true}) => _app(
      StatefulBuilder(
        builder: (context, setState) => SwipeDeck(
          profiles: profiles,
          canLike: canLike,
          onSwipe: (p, s) async {
            calls.add((p.id, s));
            if (ok) setState(() => profiles.remove(p));
            return ok;
          },
        ),
      ),
    );

    setUp(() {
      profiles = [_profile('a'), _profile('b')];
      calls = [];
    });

    testWidgets('deslizar a la derecha pide pareja', (tester) async {
      await tester.pumpWidget(deck());
      await tester.drag(
        find.textContaining('Flamengo a'),
        const Offset(500, 0),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(calls, [('a', Swipe.like)]);
      expect(find.textContaining('Flamengo a'), findsNothing);
    });

    testWidgets('deslizar a la izquierda pasa', (tester) async {
      await tester.pumpWidget(deck());
      await tester.drag(
        find.textContaining('Flamengo a'),
        const Offset(-500, 0),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(calls, [('a', Swipe.pass)]);
    });

    testWidgets('un arrastre corto regresa la tarjeta', (tester) async {
      await tester.pumpWidget(deck());
      await tester.drag(
        find.textContaining('Flamengo a'),
        const Offset(40, 0),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
    });

    testWidgets('si el servidor falla, la tarjeta vuelve', (tester) async {
      await tester.pumpWidget(deck(ok: false));
      await tester.drag(
        find.textContaining('Flamengo a'),
        const Offset(500, 0),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(calls, [('a', Swipe.like)]);
      expect(find.textContaining('Flamengo a'), findsOneWidget);
    });

    testWidgets('con el límite lleno no se puede pedir pareja', (tester) async {
      await tester.pumpWidget(deck(canLike: false));
      await tester.drag(
        find.textContaining('Flamengo a'),
        const Offset(500, 0),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
    });
  });
}
