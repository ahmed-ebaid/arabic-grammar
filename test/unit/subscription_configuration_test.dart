import 'package:arabic_grammar/core/config/app_environment.dart';
import 'package:arabic_grammar/core/subscriptions/subscription_configuration.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const testConfiguration = SubscriptionConfiguration(
    testApiKey: 'test_example',
  );

  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    test('uses Test Store key for development on $platform', () {
      expect(
        testConfiguration.apiKeyFor(
          platform: platform,
          flavor: AppFlavor.development,
          isRelease: false,
        ),
        'test_example',
      );
    });
    test('rejects Test Store key for release on $platform', () {
      expect(
        () => testConfiguration.apiKeyFor(
          platform: platform,
          flavor: AppFlavor.development,
          isRelease: true,
        ),
        throwsStateError,
      );
    });
    test('rejects Test Store key for production on $platform', () {
      expect(
        () => testConfiguration.apiKeyFor(
          platform: platform,
          flavor: AppFlavor.production,
          isRelease: false,
        ),
        throwsStateError,
      );
    });
  }

  test('selects production key for the target store', () {
    const configuration = SubscriptionConfiguration(
      iosApiKey: 'appl_example',
      androidApiKey: 'goog_example',
    );
    for (final entry in {
      TargetPlatform.iOS: 'appl_example',
      TargetPlatform.android: 'goog_example',
    }.entries) {
      expect(
        configuration.apiKeyFor(
          platform: entry.key,
          flavor: AppFlavor.production,
          isRelease: true,
        ),
        entry.value,
      );
    }
  });

  test('rejects test or secret keys in platform configuration', () {
    for (final key in ['test_example', 'sk_example', 'goog_example']) {
      expect(
        () => SubscriptionConfiguration(iosApiKey: key).apiKeyFor(
          platform: TargetPlatform.iOS,
          flavor: AppFlavor.production,
          isRelease: true,
        ),
        throwsStateError,
      );
    }
  });

  test('rejects invalid Test Store key', () {
    expect(
      () => const SubscriptionConfiguration(testApiKey: 'sk_example').apiKeyFor(
        platform: TargetPlatform.android,
        flavor: AppFlavor.development,
        isRelease: false,
      ),
      throwsStateError,
    );
  });

  test('leaves unconfigured development builds without billing', () {
    expect(
      const SubscriptionConfiguration().apiKeyFor(
        platform: TargetPlatform.android,
        flavor: AppFlavor.development,
        isRelease: false,
      ),
      isEmpty,
    );
  });

  test('requires a production store key in release builds', () {
    expect(
      () => const SubscriptionConfiguration().apiKeyFor(
        platform: TargetPlatform.android,
        flavor: AppFlavor.production,
        isRelease: true,
      ),
      throwsStateError,
    );
  });
}
