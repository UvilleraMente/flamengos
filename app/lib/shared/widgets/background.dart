import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

/// Fondo global: degradado nocturno con "luces" de flamenco.
///
/// Las luces son degradados radiales (no blur), así que se pintan una sola
/// vez y quedan en caché gracias al RepaintBoundary. Por eso el vidrio de la
/// app casi nunca necesita BackdropFilter: detrás solo hay este fondo estático.
class FlamingoBackground extends StatelessWidget {
  const FlamingoBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [FlamColors.night, FlamColors.plum, FlamColors.night],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: RepaintBoundary(child: CustomPaint(painter: _GlowPainter())),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  const _GlowPainter();

  static const _glows = [
    (Offset(0.05, 0.08), 0.75, FlamColors.pink, 0.45),
    (Offset(1.0, 0.42), 0.65, FlamColors.violet, 0.40),
    (Offset(0.15, 0.98), 0.70, FlamColors.coral, 0.30),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.shortestSide;
    for (final (pos, radius, color, alpha) in _glows) {
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
