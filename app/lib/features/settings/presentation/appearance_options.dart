import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/appearance.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart';

/// Tema, fuente, tamaño de letra y formato de letras.
class AppearanceOptions extends ConsumerWidget {
  const AppearanceOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final look = ref.watch(appearanceProvider);
    final controller = ref.read(appearanceProvider.notifier);
    void set(Appearance next) {
      HapticFeedback.selectionClick();
      controller.update(next);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Label(t.appearanceTheme),
        Row(
          children: [
            for (final theme in FlamTheme.values) ...[
              if (theme.index > 0) const SizedBox(width: 10),
              Expanded(
                child: _ThemeSwatch(
                  theme: theme,
                  label: switch (theme) {
                    FlamTheme.firefly => t.themeFirefly,
                    FlamTheme.light => t.themeLight,
                    FlamTheme.dark => t.themeDark,
                  },
                  selected: look.theme == theme,
                  onTap: () => set(look.copyWith(theme: theme)),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        _Label(t.appearanceFont),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final font in FlamFont.values)
              _FontChip(
                font: font,
                selected: look.font == font,
                onTap: () => set(look.copyWith(font: font)),
              ),
          ],
        ),
        const SizedBox(height: 20),
        _Label(
          t.appearanceTextSize,
          trailing: '${(look.textScale * 100).round()}%',
        ),
        Row(
          children: [
            const Text('A', style: TextStyle(fontSize: 13)),
            Expanded(
              child: Slider(
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
        const SizedBox(height: 12),
        _Label(t.appearanceTextCase),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in TextCase.values)
              FlamChip(
                label: switch (c) {
                  TextCase.normal => t.textCaseNormal,
                  TextCase.upper => t.textCaseUpper,
                  TextCase.lower => t.textCaseLower,
                  TextCase.title => t.textCaseTitle,
                },
                selected: look.textCase == c,
                onTap: () => set(look.copyWith(textCase: c)),
              ),
          ],
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {this.trailing});

  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: FlamColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: TextStyle(
              color: FlamColors.blush,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    ),
  );
}

/// Miniatura del tema: su fondo, una tarjeta de vidrio y el acento.
class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.theme,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final FlamTheme theme;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = FlamPalette.of(theme);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: FlamMotion.medium,
            height: 86,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(FlamRadius.md),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.alphaBlend(
                    FlamColors.pink.withValues(alpha: p.glows.first.$4),
                    p.background.first,
                  ),
                  p.background[1],
                ],
              ),
              border: Border.all(
                color: selected ? FlamColors.pink : p.glassBorder,
                width: selected ? 2.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 10,
                  width: 46,
                  decoration: BoxDecoration(
                    color: p.text,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: p.glass),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: p.glassBorder),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.all(6),
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: FlamGradients.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? FlamColors.text : FlamColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip que muestra el nombre de la fuente escrito con esa fuente.
class _FontChip extends StatelessWidget {
  const _FontChip({
    required this.font,
    required this.selected,
    required this.onTap,
  });

  final FlamFont font;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: FlamMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? FlamGradients.primary : FlamGradients.glass,
          borderRadius: BorderRadius.circular(FlamRadius.pill),
          border: selected ? null : Border.all(color: FlamColors.glassBorder),
        ),
        child: Text(
          'Aa  ${font.family}',
          style: TextStyle(
            fontFamily: font.family,
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: selected ? FlamColors.onAccent : FlamColors.text,
          ),
        ),
      ),
    );
  }
}
