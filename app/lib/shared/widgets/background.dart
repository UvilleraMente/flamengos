import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

/// Fondo global: degradado del tema con "luces" de flamenco.
///
/// Las luces son degradados radiales (no blur), así que se pintan una sola
/// vez y quedan en caché gracias al RepaintBoundary. Por eso el vidrio de la
/// app casi nunca necesita BackdropFilter: detrás solo hay este fondo estático.
class FlamingoBackground extends StatelessWidget {
  const FlamingoBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = FlamColors.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: palette.background,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(painter: _GlowPainter(palette)),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  const _GlowPainter(this.palette);

  final FlamPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.shortestSide;
    for (final (pos, radius, color, alpha) in palette.glows) {
      final center = Offset(pos.dx * size.width, pos.dy * size.height);
      final r = radius * unit;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: alpha),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: r));
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.palette != palette;
}
