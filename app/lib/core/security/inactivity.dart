import 'package:shared_preferences/shared_preferences.dart';

/// Si la app no se abre en este tiempo, la sesión se cierra sola.
/// Es largo a propósito: la idea es no sacar a quien usa la app, solo
/// proteger teléfonos perdidos o cuentas olvidadas.
const inactivityLimit = Duration(days: 30);

const _key = 'security.last_seen';

/// Marca "visto ahora" y dice si pasó demasiado tiempo desde la última vez.
Future<bool> checkInactivity() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt(_key);
    final now = DateTime.now();
    await prefs.setInt(_key, now.millisecondsSinceEpoch);
    if (last == null) return false;
    return now.difference(DateTime.fromMillisecondsSinceEpoch(last)) >
        inactivityLimit;
  } catch (_) {
    return false;
  }
}
