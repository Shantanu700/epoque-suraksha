import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF0C7075);
  static const Color softGreen = Color(0xFF0F969C);
  static const Color beige = Color(0xFF6DA5C0);
  static const Color offWhite = Color(0xFF05161A);
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFFB0BEC5);
  static const Color cardBackground = Color(0xFF072E33);
  static const Color shadowColor = Color(0xFF294D61);

  static ThemeData get theme {
    return ThemeData(
      colorSchemeSeed: primaryGreen,
      appBarTheme: AppBarTheme(
        backgroundColor: AppTheme.offWhite,
        foregroundColor: darkText,
      ),
      // primaryColor: primaryGreen,
      scaffoldBackgroundColor: offWhite,
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: darkText,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: darkText,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: lightText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: shadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      cardTheme: const CardThemeData(
        color: cardBackground,
        elevation: 0,
        shadowColor: shadowColor,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBackground,
        selectedItemColor: primaryGreen,
        unselectedItemColor: lightText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardBackground,
        indicatorColor: primaryGreen,

        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: cardBackground, size: 26);
          }
          return IconThemeData(color: lightText, size: 24);
        }),

        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: primaryGreen, fontWeight: FontWeight.w600);
          }
          return TextStyle(color: lightText);
        }),
      ),
    );
  }

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [
      BoxShadow(color: shadowColor, blurRadius: 10, offset: Offset(0, 4)),
    ],
  );

  static BoxDecoration get gradientBackground => const BoxDecoration(
    gradient: LinearGradient(
      colors: [softGreen, beige],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}
