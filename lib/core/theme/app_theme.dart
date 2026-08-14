import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _blue = Color(0xFF1565D8);
  static const _coral = Color(0xFFE85D4A);
  static const _sunshine = Color(0xFFF4B400);

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
      secondary: isDark ? const Color(0xFFFFB4A8) : _coral,
      onSecondary: isDark ? const Color(0xFF5F160D) : Colors.white,
      tertiary: isDark ? const Color(0xFFFFD66B) : _sunshine,
      onTertiary: const Color(0xFF332500),
    );
    final learningColors = isDark
        ? const LearningColors(
            sunshineContainer: Color(0xFF4A3900),
            onSunshineContainer: Color(0xFFFFE29A),
            coralContainer: Color(0xFF5A2018),
            onCoralContainer: Color(0xFFFFDAD4),
            blueContainer: Color(0xFF123B6E),
            onBlueContainer: Color(0xFFD6E4FF),
          )
        : const LearningColors(
            sunshineContainer: Color(0xFFFFF0B8),
            onSunshineContainer: Color(0xFF3F2E00),
            coralContainer: Color(0xFFFFDAD3),
            onCoralContainer: Color(0xFF5C160D),
            blueContainer: Color(0xFFD8E7FF),
            onBlueContainer: Color(0xFF073568),
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      extensions: [learningColors],
      scaffoldBackgroundColor: colorScheme.surface,
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
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: learningColors.blueContainer,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
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
