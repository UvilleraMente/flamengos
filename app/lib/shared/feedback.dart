import 'package:flutter/material.dart';

import '../core/errors.dart';
import '../core/l10n/l10n.dart';
import '../core/theme/tokens.dart';
import 'widgets/widgets.dart';

void showError(BuildContext context, Object error) =>
    showInfo(context, describeError(context, error));

void showInfo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Diálogo de vidrio que aparece con un pequeño rebote.
Future<T?> showGlassDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool dismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: const Color(0x99000000),
    transitionDuration: FlamMotion.slow,
    pageBuilder: (context, _, _) => SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Material(
              type: MaterialType.transparency,
              child: Glass(
                blur: true,
                radius: FlamRadius.xl,
                padding: const EdgeInsets.all(24),
                child: builder(context),
              ),
            ),
          ),
        ),
      ),
    ),
    transitionBuilder: (_, animation, _, child) => FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ).drive(Tween(begin: 0.85, end: 1)),
        child: child,
      ),
    ),
  );
}

Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String message,
  required String action,
  String emoji = '🦩',
  bool destructive = false,
}) async {
  final ok = await showGlassDialog<bool>(
    context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 44)),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: FlamColors.textMuted, height: 1.4),
        ),
        const SizedBox(height: 24),
        FlamButton(
          label: action,
          expand: true,
          variant: destructive ? FlamVariant.danger : FlamVariant.primary,
          onPressed: () => Navigator.pop(context, true),
        ),
        const SizedBox(height: 8),
        FlamButton(
          label: context.l10n.actionCancel,
          expand: true,
          variant: FlamVariant.ghost,
          onPressed: () => Navigator.pop(context, false),
        ),
      ],
    ),
  );
  return ok ?? false;
}
