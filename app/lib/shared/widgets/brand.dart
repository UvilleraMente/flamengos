import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import 'glass.dart';

/// Logotipo "Flamengos" en letra script con degradado.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.size = 30});

  final double size;

  @override
  Widget build(BuildContext context) {
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
    this.emoji = '🦩',
    this.action,
  });

  final String title;
  final String message;
  final String emoji;
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
              Glass(
                radius: FlamRadius.pill,
                padding: const EdgeInsets.all(26),
                child: Text(emoji, style: const TextStyle(fontSize: 48)),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
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
