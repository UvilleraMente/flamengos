import 'package:flutter/material.dart';

/// Temas disponibles. Cada uno es una [FlamPalette].
enum FlamTheme { firefly, light, dark }

/// Todos los colores de un tema. Los acentos (rosa, coral…) son de marca y
/// casi no cambian; lo que cambia es el fondo, el vidrio y el texto.
class FlamPalette {
  const FlamPalette({
    required this.brightness,
    required this.night,
    required this.plum,
    required this.blush,
    required this.text,
    required this.textMuted,
    required this.textFaint,
    required this.glassBorder,
    required this.glassFill,
    required this.glass,
    required this.frosted,
    required this.sheet,
    required this.background,
    required this.glows,
    required this.mapStyle,
  });

  final Brightness brightness;

  /// Fondo más profundo (y el hueco del anillo de los avatares).
  final Color night;

  /// Superficie base (placeholders, canvas).
  final Color plum;

  /// Rosa para textos y enlaces (legible sobre el fondo del tema).
  final Color blush;
  final Color text;
  final Color textMuted;
  final Color textFaint;
  final Color glassBorder;
  final Color glassFill;
  final List<Color> glass;
  final List<Color> frosted;
  final Color sheet;
  final List<Color> background;

  /// Luces del fondo: (posición relativa, radio, color, opacidad).
  final List<(Offset, double, Color, double)> glows;

  /// Estilo de MapTiler que combina con el tema.
  final String mapStyle;

  static const firefly = FlamPalette(
    brightness: Brightness.dark,
    night: Color(0xFF16081F),
    plum: Color(0xFF2A0E36),
    blush: Color(0xFFFFC2D6),
    text: Colors.white,
    textMuted: Color(0xB3FFFFFF),
    textFaint: Color(0x80FFFFFF),
    glassBorder: Color(0x33FFFFFF),
    glassFill: Color(0x14FFFFFF),
    glass: [Color(0x2BFFFFFF), Color(0x0AFFFFFF)],
    frosted: [Color(0x66351342), Color(0x99200A2A)],
    sheet: Color(0xF2251030),
    background: [Color(0xFF16081F), Color(0xFF2A0E36), Color(0xFF16081F)],
    glows: [
      (Offset(0.05, 0.08), 0.75, FlamColors.pink, 0.45),
      (Offset(1.0, 0.42), 0.65, FlamColors.violet, 0.40),
      (Offset(0.15, 0.98), 0.70, FlamColors.coral, 0.30),
    ],
    mapStyle: 'streets-v4-dark',
  );

  static const light = FlamPalette(
    brightness: Brightness.light,
    night: Color(0xFFFFFFFF),
    plum: Color(0xFFF6EEF2),
    blush: Color(0xFFD93D74),
    text: Color(0xFF1E1424),
    textMuted: Color(0xA61E1424),
    textFaint: Color(0x731E1424),
    glassBorder: Color(0x1A1E1424),
    glassFill: Color(0x0D1E1424),
    glass: [Color(0xF2FFFFFF), Color(0xCCFFFFFF)],
    frosted: [Color(0xD9FFFFFF), Color(0xF2FFFFFF)],
    sheet: Color(0xFAFFFFFF),
    background: [Color(0xFFFFF7FA), Color(0xFFFFFFFF), Color(0xFFFDF2F6)],
    glows: [
      (Offset(0.05, 0.08), 0.75, FlamColors.pink, 0.16),
      (Offset(1.0, 0.42), 0.65, FlamColors.violet, 0.09),
      (Offset(0.15, 0.98), 0.70, FlamColors.coral, 0.14),
    ],
    mapStyle: 'streets-v4',
  );

  static const dark = FlamPalette(
    brightness: Brightness.dark,
    night: Color(0xFF0B0B0E),
    plum: Color(0xFF17171C),
    blush: Color(0xFFFF9FBF),
    text: Colors.white,
    textMuted: Color(0xB3FFFFFF),
    textFaint: Color(0x80FFFFFF),
    glassBorder: Color(0x24FFFFFF),
    glassFill: Color(0x0FFFFFFF),
    glass: [Color(0x1AFFFFFF), Color(0x08FFFFFF)],
    frosted: [Color(0x99141418), Color(0xCC0B0B0E)],
    sheet: Color(0xF219191E),
    background: [Color(0xFF0B0B0E), Color(0xFF131317), Color(0xFF0B0B0E)],
    glows: [
      (Offset(0.05, 0.08), 0.75, FlamColors.pink, 0.12),
      (Offset(1.0, 0.42), 0.65, FlamColors.violet, 0.07),
      (Offset(0.15, 0.98), 0.70, FlamColors.coral, 0.06),
    ],
    mapStyle: 'streets-v4-dark',
  );

  static FlamPalette of(FlamTheme theme) => switch (theme) {
    FlamTheme.firefly => firefly,
    FlamTheme.light => light,
    FlamTheme.dark => dark,
  };
}

/// Colores de la app. Los de marca son constantes; los demás salen del tema
/// activo ([palette]). Al cambiar de tema la app se reconstruye completa
/// (ver `FlamengosApp`), así que todos los widgets leen la paleta nueva.
abstract final class FlamColors {
  static FlamPalette palette = FlamPalette.firefly;

  // Marca (iguales en todos los temas)
  static const pink = Color(0xFFFF5C93);
  static const coral = Color(0xFFFF9A76);
  static const violet = Color(0xFF8A5CFF);
  static const mint = Color(0xFF2DD4BF);
  static const danger = Color(0xFFFF6B6B);

  /// Texto sobre degradados de marca (botones principales, burbujas propias).
  static const onAccent = Colors.white;

  /// Texto sobre fotos (siempre blanco: va sobre un velo oscuro).
  static const onPhoto = Colors.white;
  static const onPhotoMuted = Color(0xD9FFFFFF);

  // Del tema activo
  static Color get night => palette.night;
  static Color get plum => palette.plum;
  static Color get blush => palette.blush;
  static Color get text => palette.text;
  static Color get textMuted => palette.textMuted;
  static Color get textFaint => palette.textFaint;
  static Color get glassBorder => palette.glassBorder;
  static Color get glassFill => palette.glassFill;

  /// Fondo de superficies flotantes (diálogos, hojas, snackbars).
  static Color get sheet => palette.sheet;
}

abstract final class FlamGradients {
  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [FlamColors.pink, FlamColors.coral],
  );

  static const danger = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [FlamColors.danger, Color(0xFFE0457B)],
  );

  static LinearGradient get glass => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: FlamColors.palette.glass,
  );

  /// Vidrio más opaco para cuando hay contenido moviéndose detrás (con blur).
  static LinearGradient get frosted => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: FlamColors.palette.frosted,
  );

  static const logo = LinearGradient(
    colors: [Color(0xFFFFB3CB), FlamColors.pink, FlamColors.coral],
  );

  /// Velo oscuro sobre las fotos (igual en todos los temas).
  static const scrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.45, 1],
    colors: [Colors.transparent, Color(0xE6140619)],
  );
}

abstract final class FlamRadius {
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 22.0;
  static const xl = 30.0;
  static const pill = 999.0;
}

abstract final class FlamMotion {
  static const fast = Duration(milliseconds: 140);
  static const medium = Duration(milliseconds: 280);
  static const slow = Duration(milliseconds: 450);
  static const curve = Curves.easeOutCubic;
}

abstract final class FlamShadows {
  static const glow = [
    BoxShadow(color: Color(0x55FF5C93), blurRadius: 22, offset: Offset(0, 8)),
  ];

  static List<BoxShadow> get soft => [
    BoxShadow(
      color: FlamColors.palette.brightness == Brightness.light
          ? const Color(0x1F1E1424)
          : const Color(0x40000000),
      blurRadius: 30,
      offset: const Offset(0, 12),
    ),
  ];
}
