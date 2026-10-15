import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/tokens.dart';
import 'glass.dart';

class GlassNavItem {
  const GlassNavItem({required this.icon, required this.label, this.badge = 0});

  final IconData icon;
  final String label;
  final int badge;
}

/// Barra de navegación flotante de vidrio. La pestaña activa se expande
/// en una píldora con degradado.
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.items,
    required this.index,
    required this.onTap,
  });

  final List<GlassNavItem> items;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Glass(
            blur: true,
            radius: FlamRadius.pill,
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    flex: i == index ? 3 : 2,
                    child: _NavButton(
                      item: items[i],
                      selected: i == index,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onTap(i);
                      },
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

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final GlassNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: FlamMotion.medium,
          curve: FlamMotion.curve,
          height: 50,
          decoration: BoxDecoration(
            gradient: selected ? FlamGradients.primary : null,
            borderRadius: BorderRadius.circular(FlamRadius.pill),
            boxShadow: selected ? FlamShadows.glow : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Badge.count(
                count: item.badge,
                isLabelVisible: item.badge > 0,
                backgroundColor: FlamColors.coral,
                child: Icon(
                  item.icon,
                  color: selected ? FlamColors.onAccent : FlamColors.textMuted,
                ),
              ),
              AnimatedSize(
                duration: FlamMotion.medium,
                curve: FlamMotion.curve,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: FlamColors.onAccent,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selector de dos o más opciones en una píldora de vidrio.
class GlassSegmented<T> extends StatelessWidget {
  const GlassSegmented({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
  });

  final List<(T, String)> segments;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: FlamRadius.pill,
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          for (final (v, label) in segments)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChanged(v);
                },
                child: AnimatedContainer(
                  duration: FlamMotion.medium,
                  curve: FlamMotion.curve,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: v == value ? FlamGradients.primary : null,
                    borderRadius: BorderRadius.circular(FlamRadius.pill),
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: v == value
                          ? FlamColors.onAccent
                          : FlamColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Encabezado de pantalla: título grande a la izquierda, acciones a la derecha.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.trailing});

  final Widget title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: DefaultTextStyle.merge(
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
                child: title,
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
