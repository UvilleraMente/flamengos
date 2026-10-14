import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'locale';

/// Idioma elegido por el usuario. `null` = el del dispositivo.
final localeProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);

class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    try {
      final code = (await SharedPreferences.getInstance()).getString(_prefsKey);
      if (code != null) state = Locale(code);
    } catch (_) {
      // Sin almacenamiento (modo privado, etc.): se usa el idioma del dispositivo.
    }
  }

  Future<void> set(Locale? locale) async {
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      locale == null
          ? await prefs.remove(_prefsKey)
          : await prefs.setString(_prefsKey, locale.languageCode);
    } catch (_) {}
  }
}
