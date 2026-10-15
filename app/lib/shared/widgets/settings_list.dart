import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/tokens.dart';
import 'glass.dart';

/// Grupo de filas al estilo de los Ajustes de iOS: título pequeño afuera,
/// filas en una sola tarjeta separadas por líneas finas.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    required this.children,
    this.title,
    this.footer,
  });

  final String? title;
  final String? footer;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (final (i, child) in children.indexed) {
      if (i > 0) {
        rows.add(
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 58,
            color: FlamColors.glassBorder,
          ),
        );
      }
      rows.add(child);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 7),
            child: Text(
              title!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: FlamColors.textMuted,
              ),
            ),
          ),
        Glass(
          padding: EdgeInsets.zero,
          radius: FlamRadius.md,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(FlamRadius.md),
            child: Material(
              type: MaterialType.transparency,
              child: Column(children: rows),
            ),
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 7, 16, 0),
            child: Text(
              footer!,
              style: TextStyle(fontSize: 13, color: FlamColors.textMuted),
            ),
          ),
      ],
    );
  }
}

/// Fila de ajustes: ícono en un cuadrito de color, título, valor y flecha.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;

  /// Valor actual a la derecha (p. ej. "Español").
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 9, 12, 9),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: destructive ? FlamColors.danger : null,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.3,
                            color: FlamColors.textMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (value != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    value!,
                    style: TextStyle(color: FlamColors.textMuted),
                  ),
                ),
              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: trailing!,
                ),
              if (onTap != null && trailing == null && !destructive)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: FlamColors.textFaint,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hoja inferior para elegir una opción de una lista (con marca en la actual).
Future<void> showChoiceSheet<T>(
  BuildContext context, {
  required String title,
  required List<(T, String)> options,
  required T selected,
  required ValueChanged<T> onSelected,
  TextStyle? Function(T value)? styleOf,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  builder: (sheet) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          SettingsGroupCard(
            children: [
              for (final (value, label) in options)
                InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelected(value);
                    Navigator.pop(sheet);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: (styleOf?.call(value) ?? const TextStyle())
                                .copyWith(fontSize: 16),
                          ),
                        ),
                        if (value == selected)
                          Icon(Icons.check_rounded, color: FlamColors.pink),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  ),
);

/// Solo la tarjeta de un [SettingsGroup], con divisores sin sangría.
class SettingsGroupCard extends StatelessWidget {
  const SettingsGroupCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Glass(
      padding: EdgeInsets.zero,
      radius: FlamRadius.md,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(FlamRadius.md),
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            children: [
              for (final (i, child) in children.indexed) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 16,
                    color: FlamColors.glassBorder,
                  ),
                child,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
