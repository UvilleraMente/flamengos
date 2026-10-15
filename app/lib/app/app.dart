import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/l10n.dart';
import '../core/l10n/locale_controller.dart';
import '../core/security/app_lock.dart';
import '../core/supabase/supabase_providers.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/appearance.dart';
import '../core/theme/tokens.dart';
import '../features/settings/presentation/lock_screen.dart';
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
    final locked =
        ref.watch(appLockProvider).locked &&
        ref.watch(currentUserIdProvider) != null;

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
              child: Stack(
                children: [
                  // Un solo fondo para toda la app: las páginas son transparentes.
                  ExcludeSemantics(
                    excluding: locked,
                    // El fondo llega hasta abajo, pero el contenido nunca
                    // queda detrás de los botones de Android ni de la barra
                    // de inicio del iPhone.
                    child: FlamingoBackground(
                      child: SafeArea(
                        top: false,
                        left: false,
                        right: false,
                        child: child!,
                      ),
                    ),
                  ),
                  // Opaco a los toques: nada llega a la app de abajo.
                  if (locked)
                    const Positioned.fill(child: _Opaque(child: LockScreen())),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Opaque extends StatelessWidget {
  const _Opaque({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      GestureDetector(behavior: HitTestBehavior.opaque, child: child);
}
