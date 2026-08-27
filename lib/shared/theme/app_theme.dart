import 'package:flutter/material.dart';

/// Jetons de couleur retenus via le quiz de style (accent terracotta,
/// ambiance ludique) — cf. Maquette/design-canvas pour les maquettes
/// correspondantes.
class AppColors {
  AppColors._();

  static const background = Color(0xFFFAFAF8);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF5F4F0);
  static const border = Color(0xFFE8E6E1);
  static const text = Color(0xFF1C1B19);
  static const textMuted = Color(0xFF8A8880);
  static const accent = Color(0xFFB5673A);

  /// Fond des puces non sélectionnées (ChoiceChip/Chip) — nettement plus
  /// sombre que [background]/[surface], pour rester visible sur la page au
  /// lieu de s'y fondre ("blanc sur blanc").
  static const chipBackground = Color(0xFFEFEAE3);

  /// Palette "arc-en-ciel" pour le point coloré (dot) devant chaque
  /// catégorie — teintes vives, choisies pour rester bien distinctes entre
  /// elles à petite taille. N'est plus utilisée en fond de puce (le fond
  /// sélectionné reste l'accent terracotta unique, cf. category_chips_bar.dart)
  /// donc pas de contrainte de contraste avec du texte blanc ici.
  static const categoriePalette = [
    Color(0xFF43A047), // vert
    Color(0xFF1E88E5), // bleu
    Color(0xFFE53935), // rouge
    Color(0xFFFB8C00), // orange
    Color(0xFF8E24AA), // violet
    Color(0xFF00897B), // sarcelle
  ];

  static Color categorieColor(int id) =>
      categoriePalette[id.abs() % categoriePalette.length];
}

/// Rayons de la charte "formes douces" (12px pour les contrôles, 16px pour
/// les cartes) issue du quiz de style.
class AppRadius {
  AppRadius._();

  static const control = 12.0;
  static const card = 16.0;
  static const fab = 18.0;
}

ThemeData buildAppTheme() {
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.accent,
        surface: AppColors.background,
        onSurface: AppColors.text,
      );

  final controlShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadius.control),
  );
  final cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadius.card),
    side: const BorderSide(color: AppColors.border),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Quicksand',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Quicksand',
        fontWeight: FontWeight.w700,
        fontSize: 22,
        color: AppColors.text,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: cardShape,
    ),
    chipTheme: ChipThemeData(
      shape: controlShape,
      side: const BorderSide(color: AppColors.border),
      backgroundColor: AppColors.chipBackground,
      labelStyle: const TextStyle(
        color: AppColors.text,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        shape: controlShape,
        minimumSize: const Size(0, 48),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: controlShape,
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.fab),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.card),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.accent.withValues(alpha: 0.12),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          color: selected ? AppColors.accent : AppColors.textMuted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppColors.accent : AppColors.textMuted,
        );
      }),
    ),
  );
}
