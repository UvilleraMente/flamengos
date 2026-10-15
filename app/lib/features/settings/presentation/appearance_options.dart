import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/appearance.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart';

String themeName(AppLocalizations t, FlamTheme theme) => switch (theme) {
  FlamTheme.firefly => t.themeFirefly,
  FlamTheme.spicebug => t.themeSpicebug,
  FlamTheme.light => t.themeLight,
  FlamTheme.dark => t.themeDark,
};

String _themeHint(AppLocalizations t, FlamTheme theme) => switch (theme) {
  FlamTheme.firefly => t.themeFireflyHint,
  FlamTheme.spicebug => t.themeSpicebugHint,
  FlamTheme.light => t.themeLightHint,
  FlamTheme.dark => t.themeDarkHint,
};

String _caseName(AppLocalizations t, TextCase c) => switch (c) {
  TextCase.normal => t.textCaseNormal,
  TextCase.upper => t.textCaseUpper,
  TextCase.lower => t.textCaseLower,
  TextCase.title => t.textCaseTitle,
};

/// Tema, fuente, tamaño de letra y formato de letras.
class AppearanceGroup extends ConsumerWidget {
  const AppearanceGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final look = ref.watch(appearanceProvider);
    final controller = ref.read(appearanceProvider.notifier);
    void set(Appearance next) {
      HapticFeedback.selectionClick();
      controller.update(next);
    }

    return SettingsGroup(
      title: t.settingsAppearance,
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final theme in FlamTheme.values) ...[
                if (theme.index > 0) const SizedBox(width: 10),
                Expanded(
                  child: _ThemeCard(
                    theme: theme,
                    name: themeName(t, theme),
                    hint: _themeHint(t, theme),
                    selected: look.theme == theme,
                    onTap: () => set(look.copyWith(theme: theme)),
                  ),
                ),
              ],
            ],
          ),
        ),
        SettingsTile(
          icon: Icons.text_fields_rounded,
          color: const Color(0xFF5856D6),
          title: t.appearanceFont,
          value: look.font.family,
          onTap: () => showChoiceSheet(
            context,
            title: t.appearanceFont,
            options: [for (final f in FlamFont.values) (f, f.family)],
            selected: look.font,
            styleOf: (f) => TextStyle(fontFamily: f.family),
            onSelected: (f) => set(look.copyWith(font: f)),
          ),
        ),
        SettingsTile(
          icon: Icons.format_size_rounded,
          color: const Color(0xFF34C759),
          title: t.appearanceTextSize,
          value: '${(look.textScale * 100).round()}%',
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(54, 0, 12, 6),
          child: Row(
            children: [
              const Text('A', style: TextStyle(fontSize: 13)),
              Expanded(
                child: Slider.adaptive(
                  value: look.textScale,
                  min: Appearance.minScale,
                  max: Appearance.maxScale,
                  divisions: 9,
                  onChanged: (v) =>
                      controller.update(look.copyWith(textScale: v)),
                ),
              ),
              const Text('A', style: TextStyle(fontSize: 22)),
            ],
          ),
        ),
        SettingsTile(
          icon: Icons.title_rounded,
          color: const Color(0xFFFF9500),
          title: t.appearanceTextCase,
          value: _caseName(t, look.textCase),
          onTap: () => showChoiceSheet(
            context,
            title: t.appearanceTextCase,
            options: [for (final c in TextCase.values) (c, _caseName(t, c))],
            selected: look.textCase,
            onSelected: (c) => set(look.copyWith(textCase: c)),
          ),
        ),
      ],
    );
  }
}

/// Vista previa del tema: su fondo, una tarjeta y un botón con su acento.
class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.theme,
    required this.name,
    required this.hint,
    required this.selected,
    required this.onTap,
  });

  final FlamTheme theme;
  final String name;
  final String hint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = FlamPalette.of(theme);
    final glow = p.glows.isEmpty ? null : p.glows.first;
    return Semantics(
      button: true,
      selected: selected,
      label: name,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: FlamMotion.medium,
                height: 72,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      glow == null
                          ? p.background.first
                          : Color.alphaBlend(
                              glow.$3.withValues(alpha: glow.$4),
                              p.background.first,
                            ),
                      p.background[1],
                    ],
                  ),
                  border: Border.all(
                    color: selected ? FlamColors.pink : FlamColors.glassBorder,
                    width: selected ? 2.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: p.glass),
                          borderRadius: BorderRadius.circular(6),
                          border: p.isSolid
                              ? null
                              : Border.all(color: p.glassBorder),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Line(color: p.text, width: 34),
                            const SizedBox(height: 4),
                            _Line(color: p.textFaint, width: 22),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [p.accent, p.accentEnd],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? FlamColors.text : FlamColors.textMuted,
                ),
              ),
              Text(
                hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: FlamColors.textFaint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.color, required this.width});

  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: 5,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(3),
    ),
  );
}
