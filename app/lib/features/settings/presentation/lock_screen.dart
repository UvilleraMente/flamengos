import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/security/app_lock.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/feedback.dart';
import '../../../shared/widgets/widgets.dart';
import '../../auth/data/auth_repository.dart';

/// Cubre toda la app hasta que la persona pasa la biometría.
/// Va en el `builder` de MaterialApp, fuera del Navigator.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Pide la huella apenas aparece.
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  Future<void> _unlock() async {
    if (_busy || !mounted) return;
    setState(() => _busy = true);
    await ref.read(appLockProvider.notifier).unlock(context.l10n.lockReason);
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _signOut() async {
    ref.read(appLockProvider.notifier).release();
    await ref.read(authRepositoryProvider).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return FlamingoBackground(
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FlamLogo(size: 96),
                  const SizedBox(height: 8),
                  const Wordmark(size: 38),
                  const SizedBox(height: 28),
                  Icon(Icons.lock_rounded, color: FlamColors.textMuted),
                  const SizedBox(height: 10),
                  Text(
                    t.lockTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.lockMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: FlamColors.textMuted),
                  ),
                  const SizedBox(height: 28),
                  FlamButton(
                    label: t.lockUnlock,
                    icon: const Icon(Icons.fingerprint_rounded),
                    size: FlamSize.large,
                    loading: _busy,
                    onPressed: _unlock,
                  ),
                  const SizedBox(height: 8),
                  FlamButton(
                    label: t.actionSignOut,
                    variant: FlamVariant.ghost,
                    onPressed: _signOut,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Interruptor en Ajustes → Seguridad (solo en Android e iOS).
class BiometricLockTile extends ConsumerStatefulWidget {
  const BiometricLockTile({super.key});

  @override
  ConsumerState<BiometricLockTile> createState() => _BiometricLockTileState();
}

class _BiometricLockTileState extends ConsumerState<BiometricLockTile> {
  bool _busy = false;

  Future<void> _toggle(bool enabled) async {
    final t = context.l10n;
    final lock = ref.read(appLockProvider.notifier);
    if (enabled && !await lock.available()) {
      if (mounted) showInfo(context, t.lockUnavailable);
      return;
    }
    setState(() => _busy = true);
    await lock.setEnabled(enabled, t.lockReason);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return SettingsTile(
      icon: Icons.fingerprint_rounded,
      color: const Color(0xFF34C759),
      title: t.lockSetting,
      subtitle: t.lockSettingHint,
      trailing: Switch.adaptive(
        value: ref.watch(appLockProvider).enabled,
        onChanged: _busy ? null : _toggle,
      ),
    );
  }
}
