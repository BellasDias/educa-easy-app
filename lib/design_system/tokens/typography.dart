import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTypography {
  static TextStyle title({Color? color}) => GoogleFonts.nunito(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: color ?? AppColors.gray90, // Já deixa a cor padrão aqui!
  );

  static TextStyle body({Color? color}) => GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: color ?? AppColors.gray70,
  );

  static TextStyle button({Color? color}) => GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: color ?? Colors.white,
  );

  // Global font family available to ThemeData
  static String get fontFamily => GoogleFonts.nunito().fontFamily ?? 'Nunito';
}