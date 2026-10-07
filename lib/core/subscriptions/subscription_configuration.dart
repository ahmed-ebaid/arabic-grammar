import 'package:flutter/foundation.dart';

import '../config/app_environment.dart';

class SubscriptionConfiguration {
  const SubscriptionConfiguration({
    this.testApiKey = '',
    this.iosApiKey = '',
    this.androidApiKey = '',
  });

  const SubscriptionConfiguration.fromDefines()
    : testApiKey = const String.fromEnvironment('REVENUECAT_TEST_API_KEY'),
      iosApiKey = const String.fromEnvironment('REVENUECAT_IOS_API_KEY'),
      androidApiKey = const String.fromEnvironment(
        'REVENUECAT_ANDROID_API_KEY',
      );

  final String testApiKey;
  final String iosApiKey;
  final String androidApiKey;

  String apiKeyFor({
    required TargetPlatform platform,
    required AppFlavor flavor,
    required bool isRelease,
  }) {
    if (testApiKey.isNotEmpty) {
      if (isRelease || flavor == AppFlavor.production) {
        throw StateError(
          'RevenueCat Test Store keys are not allowed in release or production builds.',
        );
      }
      if (!testApiKey.startsWith('test_')) {
        throw StateError('Expected a public RevenueCat Test Store SDK key.');
      }
    }

    if (platform != TargetPlatform.iOS && platform != TargetPlatform.android) {
      return '';
    }
    if (testApiKey.isNotEmpty) return testApiKey;

    final key = platform == TargetPlatform.iOS ? iosApiKey : androidApiKey;
    final prefix = platform == TargetPlatform.iOS ? 'appl_' : 'goog_';
    if (key.isNotEmpty && !key.startsWith(prefix)) {
      throw StateError(
        'Expected a platform-specific public RevenueCat SDK key.',
      );
    }
    if (isRelease && key.isEmpty) {
      throw StateError(
        'A RevenueCat public SDK key is required for release builds.',
      );
    }
    return key;
  }
}
