import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../../profile/domain/profile.dart';

enum Swipe { like, pass }

/// Mazo de tarjetas: arrastra a la derecha para pedir pareja y a la izquierda
/// para pasar. La tarjeta sale volando primero (optimista) y, si el servidor
/// rechaza la acción, regresa a su lugar.
class SwipeDeck extends StatefulWidget {
  const SwipeDeck({
    super.key,
    required this.profiles,
    required this.onSwipe,
    this.canLike = true,
  });

  final List<Profile> profiles;

  /// Debe quitar el perfil de [profiles] y devolver true, o devolver false
  /// para que la tarjeta regrese.
  final Future<bool> Function(Profile profile, Swipe swipe) onSwipe;
  final bool canLike;

  @override
  SwipeDeckState createState() => SwipeDeckState();
}

class SwipeDeckState extends State<SwipeDeck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: FlamMotion.medium,
  )..addListener(() => setState(() => _offset = _anim!.value));
  Animation<Offset>? _anim;
  Offset _offset = Offset.zero;
  bool _busy = false;

  /// Se actualiza en cada layout (LayoutBuilder en build).
  double _width = 400;
  double get _threshold => _width * 0.28;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _animateTo(Offset target) {
    _anim = Tween(
      begin: _offset,
      end: target,
    ).animate(CurvedAnimation(parent: _ctrl, curve: FlamMotion.curve));
    return _ctrl.forward(from: 0);
  }

  /// También la usan los botones de la página.
  Future<void> swipe(Swipe swipe) async {
    if (_busy || widget.profiles.isEmpty) return;
    if (swipe == Swipe.like && !widget.canLike) {
      await _animateTo(Offset.zero);
      return;
    }
    _busy = true;
    HapticFeedback.mediumImpact();
    final dir = swipe == Swipe.like ? 1 : -1;
    await _animateTo(Offset(dir * _width * 1.4, _offset.dy + 60));
    final ok = await widget.onSwipe(widget.profiles.first, swipe);
    if (!mounted) return;
    if (ok) {
      setState(() => _offset = Offset.zero);
    } else {
      await _animateTo(Offset.zero);
    }
    _busy = false;
  }

  void _onPanEnd(DragEndDetails d) {
    final vx = d.velocity.pixelsPerSecond.dx;
    if (_offset.dx > _threshold || vx > 900) {
      swipe(Swipe.like);
    } else if (_offset.dx < -_threshold || vx < -900) {
      swipe(Swipe.pass);
    } else {
      _animateTo(Offset.zero);
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      _width = box.maxWidth;
      return _buildDeck();
    },
  );

  Widget _buildDeck() {
    final profiles = widget.profiles;
    final progress = (_offset.dx.abs() / _threshold).clamp(0.0, 1.0);
    final liking = _offset.dx > 0;

    return Stack(
      children: [
        if (profiles.length > 1)
          Positioned.fill(
            child: Transform.scale(
              scale: 0.93 + 0.07 * progress,
              child: Opacity(
                opacity: 0.6 + 0.4 * progress,
                child: ProfileCard(profiles[1], key: ValueKey(profiles[1].id)),
              ),
            ),
          ),
        if (profiles.isNotEmpty)
          Positioned.fill(
            child: GestureDetector(
              onPanUpdate: _busy
                  ? null
                  : (d) => setState(() => _offset += d.delta),
              onPanEnd: _busy ? null : _onPanEnd,
              child: Transform.translate(
                offset: _offset,
                child: Transform.rotate(
                  angle: _offset.dx / _width * 0.35,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ProfileCard(
                        profiles.first,
                        key: ValueKey(profiles.first.id),
                      ),
                      if (progress > 0)
                        _Stamp(
                          like: liking,
                          opacity: progress,
                          blocked: liking && !widget.canLike,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Stamp extends StatelessWidget {
  const _Stamp({
    required this.like,
    required this.opacity,
    required this.blocked,
  });

  final bool like;
  final double opacity;
  final bool blocked;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final color = blocked
        ? FlamColors.textMuted
        : like
        ? FlamColors.pink
        : FlamColors.mint;
    final label = blocked
        ? t.stampLimit
        : like
        ? '🦩 ${t.stampLike}'
        : t.stampPass;
    return IgnorePointer(
      child: Align(
        alignment: like
            ? const Alignment(-0.75, -0.75)
            : const Alignment(0.75, -0.75),
        child: Opacity(
          opacity: opacity,
          child: Transform.rotate(
            angle: like ? -0.25 : 0.25,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 4),
                borderRadius: BorderRadius.circular(FlamRadius.sm),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
