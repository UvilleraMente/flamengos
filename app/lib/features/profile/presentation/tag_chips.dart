import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../domain/profile.dart';
import 'profile_l10n.dart';

/// Etiquetas de un perfil; las que comparto con esa persona van resaltadas.
class TagWrap extends StatelessWidget {
  const TagWrap({super.key, required this.tags, this.highlight = const {}});

  final Iterable<ProfileTag> tags;
  final Set<ProfileTag> highlight;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    // Primero las que tenemos en común.
    final sorted = [...tags]
      ..sort(
        (a, b) =>
            (highlight.contains(b) ? 1 : 0) - (highlight.contains(a) ? 1 : 0),
      );
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final tag in sorted)
          _Chip(
            icon: tag.icon,
            label: tag.label(t),
            selected: highlight.contains(tag),
          ),
      ],
    );
  }
}

/// Selector de etiquetas con un máximo.
class TagPicker extends StatelessWidget {
  const TagPicker({
    super.key,
    required this.selected,
    required this.max,
    required this.onChanged,
  });

  final Set<ProfileTag> selected;
  final int max;
  final ValueChanged<Set<ProfileTag>> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final full = selected.length >= max;
    return Wrap(
      spacing: 6,
      runSpacing: 8,
      children: [
        for (final tag in ProfileTag.values)
          _Chip(
            icon: tag.icon,
            label: tag.label(t),
            selected: selected.contains(tag),
            dimmed: full && !selected.contains(tag),
            onTap: () {
              HapticFeedback.selectionClick();
              if (selected.contains(tag)) {
                onChanged({...selected}..remove(tag));
              } else if (!full) {
                onChanged({...selected, tag});
              }
            },
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.selected,
    this.dimmed = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool dimmed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? FlamColors.pink : FlamColors.text;
    return Opacity(
      opacity: dimmed ? 0.4 : 1,
      child: Material(
        color: selected
            ? FlamColors.pink.withValues(alpha: 0.14)
            : FlamColors.glassFill,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected
                ? FlamColors.pink.withValues(alpha: 0.6)
                : FlamColors.glassBorder,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
