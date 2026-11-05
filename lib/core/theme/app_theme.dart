import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const ink = Color(0xFF10141C);
  static const mist = Color(0xFFF2F5F7);
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF73BFE5),
      primary: ink,
      surface: Colors.white,
    ),
    fontFamily: 'Manrope',
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: ink, fontSize: 14),
      headlineMedium: TextStyle(
        color: ink,
        fontSize: 30,
        fontWeight: FontWeight.w600,
        letterSpacing: -1.2,
      ),
    ),
    splashFactory: InkSparkle.splashFactory,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: mist,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Color(0xFFA4A7AD), fontSize: 13),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ink,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
