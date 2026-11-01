import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _blue = Color(0xFF245B8A);
  static const _coral = Color(0xFF607D8B);
  static const _sunshine = Color(0xFF9B742D);

  static const _youngBlue = Color(0xFF0E7490);
  static const _youngCoral = Color(0xFFE05A47);
  static const _youngSunshine = Color(0xFFD97706);

  static ThemeData get light => _theme(Brightness.light);
  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData lightFor({bool youngLearner = false}) =>
      _theme(Brightness.light, youngLearner: youngLearner);

  static ThemeData darkFor({bool youngLearner = false}) =>
      _theme(Brightness.dark, youngLearner: youngLearner);

  static ThemeData _theme(Brightness brightness, {bool youngLearner = false}) {
    final isDark = brightness == Brightness.dark;
    final seed = youngLearner ? _youngBlue : _blue;
    final generatedScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    final colorScheme = youngLearner
        ? generatedScheme.copyWith(
            primary: isDark ? const Color(0xFF67E8F9) : _youngBlue,
            onPrimary: isDark ? const Color(0xFF003642) : Colors.white,
            secondary: isDark ? const Color(0xFFFDA4AF) : _youngCoral,
            onSecondary: isDark ? const Color(0xFF4C1109) : Colors.white,
            tertiary: isDark ? const Color(0xFFFCD34D) : _youngSunshine,
            onTertiary: const Color(0xFF3B2100),
          )
        : generatedScheme.copyWith(
            primary: isDark ? const Color(0xFF9FC4FF) : _blue,
            onPrimary: isDark ? const Color(0xFF003063) : Colors.white,
            secondary: isDark ? const Color(0xFFB5C9D5) : _coral,
            onSecondary: isDark ? const Color(0xFF203541) : Colors.white,
            tertiary: isDark ? const Color(0xFFE5C589) : _sunshine,
            onTertiary: const Color(0xFF332500),
          );
    final learningColors = youngLearner
        ? (isDark
              ? const LearningColors(
                  sunshineContainer: Color(0xFF4F3800),
                  onSunshineContainer: Color(0xFFFFE599),
                  coralContainer: Color(0xFF4C221A),
                  onCoralContainer: Color(0xFFFFDAD4),
                  blueContainer: Color(0xFF0B4657),
                  onBlueContainer: Color(0xFFCFFAFE),
                )
              : const LearningColors(
                  sunshineContainer: Color(0xFFFEF3C7),
                  onSunshineContainer: Color(0xFF523200),
                  coralContainer: Color(0xFFFFE4E0),
                  onCoralContainer: Color(0xFF5C1D14),
                  blueContainer: Color(0xFFE0F7FA),
                  onBlueContainer: Color(0xFF0A4352),
                ))
        : (isDark
              ? const LearningColors(
                  sunshineContainer: Color(0xFF4A3900),
                  onSunshineContainer: Color(0xFFFFE29A),
                  coralContainer: Color(0xFF253B48),
                  onCoralContainer: Color(0xFFD6E5ED),
                  blueContainer: Color(0xFF123B6E),
                  onBlueContainer: Color(0xFFD6E4FF),
                )
              : const LearningColors(
                  sunshineContainer: Color(0xFFF5EDDC),
                  onSunshineContainer: Color(0xFF3F2E00),
                  coralContainer: Color(0xFFEAF0F4),
                  onCoralContainer: Color(0xFF304A5C),
                  blueContainer: Color(0xFFE3EEF7),
                  onBlueContainer: Color(0xFF173C5B),
                ));

    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
    );
    const arabicFontFallbacks = <String>[
      'SF Arabic',
      'Geeza Pro',
      'Damascus',
      'Noto Naskh Arabic',
      'Noto Sans Arabic',
      'Roboto',
    ];
    final sizeBoost = youngLearner ? 1.0 : 0.0;
    final textTheme = baseTheme.textTheme
        .apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
          fontFamilyFallback: arabicFontFallbacks,
        )
        .copyWith(
          displayLarge: TextStyle(
            fontSize: 59 + sizeBoost,
            height: 1.25,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            fontFamilyFallback: arabicFontFallbacks,
          ),
          displayMedium: TextStyle(
            fontSize: 47 + sizeBoost,
            height: 1.25,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            fontFamilyFallback: arabicFontFallbacks,
          ),
          displaySmall: TextStyle(
            fontSize: 38 + sizeBoost,
            height: 1.3,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            fontFamilyFallback: arabicFontFallbacks,
          ),
          headlineLarge: TextStyle(
            fontSize: 34 + sizeBoost,
            height: 1.4,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            fontFamilyFallback: arabicFontFallbacks,
          ),
          headlineMedium: TextStyle(
            fontSize: 30 + sizeBoost,
            height: 1.5,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            fontFamilyFallback: arabicFontFallbacks,
          ),
          headlineSmall: TextStyle(
            fontSize: 26 + sizeBoost,
            height: 1.45,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            fontFamilyFallback: arabicFontFallbacks,
          ),
          titleLarge: TextStyle(
            fontSize: 23 + sizeBoost,
            height: 1.45,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            fontFamilyFallback: arabicFontFallbacks,
          ),
          titleMedium: TextStyle(
            fontSize: 19 + sizeBoost,
            height: 1.45,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            fontFamilyFallback: arabicFontFallbacks,
          ),
          titleSmall: TextStyle(
            fontSize: 16 + sizeBoost,
            height: 1.45,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            fontFamilyFallback: arabicFontFallbacks,
          ),
          bodyLarge: TextStyle(
            fontSize: 19 + sizeBoost,
            height: 1.7,
            color: colorScheme.onSurface,
            fontFamilyFallback: arabicFontFallbacks,
          ),
          bodyMedium: TextStyle(
            fontSize: 17 + sizeBoost,
            height: 1.7,
            color: colorScheme.onSurface,
            fontFamilyFallback: arabicFontFallbacks,
          ),
          bodySmall: TextStyle(
            fontSize: 14 + sizeBoost,
            height: 1.6,
            color: colorScheme.onSurface,
            fontFamilyFallback: arabicFontFallbacks,
          ),
          labelLarge: TextStyle(
            fontSize: 16 + sizeBoost,
            height: 1.4,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            fontFamilyFallback: arabicFontFallbacks,
          ),
          labelMedium: TextStyle(
            fontSize: 14 + sizeBoost,
            height: 1.4,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
            fontFamilyFallback: arabicFontFallbacks,
          ),
          labelSmall: TextStyle(
            fontSize: 13 + sizeBoost,
            height: 1.4,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
            fontFamilyFallback: arabicFontFallbacks,
          ),
        );

    final cardRadius = youngLearner ? 24.0 : 20.0;
    final buttonRadius = youngLearner ? 18.0 : 14.0;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      extensions: [learningColors],
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'AmiriQuran',
          fontSize: 30,
          height: 1.25,
          fontWeight: FontWeight.w700,
          color: colorScheme.primary,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: youngLearner ? 1.5 : 1.0,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: learningColors.blueContainer,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: Size(48, youngLearner ? 58 : 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
      ),
    );
  }
}

@immutable
class LearningColors extends ThemeExtension<LearningColors> {
  const LearningColors({
    required this.sunshineContainer,
    required this.onSunshineContainer,
    required this.coralContainer,
    required this.onCoralContainer,
    required this.blueContainer,
    required this.onBlueContainer,
  });

  final Color sunshineContainer;
  final Color onSunshineContainer;
  final Color coralContainer;
  final Color onCoralContainer;
  final Color blueContainer;
  final Color onBlueContainer;

  @override
  LearningColors copyWith({
    Color? sunshineContainer,
    Color? onSunshineContainer,
    Color? coralContainer,
    Color? onCoralContainer,
    Color? blueContainer,
    Color? onBlueContainer,
  }) {
    return LearningColors(
      sunshineContainer: sunshineContainer ?? this.sunshineContainer,
      onSunshineContainer: onSunshineContainer ?? this.onSunshineContainer,
      coralContainer: coralContainer ?? this.coralContainer,
      onCoralContainer: onCoralContainer ?? this.onCoralContainer,
      blueContainer: blueContainer ?? this.blueContainer,
      onBlueContainer: onBlueContainer ?? this.onBlueContainer,
    );
  }

  @override
  LearningColors lerp(covariant LearningColors? other, double t) {
    if (other == null) {
      return this;
    }
    return LearningColors(
      sunshineContainer: Color.lerp(
        sunshineContainer,
        other.sunshineContainer,
        t,
      )!,
      onSunshineContainer: Color.lerp(
        onSunshineContainer,
        other.onSunshineContainer,
        t,
      )!,
      coralContainer: Color.lerp(coralContainer, other.coralContainer, t)!,
      onCoralContainer: Color.lerp(
        onCoralContainer,
        other.onCoralContainer,
        t,
      )!,
      blueContainer: Color.lerp(blueContainer, other.blueContainer, t)!,
      onBlueContainer: Color.lerp(onBlueContainer, other.onBlueContainer, t)!,
    );
  }
}
