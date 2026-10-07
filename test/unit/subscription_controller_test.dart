import 'package:arabic_grammar/core/subscriptions/subscription_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/errors.dart';

void main() {
  test(
    'restore activates Plus only when the entitlement is returned',
    () async {
      final controller = SubscriptionController.withGateway(
        _FakeSubscriptionGateway(hasPlus: true),
      );

      expect(
        await controller.restorePurchases(),
        SubscriptionActionResult.success,
      );
      expect(controller.isPlusActive, isTrue);
      expect(controller.isRestoring, isFalse);
    },
  );

  test(
    'restore leaves Plus inactive when no active entitlement is found',
    () async {
      final controller = SubscriptionController.withGateway(
        _FakeSubscriptionGateway(hasPlus: false),
      );

      expect(
        await controller.restorePurchases(),
        SubscriptionActionResult.noActiveSubscription,
      );
      expect(controller.isPlusActive, isFalse);
    },
  );

  test(
    'restore reports unavailable when RevenueCat is not configured',
    () async {
      final controller = SubscriptionController.unconfigured();

      expect(
        await controller.restorePurchases(),
        SubscriptionActionResult.notConfigured,
      );
      expect(controller.isPlusActive, isFalse);
    },
  );

  test('restore reports platform errors without granting Plus', () async {
    final controller = SubscriptionController.withGateway(
      _FakeSubscriptionGateway(error: PlatformException(code: 'store_error')),
    );

    expect(
      await controller.restorePurchases(),
      SubscriptionActionResult.failed,
    );
    expect(controller.isPlusActive, isFalse);
    expect(controller.isRestoring, isFalse);
  });

  test('loads store-localized monthly and annual options', () async {
    final controller = SubscriptionController.withGateway(
      const _FakeSubscriptionGateway(
        packages: [
          SubscriptionPackageOption(
            identifier: 'monthly',
            period: SubscriptionPeriod.monthly,
            localizedPrice: r'$3.99',
          ),
          SubscriptionPackageOption(
            identifier: 'annual',
            period: SubscriptionPeriod.annual,
            localizedPrice: r'$29.99',
          ),
        ],
      ),
    );

    await controller.loadOffering();
    expect(controller.offeringStatus, SubscriptionOfferingStatus.available);
    expect(controller.packages.map((item) => item.localizedPrice), [
      r'$3.99',
      r'$29.99',
    ]);
  });

  test(
    'purchase grants Plus only after an active entitlement is returned',
    () async {
      final controller = SubscriptionController.withGateway(
        const _FakeSubscriptionGateway(purchaseHasPlus: true),
      );

      expect(
        await controller.purchase('monthly'),
        SubscriptionActionResult.success,
      );
      expect(controller.isPlusActive, isTrue);
      expect(controller.isPurchasing, isFalse);
    },
  );

  test('purchase cancellation does not grant Plus', () async {
    final controller = SubscriptionController.withGateway(
      _FakeSubscriptionGateway(
        purchaseError: PlatformException(
          code: PurchasesErrorCode.purchaseCancelledError.index.toString(),
        ),
      ),
    );

    expect(
      await controller.purchase('monthly'),
      SubscriptionActionResult.cancelled,
    );
    expect(controller.isPlusActive, isFalse);
  });
}

class _FakeSubscriptionGateway implements SubscriptionGateway {
  const _FakeSubscriptionGateway({
    this.hasPlus = false,
    this.error,
    this.packages = const [],
    this.purchaseHasPlus = false,
    this.purchaseError,
  });

  final bool hasPlus;
  final PlatformException? error;
  final List<SubscriptionPackageOption> packages;
  final bool purchaseHasPlus;
  final PlatformException? purchaseError;

  @override
  Future<List<SubscriptionPackageOption>> loadPackages() async => packages;

  @override
  Future<bool> purchase(String packageIdentifier) async {
    if (purchaseError case final error?) throw error;
    return purchaseHasPlus;
  }

  @override
  Future<bool> restorePlusEntitlement() async {
    if (error case final error?) {
      throw error;
    }
    return hasPlus;
  }
}
