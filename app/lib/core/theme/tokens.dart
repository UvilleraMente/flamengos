import 'package:flutter/material.dart';

/// Paleta Flamengos: noche de ciruela con luces de flamenco.
abstract final class FlamColors {
  static const night = Color(0xFF16081F);
  static const plum = Color(0xFF2A0E36);
  static const pink = Color(0xFFFF5C93);
  static const coral = Color(0xFFFF9A76);
  static const violet = Color(0xFF8A5CFF);
  static const blush = Color(0xFFFFC2D6);
  static const mint = Color(0xFF5EEAD4);
  static const danger = Color(0xFFFF6B6B);

  static const text = Colors.white;
  static const textMuted = Color(0xB3FFFFFF);
  static const textFaint = Color(0x80FFFFFF);

  static const glassBorder = Color(0x33FFFFFF);
  static const glassFill = Color(0x14FFFFFF);

  /// Fondo de superficies flotantes (diálogos, hojas, snackbars).
  static const sheet = Color(0xF2251030);
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

  static const glass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x2BFFFFFF), Color(0x0AFFFFFF)],
  );

  /// Vidrio más opaco para cuando hay contenido moviéndose detrás (con blur).
  static const frosted = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x66351342), Color(0x99200A2A)],
  );

  static const logo = LinearGradient(
    colors: [FlamColors.blush, FlamColors.pink, FlamColors.coral],
  );

  static const scrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.45, 1],
    colors: [Colors.transparent, Color(0xE6140619)],
  );
}

abstract final class FlamRadius {
  static const sm = 12.0;
  static const md = 18.0;
  static const lg = 24.0;
  static const xl = 32.0;
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
    BoxShadow(color: Color(0x66FF5C93), blurRadius: 24, offset: Offset(0, 8)),
  ];
  static const soft = [
    BoxShadow(color: Color(0x40000000), blurRadius: 30, offset: Offset(0, 12)),
  ];
}
