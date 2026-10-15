import 'package:flutter/material.dart';

import 'tokens.dart';

/// Tema de Material a partir de la paleta activa ([FlamColors.palette]) y la
/// fuente elegida. El fondo lo pinta FlamingoBackground, por eso los Scaffold
/// son transparentes.
ThemeData buildFlamTheme({String fontFamily = 'Outfit'}) {
  final palette = FlamColors.palette;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: FlamColors.pink,
        brightness: palette.brightness,
      ).copyWith(
        primary: FlamColors.pink,
        secondary: FlamColors.coral,
        tertiary: FlamColors.violet,
        surface: palette.plum,
        onSurface: palette.text,
        error: FlamColors.danger,
      );

  final base = ThemeData(
    brightness: palette.brightness,
    colorScheme: scheme,
    fontFamily: fontFamily,
  );

  // Campos estilo iOS: rellenos, sin borde visible y bien redondeados;
  // al enfocar aparece un anillo rosa.
  OutlineInputBorder field([Color? color, double width = 1.5]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(FlamRadius.md),
        borderSide: color == null
            ? BorderSide.none
            : BorderSide(color: color, width: width),
      );

  return base.copyWith(
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: palette.plum,
    textTheme: base.textTheme.apply(
      bodyColor: palette.text,
      displayColor: palette.text,
    ),
    iconTheme: IconThemeData(color: palette.text),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      foregroundColor: palette.text,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: palette.text,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.field,
      labelStyle: TextStyle(color: palette.textMuted),
      floatingLabelStyle: TextStyle(
        color: palette.blush,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(color: palette.textFaint),
      prefixIconColor: palette.textMuted,
      suffixIconColor: palette.textMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: field(),
      enabledBorder: field(),
      disabledBorder: field(),
      focusedBorder: field(FlamColors.pink),
      errorBorder: field(FlamColors.danger, 1),
      focusedErrorBorder: field(FlamColors.danger),
      counterStyle: TextStyle(color: palette.textFaint),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: palette.sheet,
      contentTextStyle: TextStyle(
        fontFamily: fontFamily,
        color: palette.text,
        fontSize: 15,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FlamRadius.md),
        side: BorderSide(color: palette.glassBorder),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.sheet,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FlamRadius.xl),
        side: BorderSide(color: palette.glassBorder),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: palette.sheet,
      surfaceTintColor: Colors.transparent,
      dragHandleColor: palette.textFaint,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(FlamRadius.xl),
        ),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: palette.sheet,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FlamRadius.md),
        side: BorderSide(color: palette.glassBorder),
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: palette.sheet,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FlamRadius.xl),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: FlamColors.pink,
      inactiveTrackColor: palette.glassBorder,
      thumbColor: FlamColors.pink,
      overlayColor: FlamColors.pink.withValues(alpha: 0.15),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? FlamColors.pink
            : palette.glassBorder,
      ),
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: FlamColors.pink),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: FlamColors.pink,
      selectionColor: Color(0x66FF5C93),
      selectionHandleColor: FlamColors.pink,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: palette.blush),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _CrossFadeTransitions(),
        TargetPlatform.iOS: _CrossFadeTransitions(),
        TargetPlatform.windows: _CrossFadeTransitions(),
        TargetPlatform.macOS: _CrossFadeTransitions(),
        TargetPlatform.linux: _CrossFadeTransitions(),
      },
    ),
  );
}

/// Con páginas transparentes, deslizar mostraría ambas a la vez; un fundido
/// cruzado se ve limpio y es barato.
class _CrossFadeTransitions extends PageTransitionsBuilder {
  const _CrossFadeTransitions();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: FlamMotion.curve),
      child: FadeTransition(
        opacity: ReverseAnimation(secondaryAnimation),
        child: child,
      ),
    );
  }
}
