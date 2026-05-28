# Vistor AI - Theme Specification

> **Aviso ao Agente (Gemini CLI)**:

> Este arquivo (`THEME.md`) é a fonte de verdade absoluta para a estilização da aplicação.

> O código abaixo deve ser copiado INTEGRALMENTE para `mobile/lib/app/theme.dart`.

> **NUNCA** derive cores, espaçamentos ou estilos por conta própria. Utilize estritamente os *tokens* definidos aqui.

## Código Fonte (`theme.dart`)

```dart
// docs/mobile/THEME.dart
// Fonte da verdade de tema do Vistor AI.
// O agente copia este arquivo INTEGRALMENTE para mobile/lib/app/theme.dart.
// Nunca derive cores ou estilos por conta própria — use apenas os tokens aqui.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Cores ────────────────────────────────────────────────────────────────────

class AppColors {
  // Primárias
  static const primary        = Color(0xFF3B55E6);
  static const primaryDeep    = Color(0xFF1A3C5E);
  static const primaryDark    = Color(0xFF4F6BFF);
  static const secondary      = Color(0xFF2E75B6);

  // Backgrounds
  static const bgLight        = Color(0xFFF0F2F8);
  static const bgDark         = Color(0xFF0D1117);

  // Surfaces
  static const surfaceLight   = Color(0xFFFFFFFF);
  static const surfaceDark    = Color(0xFF161B27);
  static const surfaceVarLight = Color(0xFFF5F7FA);
  static const surfaceVarDark  = Color(0xFF1E2435);

  // Textos
  static const onBgLight      = Color(0xFF0D1117);
  static const onBgDark       = Color(0xFFE8EAF0);
  static const onSurfLight    = Color(0xFF1A1F35);
  static const onSurfDark     = Color(0xFFCDD0DC);
  static const subtextLight   = Color(0xFF6B7280);
  static const subtextDark    = Color(0xFF8892A4);

  // Bordas
  static const outlineLight   = Color(0xFFE2E6F0);
  static const outlineDark    = Color(0xFF252D40);

  // Severidade — fundo sólido + texto branco (exceto pending)
  static const criticalBg     = Color(0xFFE53E3E);
  static const moderateBg     = Color(0xFFDD6B20);
  static const lowBg          = Color(0xFF38A169);
  static const pendingBg      = Color(0xFFF3F4F6);
  static const pendingFg      = Color(0xFF6B7280);
  static const severityText   = Color(0xFFFFFFFF);

  // Estados funcionais
  static const offline        = Color(0xFFF59E0B);
  static const offlineBg      = Color(0xFFFFFBEB);
  static const error          = Color(0xFFDC2626);
  static const success        = Color(0xFF16A34A);

  // Gradiente premium (Splash + headers)
  static const gradStart      = Color(0xFF4F46E5);
  static const gradEnd        = Color(0xFF3B82F6);

  // Componentes específicos
  static const hashFg         = Color(0xFF3B55E6);
  static const hashBg         = Color(0xFFEEF2FF);
  static const pdfIconBg      = Color(0xFFE53E3E);
  static const gold           = Color(0xFFFFD700);
  static const inputFill      = Color(0xFFF1F5F9);
  static const inputFillDark  = Color(0xFF2A2A3E);
  static const accentLight    = Color(0xFFD5E8F0);  // AiResultCard background

  // Role badges
  static const roleAdminFg    = Color(0xFF3B55E6);
  static const roleAdminBg    = Color(0xFFEEF2FF);
  static const roleInspFg     = Color(0xFF059669);
  static const roleInspBg     = Color(0xFFD1FAE5);
  static const roleBlocFg     = Color(0xFFDC2626);
  static const roleBlocBg     = Color(0xFFFEE2E2);

  // Glassmorphism
  static const glassWhite     = Color(0x1AFFFFFF);
  static const glassBorder    = Color(0x26FFFFFF);
}

// ─── Gradientes ───────────────────────────────────────────────────────────────

class AppGradients {
  static const premium = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.gradStart, AppColors.gradEnd],
  );

  static const premiumVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4338CA), Color(0xFF2563EB), Color(0xFF3B82F6)],
  );

  static const premiumVerticalDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1E1B4B), Color(0xFF1E3A5F)],
  );

  static const photoOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xE6000000)],
  );
}

// ─── Espaçamento ──────────────────────────────────────────────────────────────

class AppSpacing {
  static const xs       =  4.0;
  static const sm       =  8.0;
  static const md       = 16.0;
  static const lg       = 20.0;
  static const xl       = 24.0;
  static const xxl      = 32.0;
  static const screenH  = 20.0;
  static const screenV  = 16.0;
  static const cardPad  = 14.0;
  static const itemGap  = 10.0;
  static const sectionGap = 20.0;
}

// ─── Raios ────────────────────────────────────────────────────────────────────

class AppRadius {
  static const logo    = 20.0;
  static const card    = 16.0;
  static const cardLg  = 20.0;
  static const input   = 12.0;
  static const button  = 14.0;
  static const badge   = 100.0;
  static const sheet   = 24.0;
  static const avatar  = 100.0;
}

// ─── Sombras ──────────────────────────────────────────────────────────────────

class AppShadows {
  static const card = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 20,
    offset: Offset(0, 4),
  );
  static const cardMd = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 30,
    offset: Offset(0, 8),
  );
  static const bottomNav = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 20,
    offset: Offset(0, -4),
  );
}

// ─── Animações ────────────────────────────────────────────────────────────────

class AppAnimations {
  static const fast    = Duration(milliseconds: 200);
  static const normal  = Duration(milliseconds: 300);
  static const slow    = Duration(milliseconds: 500);
  static const stagger = Duration(milliseconds: 80);
  static const spring  = Curves.elasticOut;
  static const easeOut = Curves.easeOutCubic;
  static const decel   = Curves.decelerate;
}

// ─── TextTheme ────────────────────────────────────────────────────────────────

TextTheme _buildTextTheme(Color base) {
  return GoogleFonts.interTextTheme().copyWith(
    headlineMedium: GoogleFonts.inter(
      fontSize: 24, fontWeight: FontWeight.w800,
      letterSpacing: -0.5, color: AppColors.primaryDeep,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 22, fontWeight: FontWeight.w700, color: base,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 18, fontWeight: FontWeight.w600, color: base,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 15, fontWeight: FontWeight.w600, color: base,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16, fontWeight: FontWeight.w400, color: base,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 15, fontWeight: FontWeight.w500, color: base,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 13, fontWeight: FontWeight.w400,
      color: AppColors.subtextLight,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11, fontWeight: FontWeight.w600,
      letterSpacing: 0.3, color: base,
    ),
  );
}

// ─── InputDecorationTheme ─────────────────────────────────────────────────────

InputDecorationTheme _inputTheme(bool isDark) => InputDecorationTheme(
  filled: true,
  fillColor: isDark ? AppColors.inputFillDark : AppColors.inputFill,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.input),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.input),
    borderSide: BorderSide(
      color: isDark ? const Color(0xFF3A3A4E) : const Color(0xFFE2E8F0),
      width: 1,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.input),
    borderSide: const BorderSide(color: AppColors.secondary, width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.input),
    borderSide: const BorderSide(color: AppColors.error, width: 1),
  ),
  hintStyle: GoogleFonts.inter(
    fontSize: 14,
    color: AppColors.subtextLight,
    fontWeight: FontWeight.w400,
  ),
);

// ─── ElevatedButtonTheme ──────────────────────────────────────────────────────

ElevatedButtonThemeData _elevatedButtonTheme() => ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 52),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
    ),
    textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
    elevation: 0,
  ),
);

// ─── ThemeData Light ──────────────────────────────────────────────────────────

ThemeData lightTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme(
    brightness:            Brightness.light,
    primary:               AppColors.primary,
    onPrimary:             Colors.white,
    primaryContainer:      Color(0xFFEEF2FF),
    onPrimaryContainer:    AppColors.primary,
    secondary:             AppColors.secondary,
    onSecondary:           Colors.white,
    secondaryContainer:    Color(0xFFD5E8F0),
    onSecondaryContainer:  AppColors.secondary,
    tertiary:              AppColors.success,
    onTertiary:            Colors.white,
    error:                 AppColors.error,
    onError:               Colors.white,
    surface:               AppColors.surfaceLight,
    onSurface:             AppColors.onSurfLight,
    onSurfaceVariant:      AppColors.subtextLight,
    outline:               AppColors.outlineLight,
    outlineVariant:        Color(0xFFEEEEEE),
    shadow:                Colors.black,
    scrim:                 Colors.black,
    inverseSurface:        AppColors.surfaceDark,
    onInverseSurface:      AppColors.onSurfDark,
    inversePrimary:        AppColors.primaryDark,
  ),
  scaffoldBackgroundColor: AppColors.bgLight,
  textTheme: _buildTextTheme(AppColors.onBgLight),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    foregroundColor: Colors.white,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: AppColors.surfaceLight,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.card),
    ),
    margin: EdgeInsets.zero,
  ),
  inputDecorationTheme: _inputTheme(false),
  elevatedButtonTheme: _elevatedButtonTheme(),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.surfaceLight,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: Color(0xFF9CA3AF),
    elevation: 0,
    type: BottomNavigationBarType.fixed,
    showUnselectedLabels: true,
  ),
  dividerTheme: const DividerThemeData(
    color: AppColors.outlineLight,
    thickness: 1,
    space: 0,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFFEEF2FF),
    labelStyle: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.primary,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    shape: const StadiumBorder(),
    side: BorderSide.none,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected)
          ? Colors.white
          : const Color(0xFF9CA3AF),
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected)
          ? AppColors.primary
          : const Color(0xFFE2E8F0),
    ),
  ),
);

// ─── ThemeData Dark ───────────────────────────────────────────────────────────

ThemeData darkTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme(
    brightness:            Brightness.dark,
    primary:               AppColors.primaryDark,
    onPrimary:             Color(0xFF0D1117),
    primaryContainer:      Color(0xFF1A3C5E),
    onPrimaryContainer:    AppColors.primaryDark,
    secondary:             AppColors.secondary,
    onSecondary:           Colors.white,
    secondaryContainer:    Color(0xFF1A3C5E),
    onSecondaryContainer:  AppColors.primaryDark,
    tertiary:              Color(0xFF4ADE80),
    onTertiary:            Colors.black,
    error:                 Color(0xFFF87171),
    onError:               Colors.black,
    surface:               AppColors.surfaceDark,
    onSurface:             AppColors.onSurfDark,
    onSurfaceVariant:      AppColors.subtextDark,
    outline:               AppColors.outlineDark,
    outlineVariant:        Color(0xFF2A2A3E),
    shadow:                Colors.black,
    scrim:                 Colors.black,
    inverseSurface:        AppColors.surfaceLight,
    onInverseSurface:      AppColors.onSurfLight,
    inversePrimary:        AppColors.primary,
  ),
  scaffoldBackgroundColor: AppColors.bgDark,
  textTheme: _buildTextTheme(AppColors.onBgDark),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    foregroundColor: Colors.white,
    systemOverlayStyle: SystemUiOverlayStyle.light,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: AppColors.surfaceDark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.card),
      side: const BorderSide(color: Color(0xFF2A2A3E), width: 1),
    ),
    margin: EdgeInsets.zero,
  ),
  inputDecorationTheme: _inputTheme(true),
  elevatedButtonTheme: _elevatedButtonTheme(),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.bgDark,
    selectedItemColor: AppColors.primaryDark,
    unselectedItemColor: Color(0xFF4A5568),
    elevation: 0,
    type: BottomNavigationBarType.fixed,
    showUnselectedLabels: true,
  ),
  dividerTheme: const DividerThemeData(
    color: AppColors.outlineDark,
    thickness: 1,
    space: 0,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFF1A2035),
    labelStyle: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryDark,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    shape: const StadiumBorder(),
    side: BorderSide.none,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected)
          ? Colors.white
          : const Color(0xFF4A5568),
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected)
          ? AppColors.primaryDark
          : const Color(0xFF252D40),
    ),
  ),
);
```
