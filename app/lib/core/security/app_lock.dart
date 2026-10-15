import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockState {
  const AppLockState({this.enabled = false, this.locked = false});

  /// El usuario activó el bloqueo con huella / rostro.
  final bool enabled;

  /// Hay que desbloquear antes de ver la app.
  final bool locked;
}

/// Bloqueo con biometría. La sesión de Supabase sigue abierta; esto solo
/// pide huella, rostro o el PIN del teléfono al abrir la app o al volver
/// a ella después de [relockAfter] en segundo plano. Solo Android e iOS.
final appLockProvider = NotifierProvider<AppLockController, AppLockState>(
  AppLockController.new,
);

class AppLockController extends Notifier<AppLockState> {
  static const _key = 'security.biometric';
  static const relockAfter = Duration(minutes: 1);

  static bool get platformSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  final _auth = LocalAuthentication();
  DateTime? _hiddenAt;

  /// El diálogo del sistema también manda la app a segundo plano.
  bool _authenticating = false;

  @override
  AppLockState build() {
    if (!platformSupported) return const AppLockState();
    final lifecycle = AppLifecycleListener(
      onHide: () {
        if (!_authenticating) _hiddenAt = DateTime.now();
      },
      onShow: () {
        final hiddenAt = _hiddenAt;
        _hiddenAt = null;
        if (state.enabled &&
            hiddenAt != null &&
            DateTime.now().difference(hiddenAt) >= relockAfter) {
          state = const AppLockState(enabled: true, locked: true);
        }
      },
    );
    ref.onDispose(lifecycle.dispose);
    _load();
    return const AppLockState();
  }

  Future<void> _load() async {
    try {
      final enabled =
          (await SharedPreferences.getInstance()).getBool(_key) ?? false;
      state = AppLockState(enabled: enabled, locked: enabled);
    } catch (_) {
      // Sin almacenamiento: sin bloqueo.
    }
  }

  /// ¿El teléfono tiene huella, rostro o al menos PIN/patrón?
  Future<bool> available() async {
    if (!platformSupported) return false;
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> _authenticate(String reason) async {
    _authenticating = true;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException {
      return false;
    } finally {
      _authenticating = false;
    }
  }

  Future<bool> unlock(String reason) async {
    final ok = await _authenticate(reason);
    if (ok) state = AppLockState(enabled: state.enabled);
    return ok;
  }

  /// Activarlo exige pasar la biometría una vez (así sabemos que funciona).
  Future<bool> setEnabled(bool enabled, String reason) async {
    if (enabled && !await _authenticate(reason)) return false;
    state = AppLockState(enabled: enabled);
    try {
      await (await SharedPreferences.getInstance()).setBool(_key, enabled);
    } catch (_) {}
    return true;
  }

  /// Al cerrar sesión no tiene sentido seguir bloqueado.
  void release() => state = AppLockState(enabled: state.enabled);
}
