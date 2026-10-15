import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/env.dart';
import '../../../core/supabase/supabase_providers.dart';

final pushServiceProvider = Provider((ref) {
  final service = PushService(ref.watch(supabaseProvider));
  ref.onDispose(service.dispose);
  return service;
});

/// Registra este dispositivo para recibir notificaciones push (FCM).
/// Con la app abierta no se muestran: ya avisa el toast de la app.
class PushService {
  PushService(this._db);

  final SupabaseClient _db;
  StreamSubscription<String>? _refresh;

  static String get _platform => kIsWeb
      ? 'web'
      : defaultTargetPlatform == TargetPlatform.iOS
      ? 'ios'
      : 'android';

  /// En web hace falta la clave VAPID; sin ella, push en web queda apagado.
  static bool get isSupported => !kIsWeb || Env.firebaseVapidKey.isNotEmpty;

  /// Pide permiso (la primera vez) y guarda el token con el idioma del usuario.
  /// Nunca lanza: si algo falla, la app sigue funcionando sin push.
  Future<void> register({required String locale}) async {
    if (!isSupported) return;
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      final token = await messaging.getToken(
        vapidKey: kIsWeb ? Env.firebaseVapidKey : null,
      );
      if (token == null) return;
      await _save(token, locale);

      await _refresh?.cancel();
      _refresh = messaging.onTokenRefresh.listen(
        (t) => _save(t, locale).ignore(),
      );
    } catch (e) {
      debugPrint('Push no disponible: $e');
    }
  }

  /// Al cerrar sesión: este dispositivo deja de recibir avisos de la cuenta.
  Future<void> unregister() async {
    if (!isSupported) return;
    try {
      await _refresh?.cancel();
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken(
        vapidKey: kIsWeb ? Env.firebaseVapidKey : null,
      );
      if (token != null) {
        await _db.rpc('unregister_push_token', params: {'p_token': token});
      }
      await messaging.deleteToken();
    } catch (e) {
      debugPrint('No se pudo desregistrar push: $e');
    }
  }

  Future<void> _save(String token, String locale) => _db.rpc(
    'register_push_token',
    params: {
      'p_token': token,
      'p_platform': _platform,
      'p_locale': locale == 'en' ? 'en' : 'es',
    },
  );

  void dispose() => _refresh?.cancel();
}
