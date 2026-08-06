import 'package:flutter/material.dart';

abstract final class AppColors {
  static const voidBlack = Color(0xFF070808);
  static const carbon = Color(0xFF101212);
  static const graphite = Color(0xFF1A1D1D);
  static const steel = Color(0xFF8E9797);
  static const bone = Color(0xFFF1F0EB);
  static const frost = Color(0xFFC7F4F1);
  static const danger = Color(0xFFE56B6F);
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

abstract final class AppTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      surface: AppColors.carbon,
      primary: AppColors.bone,
      secondary: AppColors.frost,
      error: AppColors.danger,
      onPrimary: AppColors.voidBlack,
      onSurface: AppColors.bone,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.voidBlack,
      colorScheme: scheme,
      fontFamily: 'Arial',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 44,
          fontWeight: FontWeight.w900,
          height: .92,
          letterSpacing: -2.2,
        ),
        displayMedium: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          height: .96,
          letterSpacing: -1.4,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          height: 1.05,
          letterSpacing: -.5,
        ),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: .2,
        ),
        bodyLarge: TextStyle(fontSize: 16, height: 1.45),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.4,
          color: AppColors.steel,
        ),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: .5,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: AppColors.steel,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.carbon,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
          side: BorderSide(color: AppColors.graphite),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.carbon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
          borderSide: BorderSide(color: AppColors.graphite),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
          borderSide: BorderSide(color: AppColors.graphite),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
          borderSide: BorderSide(color: AppColors.frost),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          backgroundColor: AppColors.bone,
          foregroundColor: AppColors.voidBlack,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: .3,
          ),
        ),
      ),
    );
  }
}
