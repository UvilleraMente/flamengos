import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/tokens.dart';
import 'glass.dart';

/// "23 h 10 min", "42 min", "menos de 1 min" — en el idioma activo.
String formatRemaining(Duration d, AppLocalizations t) {
  if (d.inMinutes < 1) return t.timeLessThanMinute;
  final h = d.inHours;
  final m = d.inMinutes % 60;
  return h == 0 ? t.timeMinutes(m) : t.timeHoursMinutes(h, m);
}

/// Cuenta regresiva en una pastilla de vidrio.
/// [label] recibe el tiempo ya formateado (para poder traducir la frase).
/// Se pone coral cuando queda menos de [warnBelow]. Llama [onDone] al llegar a cero.
class CountdownPill extends StatefulWidget {
  const CountdownPill({
    super.key,
    required this.until,
    required this.label,
    this.onDone,
    this.warnBelow = const Duration(hours: 3),
  });

  final DateTime until;
  final String Function(String remaining) label;
  final VoidCallback? onDone;
  final Duration warnBelow;

  @override
  State<CountdownPill> createState() => _CountdownPillState();
}

class _CountdownPillState extends State<CountdownPill> {
  late final Timer _timer;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _tick());
    WidgetsBinding.instance.addPostFrameCallback((_) => _tick());
  }

  void _tick() {
    if (!mounted) return;
    setState(() {});
    if (!_done && !widget.until.isAfter(DateTime.now())) {
      _done = true;
      widget.onDone?.call();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.until.difference(DateTime.now());
    final urgent = left < widget.warnBelow;
    return GlassPill(
      color: urgent ? FlamColors.coral : null,
      leading: Icon(
        urgent ? Icons.hourglass_bottom_rounded : Icons.hourglass_top_rounded,
        size: 14,
      ),
      child: Text(widget.label(formatRemaining(left, context.l10n))),
    );
  }
}
