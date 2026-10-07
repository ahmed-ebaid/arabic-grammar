import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _blue = Color(0xFF245B8A);
  static const _coral = Color(0xFF607D8B);
  static const _sunshine = Color(0xFF9B742D);

  static ThemeData get light => _theme(Brightness.light);
  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final generatedScheme = ColorScheme.fromSeed(
      seedColor: _blue,
      brightness: brightness,
    );
    final colorScheme = generatedScheme.copyWith(
      primary: isDark ? const Color(0xFF9FC4FF) : _blue,
      onPrimary: isDark ? const Color(0xFF003063) : Colors.white,
      secondary: isDark ? const Color(0xFFB5C9D5) : _coral,
      onSecondary: isDark ? const Color(0xFF203541) : Colors.white,
      tertiary: isDark ? const Color(0xFFE5C589) : _sunshine,
      onTertiary: const Color(0xFF332500),
    );
    final learningColors = isDark
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
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      extensions: [learningColors],
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme:
          ThemeData(
            useMaterial3: true,
            brightness: brightness,
            colorScheme: colorScheme,
          ).textTheme.copyWith(
            headlineMedium: TextStyle(
              fontSize: 28,
              height: 1.5,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
            bodyLarge: TextStyle(
              fontSize: 17,
              height: 1.7,
              color: colorScheme.onSurface,
            ),
            bodyMedium: TextStyle(
              fontSize: 15,
              height: 1.7,
              color: colorScheme.onSurface,
            ),
          ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: learningColors.blueContainer,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
