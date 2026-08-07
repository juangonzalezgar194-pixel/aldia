import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Paleta principal AlDía
  static const Color azulPrincipal = Color(0xFF1A3A5C);   // Azul oscuro confianza
  static const Color azulMedio = Color(0xFF2563A8);        // Azul medio
  static const Color azulClaro = Color(0xFFDCEAF8);        // Azul claro (fondos)
  static const Color esmeralda = Color(0xFF0D9E6E);        // Verde esmeralda acción
  static const Color esmeraldaOscuro = Color(0xFF0A7A55);  // Hover / pressed
  static const Color naranja = Color(0xFFF97316);          // Acento naranja (sol del logo)
  static const Color naranjaClaro = Color(0xFFFFF0E6);     // Fondo naranja suave
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color grisClaro = Color(0xFFF4F7FC);
  static const Color grisMedio = Color(0xFF8FA3BF);
  static const Color grisTexto = Color(0xFF4A5568);
  static const Color error = Color(0xFFE53E3E);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.nunito().fontFamily,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.azulPrincipal,
        onPrimary: AppColors.blanco,
        secondary: AppColors.esmeralda,
        onSecondary: AppColors.blanco,
        error: AppColors.error,
        onError: AppColors.blanco,
        surface: AppColors.blanco,
        onSurface: AppColors.azulPrincipal,
      ),
      scaffoldBackgroundColor: AppColors.grisClaro,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.blanco,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.azulClaro, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.azulClaro, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.azulMedio, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: TextStyle(
          color: AppColors.grisMedio,
          fontSize: 14,
          fontFamily: GoogleFonts.nunito().fontFamily,
        ),
        hintStyle: TextStyle(
          color: AppColors.grisMedio,
          fontSize: 14,
         fontFamily: GoogleFonts.nunito().fontFamily,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.esmeralda,
          foregroundColor: AppColors.blanco,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: GoogleFonts.nunito().fontFamily,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}