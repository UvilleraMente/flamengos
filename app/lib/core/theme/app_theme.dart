import 'package:flutter/material.dart';

import 'tokens.dart';

/// Tema único (oscuro con vidrio). El fondo lo pinta FlamingoBackground,
/// por eso los Scaffold son transparentes.
ThemeData buildFlamTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: FlamColors.pink,
        brightness: Brightness.dark,
      ).copyWith(
        primary: FlamColors.pink,
        secondary: FlamColors.coral,
        tertiary: FlamColors.violet,
        surface: FlamColors.plum,
        error: FlamColors.danger,
      );

  final base = ThemeData(
    brightness: Brightness.dark,
    colorScheme: scheme,
    fontFamily: 'Outfit',
  );

  final fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(FlamRadius.md),
    borderSide: const BorderSide(color: FlamColors.glassBorder),
  );

  return base.copyWith(
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: FlamColors.plum,
    textTheme: base.textTheme.apply(
      bodyColor: FlamColors.text,
      displayColor: FlamColors.text,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      foregroundColor: FlamColors.text,
      titleTextStyle: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: FlamColors.text,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: FlamColors.glassFill,
      labelStyle: const TextStyle(color: FlamColors.textMuted),
      floatingLabelStyle: const TextStyle(color: FlamColors.blush),
      hintStyle: const TextStyle(color: FlamColors.textFaint),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: fieldBorder,
      enabledBorder: fieldBorder,
      focusedBorder: fieldBorder.copyWith(
        borderSide: const BorderSide(color: FlamColors.pink, width: 1.5),
      ),
      errorBorder: fieldBorder.copyWith(
        borderSide: const BorderSide(color: FlamColors.danger),
      ),
      focusedErrorBorder: fieldBorder.copyWith(
        borderSide: const BorderSide(color: FlamColors.danger, width: 1.5),
      ),
      counterStyle: const TextStyle(color: FlamColors.textFaint),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: FlamColors.sheet,
      contentTextStyle: const TextStyle(
        fontFamily: 'Outfit',
        color: FlamColors.text,
        fontSize: 15,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FlamRadius.md),
        side: const BorderSide(color: FlamColors.glassBorder),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: FlamColors.sheet,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FlamRadius.xl),
        side: const BorderSide(color: FlamColors.glassBorder),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: FlamColors.sheet,
      surfaceTintColor: Colors.transparent,
      dragHandleColor: FlamColors.textFaint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(FlamRadius.xl),
        ),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: FlamColors.sheet,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FlamRadius.md),
        side: const BorderSide(color: FlamColors.glassBorder),
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: FlamColors.sheet,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FlamRadius.xl),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: FlamColors.pink,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: FlamColors.pink,
      selectionColor: Color(0x66FF5C93),
      selectionHandleColor: FlamColors.pink,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: FlamColors.blush),
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
