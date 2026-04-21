import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for the "Modern Academy" theme inspired by the new teal/navy UI.
class AppColors {
  // Primary Palette (Deep Teal)
  static const Color primary = Color(0xFF007A82); // Darker Teal
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFFB2EBF2); 
  static const Color onPrimaryContainer = Color(0xFF004D53);

  // Dark Palette (Navy Teal for Nav bars)
  static const Color darkTeal = Color(0xFF00424D); 
  static const Color onDarkTeal = Colors.white;

  // Secondary Palette
  static const Color secondary = Color(0xFF005F68); // Darker Secondary
  static const Color onSecondary = Colors.white;
  static const Color secondaryContainer = Color(0xFFB2EBF2);
  static const Color onSecondaryContainer = Color(0xFF002023);

  // Surfaces & Backgrounds
  static const Color surface = Color(0xFFF8FBFB); // Extremely light teal-tinted white
  static const Color onSurface = Color(0xFF1A1C1E);
  static const Color onSurfaceVariant = Color(0xFF44474E);
  
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F8);
  static const Color surfaceContainer = Color(0xFFEEF0F5);
  static const Color surfaceContainerHigh = Color(0xFFE8EAEF);
  static const Color surfaceContainerHighest = Color(0xFFE1E2E8);

  // Status & UI Elements
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Colors.white;
  static const Color outline = Color(0xFF74777F);
  static const Color outlineVariant = Color(0xFFC4C6D0);
  
  // Custom Design Tokens
  static const Color ghostBorder = Color(0x1A000000);
  static const Color glassWhite = Color(0xCCFFFFFF);
}

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;

  static final BorderRadius xsRadius = BorderRadius.circular(xs);
  static final BorderRadius smRadius = BorderRadius.circular(sm);
  static final BorderRadius mdRadius = BorderRadius.circular(md);
  static final BorderRadius lgRadius = BorderRadius.circular(lg);
  static final BorderRadius xlRadius = BorderRadius.circular(xl);
  static final BorderRadius xxlRadius = BorderRadius.circular(xxl);
  static final BorderRadius xxxlRadius = BorderRadius.circular(xxxl);
  static final BorderRadius fullRadius = BorderRadius.circular(100);
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class AppGradients {
  static const LinearGradient tealHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF006D75),
      Color(0xFF008E96),
    ],
  );

  static const LinearGradient surfaceOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.white,
      Color(0xFFF8FBFB),
    ],
  );
}

class AppShadows {
  static final List<BoxShadow> soft = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> medium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.07),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static final List<BoxShadow> tight = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 5,
      offset: const Offset(0, 2),
    ),
  ];
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    scaffoldBackgroundColor: AppColors.surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xlRadius),
      color: AppColors.surfaceContainerLowest,
    ),
  );
}
