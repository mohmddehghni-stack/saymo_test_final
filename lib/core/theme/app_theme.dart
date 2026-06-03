import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme extends ThemeExtension<AppTheme> {
  final Color cardBackground;
  final Color surfaceBackground;
  final Color headerGradientStart;
  final Color headerGradientEnd;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color shadowColor;

  const AppTheme({
    required this.cardBackground,
    required this.surfaceBackground,
    required this.headerGradientStart,
    required this.headerGradientEnd,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.shadowColor,
  });

  static const light = AppTheme(
    cardBackground: Colors.white,
    surfaceBackground: Color(0xFFF5F5F5),
    headerGradientStart: AppColors.primary,
    headerGradientEnd: AppColors.primaryDark,
    textPrimary: Color(0xFF1A1A2E),
    textSecondary: Color(0xFF5D4037),
    textHint: Color(0xFF8E8E98),
    shadowColor: Color(0x0F000000),
  );

  static const dark = AppTheme(
    cardBackground: Color(0xFF16213E),
    surfaceBackground: Color(0xFF1A1A2E),
    headerGradientStart: Color(0xFF0F3460),
    headerGradientEnd: Color(0xFF1A1A2E),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFB0B0B0),
    textHint: Color(0xFF666666),
    shadowColor: Color(0x0FFFFFFF),
  );

  @override
  AppTheme copyWith({
    Color? cardBackground,
    Color? surfaceBackground,
    Color? headerGradientStart,
    Color? headerGradientEnd,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? shadowColor,
  }) {
    return AppTheme(
      cardBackground: cardBackground ?? this.cardBackground,
      surfaceBackground: surfaceBackground ?? this.surfaceBackground,
      headerGradientStart: headerGradientStart ?? this.headerGradientStart,
      headerGradientEnd: headerGradientEnd ?? this.headerGradientEnd,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }

  @override
  AppTheme lerp(AppTheme? other, double t) {
    if (other is! AppTheme) return this;
    return AppTheme(
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      surfaceBackground:
          Color.lerp(surfaceBackground, other.surfaceBackground, t)!,
      headerGradientStart:
          Color.lerp(headerGradientStart, other.headerGradientStart, t)!,
      headerGradientEnd:
          Color.lerp(headerGradientEnd, other.headerGradientEnd, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
    );
  }
}
