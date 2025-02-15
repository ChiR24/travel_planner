import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core color schemes
  static final ColorScheme _lightColorScheme = ColorScheme.light(
    primary: const Color(0xFF1E88E5),
    secondary: const Color(0xFF26A69A),
    tertiary: const Color(0xFF7E57C2),
    error: const Color(0xFFE57373),
    background: const Color(0xFFFAFAFA),
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: Colors.white,
    onError: Colors.white,
    onBackground: Colors.black87,
    onSurface: Colors.black87,
    surfaceVariant: const Color(0xFFF5F5F5),
    outline: Colors.grey[400]!,
  );

  static final ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: const Color(0xFF90CAF9),
    secondary: const Color(0xFF80CBC4),
    tertiary: const Color(0xFFB39DDB),
    error: const Color(0xFFEF9A9A),
    background: const Color(0xFF121212),
    surface: const Color(0xFF1E1E1E),
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onTertiary: Colors.black,
    onError: Colors.black,
    onBackground: Colors.white,
    onSurface: Colors.white,
    surfaceVariant: const Color(0xFF2D2D2D),
    outline: Colors.grey[700]!,
  );

  // Custom theme properties
  static const _cardRadius = 16.0;
  static const _buttonRadius = 12.0;
  static const _inputRadius = 12.0;

  // Elevation values
  static const _cardElevation = 2.0;
  static const _buttonElevation = 0.0;
  static const _buttonPressedElevation = 4.0;

  // Animation durations
  static const _shortAnimation = Duration(milliseconds: 200);
  static const _mediumAnimation = Duration(milliseconds: 300);

  // Animation durations
  static const Duration quickAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Haptic feedback settings
  static const bool enableHapticFeedback = true;
  static const Duration hapticFeedbackInterval = Duration(milliseconds: 50);

  // Accessibility settings
  static const double minTextScaleFactor = 0.8;
  static const double maxTextScaleFactor = 1.4;
  static const double textScaleFactorStep = 0.1;

  // Spacing and layout constants
  static const double spacing_2xs = 4.0;
  static const double spacing_xs = 8.0;
  static const double spacing_sm = 12.0;
  static const double spacing_md = 16.0;
  static const double spacing_lg = 24.0;
  static const double spacing_xl = 32.0;
  static const double spacing_2xl = 48.0;

  // Border radius constants
  static const double radius_sm = 4.0;
  static const double radius_md = 8.0;
  static const double radius_lg = 12.0;
  static const double radius_xl = 16.0;
  static const double radius_2xl = 24.0;

  // Elevation constants
  static const double elevation_none = 0.0;
  static const double elevation_xs = 2.0;
  static const double elevation_sm = 4.0;
  static const double elevation_md = 8.0;
  static const double elevation_lg = 16.0;
  static const double elevation_xl = 24.0;

  // Text Styles
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: colorScheme.onBackground,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: colorScheme.onBackground,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: colorScheme.onBackground,
        height: 1.2,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: colorScheme.onBackground,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colorScheme.onBackground,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colorScheme.onBackground,
        height: 1.3,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colorScheme.onBackground,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colorScheme.onBackground,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: colorScheme.onBackground,
        height: 1.4,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: colorScheme.onBackground,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: colorScheme.onBackground.withOpacity(0.8),
        height: 1.5,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        color: colorScheme.onBackground.withOpacity(0.8),
        height: 1.5,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colorScheme.onBackground,
        letterSpacing: 0.5,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onBackground,
        letterSpacing: 0.5,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colorScheme.onBackground,
        letterSpacing: 0.5,
        height: 1.4,
      ),
    );
  }

  static ThemeData get lightTheme {
    return _buildTheme(_lightColorScheme);
  }

  static ThemeData get darkTheme {
    return _buildTheme(_darkColorScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final textTheme = _buildTextTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      textTheme: textTheme,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.headlineMedium,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        toolbarHeight: 64,
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: elevation_xs,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius_xl),
        ),
        clipBehavior: Clip.antiAlias,
        color: colorScheme.surface,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: elevation_none,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius_lg),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(88, 48),
          animationDuration: quickAnimation,
        ).copyWith(
          elevation: MaterialStateProperty.resolveWith<double>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return elevation_sm;
              }
              return elevation_none;
            },
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius_lg),
          ),
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge?.copyWith(
            color: colorScheme.primary,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? colorScheme.surfaceVariant : colorScheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius_lg),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius_lg),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius_lg),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius_lg),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius_lg),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.5),
        ),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.error,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor:
            isDark ? colorScheme.surfaceVariant : colorScheme.surface,
        disabledColor: colorScheme.onSurface.withOpacity(0.12),
        selectedColor: colorScheme.primary,
        secondarySelectedColor: colorScheme.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        labelStyle: textTheme.bodyMedium,
        secondaryLabelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSecondary,
        ),
        brightness: colorScheme.brightness,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primary.withOpacity(0.1),
        refreshBackgroundColor: colorScheme.surface,
        linearMinHeight: 4.0,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            isDark ? colorScheme.surfaceVariant : colorScheme.surface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: _cardElevation,
        actionTextColor: colorScheme.primary,
      ),

      // Page transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // Scrolling physics
      scrollbarTheme: ScrollbarThemeData(
        thickness: MaterialStateProperty.all(8.0),
        thumbColor: MaterialStateProperty.all(
          colorScheme.onSurface.withOpacity(0.4),
        ),
        radius: const Radius.circular(radius_sm),
        crossAxisMargin: 2,
      ),

      // Tooltip theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(radius_md),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: elevation_xs,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurface,
        ),
        waitDuration: const Duration(milliseconds: 500),
        showDuration: const Duration(milliseconds: 3000),
      ),

      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        modalBackgroundColor: colorScheme.surface,
        elevation: elevation_md,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radius_xl),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: colorScheme.surface,
        elevation: elevation_lg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius_lg),
        ),
      ),

      // Navigation bar theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        elevation: elevation_sm,
        height: 80,
        labelTextStyle: MaterialStateProperty.all(
          textTheme.labelMedium,
        ),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return IconThemeData(color: colorScheme.primary);
          }
          return IconThemeData(color: colorScheme.onSurface);
        }),
      ),
    );
  }
}
