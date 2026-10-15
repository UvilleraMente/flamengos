import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/cased_localizations.dart';
import 'tokens.dart';

/// Fuentes incluidas en la app (assets/fonts).
enum FlamFont {
  outfit('Outfit'),
  nunito('Nunito'),
  lora('Lora'),
  quicksand('Quicksand');

  const FlamFont(this.family);
  final String family;
}

/// Formato de letras de los textos de la interfaz (no del contenido de los
/// usuarios: nombres, bios y chat se muestran tal como se escribieron).
enum TextCase { normal, upper, lower, title }

String applyTextCase(TextCase textCase, String s) => switch (textCase) {
  TextCase.normal => s,
  TextCase.upper => s.toUpperCase(),
  TextCase.lower => s.toLowerCase(),
  TextCase.title =>
    s
        .split(' ')
        .map(
          (w) =>
              w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase(),
        )
        .join(' '),
};

@immutable
class Appearance {
  const Appearance({
    this.theme = FlamTheme.firefly,
    this.font = FlamFont.outfit,
    this.textScale = 1.0,
    this.textCase = TextCase.normal,
  });

  static const minScale = 0.85;
  static const maxScale = 1.3;

  final FlamTheme theme;
  final FlamFont font;
  final double textScale;
  final TextCase textCase;

  Appearance copyWith({
    FlamTheme? theme,
    FlamFont? font,
    double? textScale,
    TextCase? textCase,
  }) => Appearance(
    theme: theme ?? this.theme,
    font: font ?? this.font,
    textScale: textScale ?? this.textScale,
    textCase: textCase ?? this.textCase,
  );

  @override
  bool operator ==(Object other) =>
      other is Appearance &&
      other.theme == theme &&
      other.font == font &&
      other.textScale == textScale &&
      other.textCase == textCase;

  @override
  int get hashCode => Object.hash(theme, font, textScale, textCase);
}

final appearanceProvider = NotifierProvider<AppearanceController, Appearance>(
  AppearanceController.new,
);

/// Preferencias visuales, guardadas en el dispositivo.
class AppearanceController extends Notifier<Appearance> {
  static const _theme = 'appearance.theme';
  static const _font = 'appearance.font';
  static const _scale = 'appearance.scale';
  static const _case = 'appearance.case';

  @override
  Appearance build() {
    _load();
    return const Appearance();
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      T pick<T extends Enum>(List<T> values, String key, T fallback) =>
          values.asNameMap()[p.getString(key)] ?? fallback;
      state = Appearance(
        theme: pick(FlamTheme.values, _theme, FlamTheme.firefly),
        font: pick(FlamFont.values, _font, FlamFont.outfit),
        textScale: (p.getDouble(_scale) ?? 1.0).clamp(
          Appearance.minScale,
          Appearance.maxScale,
        ),
        textCase: pick(TextCase.values, _case, TextCase.normal),
      );
    } catch (_) {
      // Sin almacenamiento: valores por defecto.
    }
  }

  Future<void> update(Appearance next) async {
    state = next;
    try {
      final p = await SharedPreferences.getInstance();
      await Future.wait([
        p.setString(_theme, next.theme.name),
        p.setString(_font, next.font.name),
        p.setDouble(_scale, next.textScale),
        p.setString(_case, next.textCase.name),
      ]);
    } catch (_) {}
  }
}

/// Carga las traducciones y les aplica el formato de letras elegido.
class CasedLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const CasedLocalizationsDelegate(this.textCase);

  final TextCase textCase;

  /// Reemplaza a AppLocalizations.localizationsDelegates.
  static List<LocalizationsDelegate<dynamic>> all(TextCase textCase) => [
    CasedLocalizationsDelegate(textCase),
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.delegate.isSupported(locale);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final base = await AppLocalizations.delegate.load(locale);
    if (textCase == TextCase.normal) return base;
    return CasedLocalizations(base, (s) => applyTextCase(textCase, s));
  }

  @override
  bool shouldReload(CasedLocalizationsDelegate old) => old.textCase != textCase;
}
