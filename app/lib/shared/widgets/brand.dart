import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

/// Logotipo "Flamengos": letra script con degradado; en Cricket (minimalista)
/// va en la fuente de la app, sólido y compacto.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.size = 30});

  final double size;

  @override
  Widget build(BuildContext context) {
    if (FlamColors.palette.isSolid) {
      return Text(
        'flamengos',
        style: TextStyle(
          fontSize: size * 0.82,
          height: 1.3,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.04 * size,
          color: FlamColors.pink,
        ),
      );
    }
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: FlamGradients.logo.createShader,
      child: Text(
        'Flamengos',
        style: TextStyle(fontFamily: 'Pacifico', fontSize: size, height: 1.3),
      ),
    );
  }
}

/// El flamenco de la marca (el mismo dibujo del ícono de la app).
class FlamLogo extends StatelessWidget {
  const FlamLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/flamingo.png',
    width: size,
    height: size,
    filterQuality: FilterQuality.medium,
  );
}

/// Late suavemente (splash, celebraciones).
class Heartbeat extends StatefulWidget {
  const Heartbeat({super.key, required this.child, this.scale = 0.12});

  final Widget child;
  final double scale;

  @override
  State<Heartbeat> createState() => _HeartbeatState();
}

class _HeartbeatState extends State<Heartbeat>
    with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: Tween(
      begin: 1.0,
      end: 1 + widget.scale,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut)),
    child: widget.child,
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.explore_outlined,
    this.action,
  });

  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: FlamColors.pink.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 34, color: FlamColors.pink),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: FlamColors.textMuted, height: 1.4),
              ),
              if (action != null) ...[const SizedBox(height: 24), action!],
            ],
          ),
        ),
      ),
    );
  }
}
