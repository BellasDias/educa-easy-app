import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      // 🔤 FONT GLOBAL
      fontFamily: AppTypography.fontFamily,

      // 🎨 COLOR SYSTEM
      colorScheme: const ColorScheme(
        brightness: Brightness.light,

        primary: AppColors.purplePrimary,
        onPrimary: Colors.white,

        secondary: AppColors.bluePrimary,
        onSecondary: Colors.white,

        error: AppColors.redPrimary,
        onError: Colors.white,

        surface: AppColors.gray00,
        onSurface: AppColors.gray90,
      ),

      scaffoldBackgroundColor: AppColors.gray00,

      // 🔤 TYPOGRAPHY SYSTEM
      textTheme: TextTheme(
        titleLarge: AppTypography.title(),
        bodyMedium: AppTypography.body(),
        labelLarge: AppTypography.button(),
      ),

      // 🔘 BOTÃO PADRÃO (fallback)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purplePrimary,
          foregroundColor: Colors.white,
          textStyle: AppTypography.button(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // 🧾 INPUTS (já deixa preparado)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray05,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.gray20),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.gray20),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.purplePrimary, width: 2),
        ),
      ),

      // 📱 APP BAR
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.gray00,
        foregroundColor: AppColors.gray90,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}