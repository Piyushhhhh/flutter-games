import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Application theme configuration
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Color Palette
  static const Color primaryColor = Color(0xFF673AB7); // Deep Purple
  static const Color primaryVariant = Color(0xFF512DA8);
  static const Color secondaryColor = Color(0xFF3F51B5); // Indigo
  static const Color secondaryVariant = Color(0xFF303F9F);

  static const Color accentColor = Color(0xFFFF4081); // Pink Accent
  static const Color errorColor = Color(0xFFE57373);
  static const Color successColor = Color(0xFF81C784);
  static const Color warningColor = Color(0xFFFFB74D);
  static const Color infoColor = Color(0xFF64B5F6);

  // Game Colors
  static const Color playerXColor = Color(0xFF2196F3); // Blue
  static const Color playerOColor = Color(0xFFE53935); // Red
  static const Color gameGridColor = Color(0xFFE0E0E0);
  static const Color gameGridDisabledColor = Color(0xFFBDBDBD);

  // Surface Colors
  static const Color surfaceColor = Color(0xFFFAFAFA);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Text Colors
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textDisabledColor = Color(0xFFBDBDBD);
  static const Color textOnPrimaryColor = Color(0xFFFFFFFF);
  static const Color textOnSecondaryColor = Color(0xFFFFFFFF);

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: AppConstants.elevationLow,
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: textOnPrimaryColor,
        titleTextStyle: TextStyle(
          fontSize: AppConstants.fontXXL,
          fontWeight: FontWeight.w600,
          color: textOnPrimaryColor,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: AppConstants.elevationMedium,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppConstants.elevationLow,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingL,
            vertical: AppConstants.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          textStyle: const TextStyle(
            fontSize: AppConstants.fontXL,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Theme
      textTheme: _buildTextTheme(),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        contentPadding: const EdgeInsets.all(AppConstants.spacingM),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: textPrimaryColor,
        size: AppConstants.iconM,
      ),

      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(
        color: textOnPrimaryColor,
        size: AppConstants.iconM,
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: AppConstants.elevationLow,
        centerTitle: true,
        backgroundColor: Colors.grey,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: AppConstants.fontXXL,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: AppConstants.elevationMedium,
        color: Colors.grey[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppConstants.elevationLow,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingL,
            vertical: AppConstants.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          textStyle: const TextStyle(
            fontSize: AppConstants.fontXL,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Theme
      textTheme: _buildTextTheme(isDark: true),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        contentPadding: const EdgeInsets.all(AppConstants.spacingM),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: AppConstants.iconM,
      ),

      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(
        color: Colors.white,
        size: AppConstants.iconM,
      ),
    );
  }

  /// Build text theme with consistent typography
  static TextTheme _buildTextTheme({bool isDark = false}) {
    final Color textColor = isDark ? Colors.white : textPrimaryColor;
    final Color textSecondary = isDark ? Colors.white70 : textSecondaryColor;

    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontSize: AppConstants.fontDisplay,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displayMedium: TextStyle(
        fontSize: AppConstants.fontTitle,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displaySmall: TextStyle(
        fontSize: AppConstants.fontXXXL,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontSize: AppConstants.fontXXL,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontSize: AppConstants.fontXL,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontSize: AppConstants.fontL,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),

      // Title styles
      titleLarge: TextStyle(
        fontSize: AppConstants.fontXL,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontSize: AppConstants.fontL,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleSmall: TextStyle(
        fontSize: AppConstants.fontM,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),

      // Body styles
      bodyLarge: TextStyle(
        fontSize: AppConstants.fontL,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: AppConstants.fontM,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontSize: AppConstants.fontS,
        fontWeight: FontWeight.normal,
        color: textSecondary,
      ),

      // Label styles
      labelLarge: TextStyle(
        fontSize: AppConstants.fontM,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelMedium: TextStyle(
        fontSize: AppConstants.fontS,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelSmall: TextStyle(
        fontSize: AppConstants.fontS,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
    );
  }
}

/// Game-specific theme extensions
extension GameTheme on ThemeData {
  /// Player X color (Blue)
  Color get playerXColor => AppTheme.playerXColor;

  /// Player O color (Red)
  Color get playerOColor => AppTheme.playerOColor;

  /// Game grid color
  Color get gameGridColor => AppTheme.gameGridColor;

  /// Game grid disabled color
  Color get gameGridDisabledColor => AppTheme.gameGridDisabledColor;

  /// Success color
  Color get successColor => AppTheme.successColor;

  /// Error color
  Color get errorColor => AppTheme.errorColor;

  /// Warning color
  Color get warningColor => AppTheme.warningColor;

  /// Info color
  Color get infoColor => AppTheme.infoColor;
}
