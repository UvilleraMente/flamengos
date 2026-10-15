import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

/// Superficie de vidrio.
///
/// Por defecto es "vidrio barato": relleno translúcido + borde, sin blur.
/// Sobre el fondo estático se ve igual y no cuesta nada.
/// Usa [blur] solo cuando hay contenido moviéndose detrás
/// (barra de navegación, barra del chat, diálogos).
class Glass extends StatelessWidget {
  const Glass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = FlamRadius.lg,
    this.blur = false,
    this.gradient,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool blur;
  final Gradient? gradient;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    // En temas sólidos (Cricket) las tarjetas no llevan borde, como en iOS.
    final showBorder = borderColor != null || !FlamColors.palette.isSolid;
    final box = DecoratedBox(
      decoration: BoxDecoration(
        gradient:
            gradient ?? (blur ? FlamGradients.frosted : FlamGradients.glass),
        borderRadius: shape,
        border: showBorder
            ? Border.all(color: borderColor ?? FlamColors.glassBorder)
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );
    if (!blur) return box;
    return ClipRRect(
      borderRadius: shape,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: box,
      ),
    );
  }
}

/// Bloque con título para formularios y pantallas de detalle.
class GlassSection extends StatelessWidget {
  const GlassSection({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Glass(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitle!,
                style: TextStyle(color: FlamColors.textMuted),
              ),
            ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// Pastilla pequeña de vidrio (contadores, etiquetas).
class GlassPill extends StatelessWidget {
  const GlassPill({super.key, required this.child, this.leading, this.color});

  final Widget child;
  final Widget? leading;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: FlamRadius.pill,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      borderColor: color?.withValues(alpha: 0.5) ?? FlamColors.glassBorder,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color ?? FlamColors.text,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 6)],
            child,
          ],
        ),
      ),
    );
  }
}
