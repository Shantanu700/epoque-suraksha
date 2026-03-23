import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppTheme aligned with the Epoque luxury dark design language.
///
/// Design language:
///   • Deep navy background      (#0D1B2A)
///   • Card surface              (#132235)
///   • Input field surface       (#0F1E2E)
///   • Warm gold accent          (#CBA96E) — primary interactive color
///   • Warm off-white text       (#F2EDE4)
///   • Muted blue-grey           (#8A9BB0)
///   • Subtle border / divider   (#1E3448)
class AppTheme {
  // ─── Core Palette ─────────────────────────────────────────────────────────

  /// Deep navy — scaffold background.
  static const Color bgDeep = Color(0xFF0D1B2A);

  /// Card surface.
  static const Color navyCard = Color(0xFF132235);

  /// Input field background.
  static const Color bgInput = Color(0xFF0F1E2E);

  /// Warm gold — primary brand / interactive / accent color.
  static const Color gold = Color(0xFFCBA96E);

  /// Lighter gold — for gradients / focus states.
  static const Color goldLight = Color(0xFFE8C98A);

  /// Primary text — warm off-white.
  static const Color snowWhite = Color(0xFFF2EDE4);

  /// Muted secondary text / icons.
  static const Color ashGrey = Color(0xFF8A9BB0);

  /// Dividers, borders, and subtle outlines.
  static const Color puzzleBorder = Color(0xFF1E3448);

  // ─── Semantic Colors ──────────────────────────────────────────────────────

  /// Error / destructive red.
  static const Color errorRed = Color(0xFFE05252);

  /// Success green.
  static const Color successGreen = Color(0xFF2ECC71);

  // ─── Shadows ──────────────────────────────────────────────────────────────

  static const Color goldShadow = Color(0x33CBA96E);
  static const Color darkShadow = Color(0x66000000);

  // ─── Theme ────────────────────────────────────────────────────────────────

  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      colorSchemeSeed: gold,
      scaffoldBackgroundColor: bgDeep,

      // ── App Bar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: snowWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.lora(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: snowWhite,
          letterSpacing: 3,
        ),
        iconTheme: const IconThemeData(color: snowWhite),
      ),

      // ── Typography ─────────────────────────────────────────────────────────
      // Display / headline: Lora (serif) — refined, editorial, matches Georgia fallback.
      // Body: DM Sans — clean, legible, slightly warm.
      fontFamily: GoogleFonts.dmSans().fontFamily,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.lora(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: snowWhite,
          letterSpacing: 0.3,
        ),
        displayMedium: GoogleFonts.lora(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: snowWhite,
        ),
        displaySmall: GoogleFonts.lora(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: snowWhite,
        ),
        headlineLarge: GoogleFonts.lora(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: snowWhite,
          letterSpacing: 0.3,
        ),
        headlineMedium: GoogleFonts.lora(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: snowWhite,
        ),
        titleLarge: GoogleFonts.lora(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: snowWhite,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: snowWhite,
          letterSpacing: 0.3,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: snowWhite,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: ashGrey,
        ),
        bodySmall: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.normal,
          color: ashGrey,
          letterSpacing: 0.3,
        ),
        labelLarge: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: ashGrey,
          letterSpacing: 2,
        ),
      ),

      // ── Cards ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: navyCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: puzzleBorder, width: 1),
        ),
      ),

      // ── Elevated Button (Gold primary) ─────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: bgDeep,
          disabledBackgroundColor: Color(0x80CBA96E),
          elevation: 0,
          shadowColor: goldShadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: GoogleFonts.lora(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),

      // ── Outlined Button ────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: gold,
          side: const BorderSide(color: gold, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: GoogleFonts.lora(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),

      // ── Text Button ────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: goldLight,
          textStyle: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Input / TextField ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgInput,
        hintStyle: GoogleFonts.lora(color: ashGrey, fontSize: 13),
        labelStyle: GoogleFonts.lora(
          color: ashGrey,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
        floatingLabelStyle: GoogleFonts.lora(
          color: gold,
          fontSize: 12,
          letterSpacing: 0.8,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: puzzleBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: errorRed, width: 1.5),
        ),
        prefixIconColor: ashGrey,
        suffixIconColor: ashGrey,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),

      // ── Navigation Bar ─────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navyCard,
        indicatorColor: gold.withOpacity(0.13),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: gold, size: 20);
          }
          return const IconThemeData(color: ashGrey, size: 20);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.lora(
              color: gold,
              fontWeight: FontWeight.w600,
              fontSize: 10,
              letterSpacing: 0.5,
            );
          }
          return GoogleFonts.lora(color: ashGrey, fontSize: 10);
        }),
      ),

      // ── Bottom Navigation Bar ──────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: navyCard,
        selectedItemColor: gold,
        unselectedItemColor: ashGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ── Dialog ─────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: navyCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: puzzleBorder),
        ),
        titleTextStyle: GoogleFonts.lora(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: snowWhite,
        ),
        contentTextStyle: GoogleFonts.dmSans(
          fontSize: 13,
          color: ashGrey,
          height: 1.5,
        ),
      ),

      // ── Bottom Sheet ───────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: navyCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        dragHandleColor: puzzleBorder,
      ),

      // ── Chip ───────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: navyCard,
        selectedColor: gold.withOpacity(0.15),
        labelStyle: GoogleFonts.dmSans(color: snowWhite, fontSize: 12),
        side: const BorderSide(color: puzzleBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // ── Divider ────────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: puzzleBorder,
        thickness: 1,
        space: 1,
      ),

      // ── SnackBar ───────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: navyCard,
        contentTextStyle: GoogleFonts.dmSans(color: snowWhite, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: puzzleBorder),
        ),
        behavior: SnackBarBehavior.floating,
        actionTextColor: goldLight,
      ),

      // ── Switch / Checkbox / Radio ──────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? gold : ashGrey,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? gold.withOpacity(0.35)
              : puzzleBorder,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? gold : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(bgDeep),
        side: const BorderSide(color: ashGrey, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? gold : ashGrey,
        ),
      ),

      // ── Progress Indicator ─────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: gold,
        linearTrackColor: puzzleBorder,
        circularTrackColor: puzzleBorder,
      ),

      // ── Floating Action Button ─────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: gold,
        foregroundColor: bgDeep,
        elevation: 4,
      ),
    );
  }

  // ─── Reusable Decorations ──────────────────────────────────────────────────

  /// Standard navy card with subtle border.
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: navyCard,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: puzzleBorder, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.35),
        blurRadius: 20,
        offset: const Offset(0, 6),
      ),
    ],
  );

  /// Card with a gold glow — for featured / active items.
  static BoxDecoration get accentCardDecoration => BoxDecoration(
    color: navyCard,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: gold.withOpacity(0.4), width: 1),
    boxShadow: [
      BoxShadow(
        color: gold.withOpacity(0.12),
        blurRadius: 20,
        spreadRadius: 2,
        offset: const Offset(0, 4),
      ),
    ],
  );

  /// Top-left gold radial glow backdrop (used on splash & login).
  static BoxDecoration get glowBackground => BoxDecoration(
    color: bgDeep,
    gradient: RadialGradient(
      center: Alignment.topLeft,
      radius: 1.2,
      colors: [gold.withOpacity(0.07), bgDeep],
    ),
  );

  /// Vertical dark gradient for overlays on top of camera / images.
  static BoxDecoration get overlayGradient => BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.transparent, bgDeep.withOpacity(0.95)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  // ─── Legacy aliases (kept for backward compatibility) ─────────────────────

  /// @deprecated Use [bgDeep] instead.
  static const Color midnightBlack = bgDeep;

  /// @deprecated Use [ashGrey] instead.
  static const Color phoenixBlue = Color(0xFF1E5BA8);

  /// @deprecated Use [errorRed] instead.
  static const Color emberRed = errorRed;
}
