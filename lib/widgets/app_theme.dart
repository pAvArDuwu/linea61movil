import 'package:flutter/material.dart';

/// Tema de la aplicación que replica exactamente los colores y estilos
/// del proyecto web icontrol-seguimiento-lineas-main.
class AppTheme {
  // Colores principales del diseño web
  static const Color primary = Color(0xFF0B3C78);
  static const Color primaryDark = Color(0xFF072B52);
  static const Color accent = Color(0xFF7B1E2B);
  static const Color surface = Color(0xFFF4F6F9);
  static const Color textColor = Color(0xFF1F2937);
  static const Color muted = Color(0xFF6B7280);

  // Colores de estado
  static const Color activeGreen = Color(0xFF1E7E34);
  static const Color activeBg = Color(0xFFE6F4EA);
  static const Color inactiveGray = Color(0xFF6C757D);
  static const Color inactiveBg = Color(0xFFF0F0F0);

  // Colores para badges y cards
  static const Color cardBorder = Color(0xFFEEF2F7);
  static const Color tableBg = Color(0xFFF8F9FC);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: primary,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          color: primary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F9FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          color: textColor,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          color: muted.withValues(alpha: 0.6),
          fontSize: 14,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      dividerTheme: const DividerThemeData(
        color: cardBorder,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, color: textColor),
        headlineMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, color: textColor),
        headlineSmall: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: textColor),
        titleLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: textColor),
        titleMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: textColor),
        titleSmall: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, color: textColor),
        bodyLarge: TextStyle(fontFamily: 'Inter', color: textColor),
        bodyMedium: TextStyle(fontFamily: 'Inter', color: textColor),
        bodySmall: TextStyle(fontFamily: 'Inter', color: muted),
        labelLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
        labelMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontFamily: 'Inter', color: muted, fontSize: 11),
      ),
    );
  }

  // Decoración para cards estilo web (card-soft)
  static BoxDecoration get cardSoftDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: cardBorder),
    boxShadow: [
      BoxShadow(
        color: primary.withValues(alpha: 0.06),
        blurRadius: 30,
        offset: const Offset(0, 10),
      ),
    ],
  );

  // Gradiente para botones principales
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  // Gradiente para el sidebar
  static const LinearGradient sidebarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryDark, primary],
  );

  // Gradiente para avatar
  static const LinearGradient avatarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );
}
