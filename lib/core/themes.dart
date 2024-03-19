// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/material.dart';

class Themes {
  static ThemeData get defaultTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: gray.shade900,
        colorSchemeSeed: mainOrange,
        fontFamily: 'kZenkakuGothicNew',
        appBarTheme: AppBarTheme(
          surfaceTintColor: ThemeData.light().scaffoldBackgroundColor,
          elevation: 0,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          iconTheme: IconThemeData(color: gray[800], size: 20),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          shape: const CircleBorder(),
          foregroundColor: Themes.gray.shade900,
          backgroundColor: Themes.mainOrange,
          elevation: 10,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: mainOrange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 4,
            shadowColor: mainOrange.shade300.withOpacity(0.25),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: mainOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        popupMenuTheme: PopupMenuThemeData(
          elevation: 4,
          shadowColor: mainOrange.shade300.withOpacity(0.25),
          textStyle: TextStyle(
            color: gray.shade900,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shadowColor: mainOrange.shade300.withOpacity(0.25),
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: gray.shade50,
          filled: true,
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(
            color: gray.shade300,
            fontSize: 16,
          ),
        ),
        listTileTheme: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          iconColor: gray.shade700,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        dialogTheme: DialogTheme(
          surfaceTintColor: Colors.white,
          backgroundColor: Themes.gray.shade800,
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 8,
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith(
            (states) =>
                states.contains(MaterialState.selected) ? Colors.white : gray,
          ),
          trackOutlineColor: MaterialStateProperty.resolveWith(
            (states) =>
                states.contains(MaterialState.selected) ? mainOrange : gray,
          ),
          trackColor: MaterialStateProperty.resolveWith(
            (states) => states.contains(MaterialState.selected)
                ? mainOrange
                : Colors.white,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Themes.gray.shade900,
          selectedItemColor: mainOrange,
          unselectedItemColor: gray.shade700,
          elevation: 4,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        dividerColor: Colors.transparent,
        shadowColor: gray.shade700,
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            side: MaterialStateProperty.all<BorderSide>(BorderSide.none),
            padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            ),
            backgroundColor: MaterialStateProperty.resolveWith(
              (states) => states.contains(MaterialState.disabled)
                  ? gray.withOpacity(0.5)
                  : mainOrange,
            ),
            shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            textStyle: MaterialStateProperty.all<TextStyle>(
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            shadowColor: MaterialStateProperty.all<Color>(
              mainOrange.shade300.withOpacity(0.25),
            ),
          ),
        ),
        textTheme: TextTheme(
          headlineSmall: TextStyle(
            color: gray.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ), //ログイン・登録でのみ使用
      );

  static const MaterialColor mainOrange =
      MaterialColor(_mainOrangeValue, <int, Color>{
    50: Color(0xFFfdf3e4),
    100: Color(0xFFfce0ba),
    200: Color(0xFFfacd8f),
    300: Color(0xFFf8b966),
    400: Color(0xFFf6aa4b),
    500: Color(0xFFf49c3e),
    600: Color(_mainOrangeValue),
    700: Color(0xFFe88336),
    800: Color(0xFFe07533),
    900: Color(0xFFd3612f),
  });
  static const int _mainOrangeValue = 0xFFef913a;

  static const MaterialColor gray =
      MaterialColor(_grayPrimaryValue, <int, Color>{
    50: Color(0xFFfff4eb),
    100: Color(0xFFf8eae1),
    200: Color(0xFFebded4),
    300: Color(0xFFd8cac1),
    400: Color(0xFFd8cac1),
    500: Color(_grayPrimaryValue),
    600: Color(0xFF685d55),
    700: Color(0xFF554b43),
    800: Color(0xFF372d26),
    900: Color(0xFF180c00),
  });
  static const int _grayPrimaryValue = 0xFF90847c;
}
