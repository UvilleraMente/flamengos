import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/l10n.dart';
import '../core/l10n/locale_controller.dart';
import '../core/theme/app_theme.dart';
import '../shared/widgets/widgets.dart';
import 'router.dart';

class FlamengosApp extends ConsumerWidget {
  const FlamengosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appName,
      debugShowCheckedModeBanner: false,
      theme: buildFlamTheme(),
      // null = idioma del dispositivo (si no está soportado, el primero: español).
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: ref.watch(routerProvider),
      // Un solo fondo para toda la app: las páginas son transparentes.
      builder: (context, child) => FlamingoBackground(child: child!),
    );
  }
}
