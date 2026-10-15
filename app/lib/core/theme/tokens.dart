import 'package:flutter/material.dart';

/// Temas disponibles. Cada uno es una [FlamPalette] con su propio lenguaje:
/// Firefly (noche rosa), Spicebug (verde profundo) y Cricket (minimalista
/// estilo iOS, claro u oscuro).
///
/// Los nombres `light` y `dark` se conservan para no perder lo que ya
/// guardaron los usuarios: son las dos variantes de Cricket.
enum FlamTheme { firefly, spicebug, light, dark }

/// Cómo se ven las tarjetas y paneles del tema.
enum FlamSurface {
  /// Vidrio translúcido con borde fino sobre un fondo con luces.
  glass,

  /// Tarjetas opacas sin borde sobre un fondo liso (estilo iOS).
  solid,
}

/// Todo lo visual de un tema: fondo, superficies, texto y acentos.
class FlamPalette {
  const FlamPalette({
    required this.brightness,
    required this.surface,
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
    required this.accent,
    required this.accentEnd,
    required this.accentAlt,
    required this.onAccent,
    required this.accentShadow,
    required this.field,
  });

  final Brightness brightness;
  final FlamSurface surface;

  /// Fondo más profundo (y el hueco del anillo de los avatares).
  final Color night;

  /// Superficie base (placeholders, canvas).
  final Color plum;

  /// Acento para textos y enlaces (legible sobre el fondo del tema).
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

  /// Acento principal y el final de su degradado (igual = color sólido).
  final Color accent;
  final Color accentEnd;

  /// Acento secundario (detalles, mapas, gráficos).
  final Color accentAlt;

  /// Texto e íconos sobre el acento.
  final Color onAccent;

  /// Resplandor bajo los botones principales (null = sin resplandor).
  final Color? accentShadow;

  /// Relleno de los campos de texto.
  final Color field;

  bool get isSolid => surface == FlamSurface.solid;

  /// Firefly: noche rosa y violeta, vidrio y luces suaves.
  static const firefly = FlamPalette(
    brightness: Brightness.dark,
    surface: FlamSurface.glass,
    night: Color(0xFF15081C),
    plum: Color(0xFF261030),
    blush: Color(0xFFFFC2D6),
    text: Color(0xFFFFF7FA),
    textMuted: Color(0xB3FFF7FA),
    textFaint: Color(0x80FFF7FA),
    glassBorder: Color(0x26FFFFFF),
    glassFill: Color(0x12FFFFFF),
    glass: [Color(0x21FFFFFF), Color(0x0AFFFFFF)],
    frosted: [Color(0x80301238), Color(0xB31A0A22)],
    sheet: Color(0xF5221029),
    background: [Color(0xFF15081C), Color(0xFF221029), Color(0xFF15081C)],
    glows: [
      (Offset(0.0, 0.0), 0.80, Color(0xFFFF5C93), 0.30),
      (Offset(1.0, 0.55), 0.70, Color(0xFF8A5CFF), 0.22),
    ],
    mapStyle: 'streets-v4-dark',
    accent: Color(0xFFFF5C93),
    accentEnd: Color(0xFFFF8A7A),
    accentAlt: Color(0xFF9B7BFF),
    onAccent: Colors.white,
    accentShadow: Color(0x4DFF5C93),
    field: Color(0x17FFFFFF),
  );

  /// Spicebug: verde botella profundo con acento esmeralda y lima.
  static const spicebug = FlamPalette(
    brightness: Brightness.dark,
    surface: FlamSurface.glass,
    night: Color(0xFF07120D),
    plum: Color(0xFF0F2119),
    blush: Color(0xFFB4F0CF),
    text: Color(0xFFF0F5EC),
    textMuted: Color(0xADF0F5EC),
    textFaint: Color(0x7AF0F5EC),
    glassBorder: Color(0x24D9FBE8),
    glassFill: Color(0x10D9FBE8),
    glass: [Color(0x1CD9FBE8), Color(0x08D9FBE8)],
    frosted: [Color(0x80102A1E), Color(0xB307120D)],
    sheet: Color(0xF50E1F17),
    background: [Color(0xFF07120D), Color(0xFF0E2219), Color(0xFF07120D)],
    glows: [
      (Offset(0.0, 0.05), 0.80, Color(0xFF2FBF7F), 0.26),
      (Offset(1.0, 0.70), 0.65, Color(0xFF1AA6A6), 0.18),
    ],
    mapStyle: 'streets-v4-dark',
    accent: Color(0xFF3DDC97),
    accentEnd: Color(0xFFB8E86B),
    accentAlt: Color(0xFF2CC5C5),
    onAccent: Color(0xFF05140D),
    accentShadow: Color(0x403DDC97),
    field: Color(0x14D9FBE8),
  );

  /// Cricket claro: minimalista estilo iOS. Fondo agrupado, tarjetas blancas.
  static const light = FlamPalette(
    brightness: Brightness.light,
    surface: FlamSurface.solid,
    night: Color(0xFFFFFFFF),
    plum: Color(0xFFE5E5EA),
    blush: Color(0xFFE8335F),
    text: Color(0xFF1C1C1E),
    textMuted: Color(0x993C3C43),
    textFaint: Color(0x4D3C3C43),
    glassBorder: Color(0x1F3C3C43),
    glassFill: Color(0x0A000000),
    glass: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
    frosted: [Color(0xEBF9F9F9), Color(0xF2F9F9F9)],
    sheet: Color(0xFFFFFFFF),
    background: [Color(0xFFF2F2F7), Color(0xFFF2F2F7), Color(0xFFF2F2F7)],
    glows: [],
    mapStyle: 'streets-v4',
    accent: Color(0xFFFF2D55),
    accentEnd: Color(0xFFFF2D55),
    accentAlt: Color(0xFF5856D6),
    onAccent: Colors.white,
    accentShadow: null,
    field: Color(0xFFEEEEF0),
  );

  /// Cricket oscuro: el mismo minimalismo sobre negro.
  static const dark = FlamPalette(
    brightness: Brightness.dark,
    surface: FlamSurface.solid,
    night: Color(0xFF000000),
    plum: Color(0xFF2C2C2E),
    blush: Color(0xFFFF6482),
    text: Color(0xFFFFFFFF),
    textMuted: Color(0x99EBEBF5),
    textFaint: Color(0x4DEBEBF5),
    glassBorder: Color(0x29545458),
    glassFill: Color(0x14FFFFFF),
    glass: [Color(0xFF1C1C1E), Color(0xFF1C1C1E)],
    frosted: [Color(0xE61C1C1E), Color(0xF21C1C1E)],
    sheet: Color(0xFF1C1C1E),
    background: [Color(0xFF000000), Color(0xFF000000), Color(0xFF000000)],
    glows: [],
    mapStyle: 'streets-v4-dark',
    accent: Color(0xFFFF375F),
    accentEnd: Color(0xFFFF375F),
    accentAlt: Color(0xFF5E5CE6),
    onAccent: Colors.white,
    accentShadow: null,
    field: Color(0xFF2C2C2E),
  );

  static FlamPalette of(FlamTheme theme) => switch (theme) {
    FlamTheme.firefly => firefly,
    FlamTheme.spicebug => spicebug,
    FlamTheme.light => light,
    FlamTheme.dark => dark,
  };
}

/// Colores de la app, del tema activo ([palette]). Al cambiar de tema la app
/// se reconstruye completa (ver `FlamengosApp`), así que todos los widgets
/// leen la paleta nueva.
abstract final class FlamColors {
  static FlamPalette palette = FlamPalette.firefly;

  // Acentos del tema (los nombres vienen del tema original, Firefly).
  static Color get pink => palette.accent;
  static Color get coral => palette.accentEnd;
  static Color get violet => palette.accentAlt;

  // Semánticos (iguales en todos los temas)
  static const mint = Color(0xFF2DD4BF);
  static const danger = Color(0xFFFF5A5F);

  /// Texto sobre el acento (botones principales, burbujas propias).
  static Color get onAccent => palette.onAccent;

  /// Texto sobre fotos (siempre blanco: va sobre un velo oscuro).
  static const onPhoto = Colors.white;
  static const onPhotoMuted = Color(0xD9FFFFFF);

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
  static LinearGradient get primary => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [FlamColors.pink, FlamColors.coral],
  );

  static const danger = LinearGradient(
    colors: [FlamColors.danger, FlamColors.danger],
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

  static LinearGradient get logo => LinearGradient(
    colors: [FlamColors.blush, FlamColors.pink, FlamColors.coral],
  );

  /// Velo oscuro sobre las fotos (igual en todos los temas).
  static const scrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.5, 1],
    colors: [Colors.transparent, Color(0xD90A0A0C)],
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
  static List<BoxShadow> get glow {
    final color = FlamColors.palette.accentShadow;
    return color == null
        ? const []
        : [
            BoxShadow(
              color: color,
              blurRadius: 28,
              spreadRadius: -6,
              offset: const Offset(0, 10),
            ),
          ];
  }

  /// Sombra de tarjetas: suave en temas claros, casi nula en oscuros.
  static List<BoxShadow> get soft => [
    BoxShadow(
      color: FlamColors.palette.brightness == Brightness.light
          ? const Color(0x141C1C1E)
          : const Color(0x40000000),
      blurRadius: 32,
      spreadRadius: -10,
      offset: const Offset(0, 14),
    ),
  ];
}
