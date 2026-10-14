import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/locale_controller.dart';
import '../../../shared/widgets/widgets.dart';

/// Nombre de cada idioma escrito en su propio idioma.
const languageNames = {'es': 'Español', 'en': 'English'};

/// Opciones de idioma: el del dispositivo + cada idioma soportado.
class LanguageOptions extends ConsumerWidget {
  const LanguageOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider);
    final controller = ref.read(localeProvider.notifier);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FlamChip(
          label: context.l10n.languageSystem,
          selected: current == null,
          onTap: () => controller.set(null),
        ),
        for (final locale in AppLocalizations.supportedLocales)
          FlamChip(
            label: languageNames[locale.languageCode] ?? locale.languageCode,
            selected: current?.languageCode == locale.languageCode,
            onTap: () => controller.set(locale),
          ),
      ],
    );
  }
}

/// Botón compacto (🌐 ES) para pantallas sin ajustes, como el login.
class LanguageButton extends ConsumerWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = Localizations.localeOf(context).languageCode;
    return PopupMenuButton<Locale>(
      tooltip: context.l10n.settingsLanguage,
      onSelected: (l) => ref.read(localeProvider.notifier).set(l),
      itemBuilder: (_) => [
        for (final locale in AppLocalizations.supportedLocales)
          PopupMenuItem(
            value: locale,
            child: Text(
              languageNames[locale.languageCode] ?? locale.languageCode,
            ),
          ),
      ],
      child: GlassPill(
        leading: const Icon(Icons.language_rounded, size: 16),
        child: Text(code.toUpperCase()),
      ),
    );
  }
}
