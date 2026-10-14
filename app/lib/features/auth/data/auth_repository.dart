import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(ref.watch(supabaseProvider)),
);

/// true mientras el usuario entró con un enlace/código de recuperación y
/// todavía no eligió su contraseña nueva. El router lo manda a /reset-password.
final passwordRecoveryProvider =
    NotifierProvider<PasswordRecoveryController, bool>(
      PasswordRecoveryController.new,
    );

class PasswordRecoveryController extends Notifier<bool> {
  @override
  bool build() {
    final sub = ref.watch(supabaseProvider).auth.onAuthStateChange.listen((s) {
      switch (s.event) {
        case AuthChangeEvent.passwordRecovery:
          state = true;
        case AuthChangeEvent.signedOut:
          state = false;
        default:
          break;
      }
    });
    ref.onDispose(sub.cancel);
    return false;
  }

  void done() => state = false;
}

class AuthRepository {
  AuthRepository(this._db);

  final SupabaseClient _db;

  /// A dónde vuelve el enlace del correo: la misma web, o la app por deep link.
  static String get redirectUrl =>
      kIsWeb ? Uri.base.origin : 'com.flamengos.flamengos://login-callback';

  Future<void> signIn(String email, String password) =>
      _db.auth.signInWithPassword(email: email, password: password);

  /// Devuelve false si hace falta confirmar el correo antes de entrar.
  Future<bool> signUp(String email, String password) async {
    final res = await _db.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: redirectUrl,
    );
    return res.session != null;
  }

  Future<void> signOut() => _db.auth.signOut();

  /// Envía el correo de recuperación (enlace + código de 6 dígitos).
  Future<void> sendPasswordReset(String email) =>
      _db.auth.resetPasswordForEmail(email, redirectTo: redirectUrl);

  /// Verifica el código del correo. Si es válido, inicia una sesión de
  /// recuperación (dispara `passwordRecovery`).
  Future<void> verifyRecoveryCode(String email, String code) =>
      _db.auth.verifyOTP(email: email, token: code, type: OtpType.recovery);

  Future<void> updatePassword(String password) =>
      _db.auth.updateUser(UserAttributes(password: password));

  /// Borra fotos y selfies del usuario y luego la cuenta completa.
  /// La base de datos borra en cascada perfil, solicitudes, pareja y chat.
  Future<void> deleteAccount() async {
    final uid = _db.myId;
    for (final bucket in ['photos', 'verifications']) {
      final files = await _db.storage.from(bucket).list(path: uid);
      if (files.isNotEmpty) {
        await _db.storage.from(bucket).remove([
          for (final f in files) '$uid/${f.name}',
        ]);
      }
    }
    await _db.rpc('delete_my_account');
    // El usuario ya no existe en el servidor; limpiamos la sesión local.
    await _db.auth.signOut(scope: SignOutScope.local).catchError((_) {});
  }
}
