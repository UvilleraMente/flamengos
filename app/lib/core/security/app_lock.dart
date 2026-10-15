import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import '../supabase/supabase_providers.dart';

class AppLockState {
  const AppLockState({this.enabled = false, this.locked = false});

  /// El usuario activó el bloqueo con huella / rostro.
  final bool enabled;

  /// Hay que desbloquear antes de ver la app.
  final bool locked;
}

/// Huella / rostro, en dos partes que se activan juntas:
/// * Bloqueo: con la sesión abierta, pide la biometría al abrir la app o al
///   volver después de [relockAfter] en segundo plano.
/// * Entrar con huella: tras cerrar sesión, el login ofrece entrar con la
///   biometría usando el correo y la contraseña guardados cifrados en el
///   teléfono (Keystore en Android, Keychain en iOS).
/// Solo Android e iOS.
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

  static const _emailKey = 'bio.email';
  static const _passwordKey = 'bio.password';

  final _auth = LocalAuthentication();
  final _vault = const FlutterSecureStorage();
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
    // Si acaba de iniciar sesión (con contraseña o huella), ya se identificó.
    ref.listen(currentUserIdProvider, (before, now) {
      if (before == null && now != null) release();
    });
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

  /// Activarlo exige pasar la biometría una vez (así sabemos que funciona)
  /// y guarda las credenciales para "Entrar con huella".
  Future<bool> enable({
    required String email,
    required String password,
    required String reason,
  }) async {
    if (!await _authenticate(reason)) return false;
    await _vault.write(key: _emailKey, value: email);
    await _vault.write(key: _passwordKey, value: password);
    await _save(true);
    return true;
  }

  /// Apaga el bloqueo y borra las credenciales guardadas.
  Future<void> disable() async {
    await _save(false);
    try {
      await _vault.delete(key: _emailKey);
      await _vault.delete(key: _passwordKey);
    } catch (_) {}
  }

  Future<void> _save(bool enabled) async {
    state = AppLockState(enabled: enabled);
    try {
      await (await SharedPreferences.getInstance()).setBool(_key, enabled);
    } catch (_) {}
  }

  /// ¿El login puede ofrecer "Entrar con huella"?
  Future<bool> canSignInWithBiometrics() async {
    if (!platformSupported) return false;
    try {
      return await _vault.read(key: _emailKey) != null;
    } catch (_) {
      return false;
    }
  }

  /// Pide la biometría y entra con lo guardado. Si la contraseña ya no sirve
  /// (la cambió), borra lo guardado y deja que [signIn] lance el error.
  Future<bool> signInWithBiometrics(
    String reason,
    Future<void> Function(String email, String password) signIn,
  ) async {
    if (!await _authenticate(reason)) return false;
    final email = await _vault.read(key: _emailKey);
    final password = await _vault.read(key: _passwordKey);
    if (email == null || password == null) return false;
    try {
      await signIn(email, password);
    } on AuthException {
      // Contraseña cambiada: lo guardado ya no sirve.
      await disable();
      rethrow;
    }
    return true;
  }

  /// Al cerrar sesión no tiene sentido seguir bloqueado.
  void release() => state = AppLockState(enabled: state.enabled);
}
