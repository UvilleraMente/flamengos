import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/locale_controller.dart';
import '../../../shared/widgets/widgets.dart';

/// Nombre de cada idioma escrito en su propio idioma.
const languageNames = {'es': 'Español', 'en': 'English'};

/// Fila de Ajustes con el idioma actual; abre la lista de idiomas.
class LanguageTile extends ConsumerWidget {
  const LanguageTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final current = ref.watch(localeProvider);
    String name(Locale? l) => l == null
        ? t.languageSystem
        : languageNames[l.languageCode] ?? l.languageCode;
    return SettingsTile(
      icon: Icons.language_rounded,
      color: const Color(0xFF007AFF),
      title: t.settingsLanguage,
      value: name(current),
      onTap: () => showChoiceSheet<Locale?>(
        context,
        title: t.settingsLanguage,
        options: [
          (null, t.languageSystem),
          for (final l in AppLocalizations.supportedLocales) (l, name(l)),
        ],
        selected: current == null
            ? null
            : AppLocalizations.supportedLocales.firstWhere(
                (l) => l.languageCode == current.languageCode,
                orElse: () => current,
              ),
        onSelected: ref.read(localeProvider.notifier).set,
      ),
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
