import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/l10n.dart';
import '../core/l10n/locale_controller.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/appearance.dart';
import '../core/theme/tokens.dart';
import '../shared/widgets/widgets.dart';
import 'router.dart';

class FlamengosApp extends ConsumerWidget {
  const FlamengosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final look = ref.watch(appearanceProvider);

    // La paleta es global (FlamColors la lee). Al cambiar de tema, el
    // KeyedSubtree de abajo vuelve a montar la app para que todo la use.
    FlamColors.palette = FlamPalette.of(look.theme);
    final light = FlamColors.palette.brightness == Brightness.light;

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appName,
      debugShowCheckedModeBanner: false,
      theme: buildFlamTheme(fontFamily: look.font.family),
      // null = idioma del dispositivo (si no está soportado, el primero: español).
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: CasedLocalizationsDelegate.all(look.textCase),
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: light ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
          child: MediaQuery(
            // Tamaño de letra elegido × el del sistema (accesibilidad).
            data: media.copyWith(
              textScaler: TextScaler.linear(
                media.textScaler.scale(1) * look.textScale,
              ),
            ),
            child: KeyedSubtree(
              key: ValueKey(look.theme),
              // Un solo fondo para toda la app: las páginas son transparentes.
              child: FlamingoBackground(child: child!),
            ),
          ),
        );
      },
    );
  }
}
