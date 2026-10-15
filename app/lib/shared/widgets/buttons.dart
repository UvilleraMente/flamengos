import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/tokens.dart';

enum FlamVariant { primary, glass, ghost, danger }

enum FlamSize { small, medium, large }

BoxDecoration? _decoration(FlamVariant variant, BorderRadius radius) =>
    switch (variant) {
      FlamVariant.primary => BoxDecoration(
        gradient: FlamGradients.primary,
        borderRadius: radius,
        boxShadow: FlamShadows.glow,
      ),
      FlamVariant.danger => BoxDecoration(
        gradient: FlamGradients.danger,
        borderRadius: radius,
      ),
      FlamVariant.glass => BoxDecoration(
        gradient: FlamGradients.glass,
        borderRadius: radius,
        border: Border.all(color: FlamColors.glassBorder),
      ),
      FlamVariant.ghost => null,
    };

/// Se encoge un poco al presionar. Base de todos los botones Flamengos.
class _Pressable extends StatefulWidget {
  const _Pressable({
    required this.onTap,
    required this.decoration,
    required this.radius,
    required this.child,
  });

  final VoidCallback? onTap;
  final BoxDecoration? decoration;
  final BorderRadius radius;
  final Widget child;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return AnimatedScale(
      scale: _down ? 0.95 : 1,
      duration: FlamMotion.fast,
      curve: FlamMotion.curve,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.45,
        duration: FlamMotion.fast,
        child: DecoratedBox(
          decoration: widget.decoration ?? const BoxDecoration(),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: widget.radius,
              splashColor: Colors.white24,
              highlightColor: Colors.white10,
              onTap: enabled
                  ? () {
                      HapticFeedback.selectionClick();
                      widget.onTap!();
                    }
                  : null,
              onHighlightChanged: (v) => setState(() => _down = v),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón principal de la app.
///
/// ```dart
/// FlamButton(label: 'Entrar', onPressed: _login, expand: true)
/// FlamButton(label: 'Editar', variant: FlamVariant.glass, icon: Icon(Icons.edit))
/// ```
class FlamButton extends StatelessWidget {
  const FlamButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = FlamVariant.primary,
    this.size = FlamSize.medium,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final FlamVariant variant;
  final FlamSize size;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final (height, fontSize, hPad) = switch (size) {
      FlamSize.small => (38.0, 15.0, 16.0),
      FlamSize.medium => (50.0, 17.0, 22.0),
      FlamSize.large => (56.0, 17.0, 28.0),
    };
    final radius = BorderRadius.circular(FlamRadius.pill);
    final color = switch (variant) {
      FlamVariant.ghost => FlamColors.blush,
      FlamVariant.glass => FlamColors.text,
      FlamVariant.primary || FlamVariant.danger => FlamColors.onAccent,
    };

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox.square(
            dimension: fontSize + 2,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: color),
          )
        else if (icon != null)
          IconTheme.merge(
            data: IconThemeData(color: color, size: fontSize + 4),
            child: icon!,
          ),
        if (loading || icon != null) const SizedBox(width: 10),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );

    final button = _Pressable(
      onTap: loading ? null : onPressed,
      decoration: _decoration(variant, radius),
      radius: radius,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Center(widthFactor: 1, child: content),
        ),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Botón redondo (acciones de tarjeta, enviar mensaje, aceptar/declinar).
class FlamIconButton extends StatelessWidget {
  const FlamIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.variant = FlamVariant.glass,
    this.size = 48,
    this.tooltip,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final FlamVariant variant;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size);
    Widget button = _Pressable(
      onTap: onPressed,
      decoration: _decoration(variant, radius),
      radius: radius,
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: IconTheme.merge(
            data: IconThemeData(
              color:
                  variant == FlamVariant.glass || variant == FlamVariant.ghost
                  ? FlamColors.text
                  : FlamColors.onAccent,
              size: size * 0.45,
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(fontSize: size * 0.42),
              child: icon,
            ),
          ),
        ),
      ),
    );
    if (tooltip != null) button = Tooltip(message: tooltip!, child: button);
    return button;
  }
}

/// Chip seleccionable (género, preferencias, filtros).
class FlamChip extends StatelessWidget {
  const FlamChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(FlamRadius.pill);
    return _Pressable(
      onTap: onTap,
      decoration: selected
          ? BoxDecoration(gradient: FlamGradients.primary, borderRadius: radius)
          : _decoration(FlamVariant.glass, radius),
      radius: radius,
      child: AnimatedPadding(
        duration: FlamMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(
                Icons.check_rounded,
                size: 18,
                color: FlamColors.onAccent,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? FlamColors.onAccent : FlamColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
