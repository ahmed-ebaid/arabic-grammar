enum AppFlavor { development, staging, production }

class AppEnvironment {
  const AppEnvironment(this.flavor);

  factory AppEnvironment.fromDefines() {
    const value = String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'development',
    );

    return AppEnvironment(switch (value) {
      'development' => AppFlavor.development,
      'staging' => AppFlavor.staging,
      'production' => AppFlavor.production,
      _ => throw ArgumentError.value(
        value,
        'APP_ENV',
        'Expected development, staging, or production',
      ),
    });
  }

  final AppFlavor flavor;

  bool get isProduction => flavor == AppFlavor.production;
}
