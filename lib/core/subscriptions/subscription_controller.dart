import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../config/app_environment.dart';
import 'subscription_configuration.dart';

const plusEntitlementId = 'plus';

enum SubscriptionPeriod { monthly, annual }

class SubscriptionPackageOption {
  const SubscriptionPackageOption({
    required this.identifier,
    required this.period,
    required this.localizedPrice,
  });

  final String identifier;
  final SubscriptionPeriod period;
  final String localizedPrice;
}

enum SubscriptionOfferingStatus {
  notLoaded,
  loading,
  available,
  unavailable,
  failed,
}

enum SubscriptionActionResult {
  success,
  noActiveSubscription,
  notConfigured,
  alreadyRunning,
  cancelled,
  failed,
}

abstract interface class SubscriptionGateway {
  Future<List<SubscriptionPackageOption>> loadPackages();
  Future<bool> purchase(String packageIdentifier);
  Future<bool> restorePlusEntitlement();
}

class SubscriptionController extends ChangeNotifier {
  SubscriptionController._(this._gateway, {this.configurationFailed = false});

  factory SubscriptionController.unconfigured() =>
      SubscriptionController._(null);

  factory SubscriptionController.withGateway(SubscriptionGateway gateway) =>
      SubscriptionController._(gateway);

  final SubscriptionGateway? _gateway;
  final bool configurationFailed;
  final List<SubscriptionPackageOption> _packages = [];
  SubscriptionOfferingStatus _offeringStatus =
      SubscriptionOfferingStatus.notLoaded;
  bool _isPurchasing = false;
  bool _isRestoring = false;
  bool _isPlusActive = false;

  bool get isConfigured => _gateway != null;
  bool get isPurchasing => _isPurchasing;
  bool get isRestoring => _isRestoring;
  bool get isBusy => _isPurchasing || _isRestoring;
  bool get isPlusActive => _isPlusActive;
  List<SubscriptionPackageOption> get packages => List.unmodifiable(_packages);
  SubscriptionOfferingStatus get offeringStatus => _offeringStatus;

  static Future<SubscriptionController> configureFromEnvironment() async {
    try {
      final apiKey = const SubscriptionConfiguration.fromDefines().apiKeyFor(
        platform: defaultTargetPlatform,
        flavor: AppEnvironment.fromDefines().flavor,
        isRelease: kReleaseMode,
      );
      if (apiKey.isEmpty) {
        return SubscriptionController.unconfigured();
      }
      await Purchases.configure(PurchasesConfiguration(apiKey));
      final controller = SubscriptionController.withGateway(
        _RevenueCatSubscriptionGateway(),
      );
      Purchases.addCustomerInfoUpdateListener(controller._updateCustomerInfo);
      try {
        controller._updateCustomerInfo(await Purchases.getCustomerInfo());
      } on PlatformException catch (error, stackTrace) {
        debugPrint('Loading subscription status failed: $error\n$stackTrace');
      }
      return controller;
    } on PlatformException catch (error, stackTrace) {
      debugPrint('RevenueCat configuration failed: $error\n$stackTrace');
      return SubscriptionController._(null, configurationFailed: true);
    } on StateError catch (error, stackTrace) {
      debugPrint('RevenueCat configuration failed: $error\n$stackTrace');
      return SubscriptionController._(null, configurationFailed: true);
    }
  }

  void _updateCustomerInfo(CustomerInfo customerInfo) {
    _isPlusActive = customerInfo.entitlements.active.containsKey(
      plusEntitlementId,
    );
    notifyListeners();
  }

  Future<void> loadOffering() async {
    final gateway = _gateway;
    if (gateway == null ||
        _offeringStatus == SubscriptionOfferingStatus.loading) {
      return;
    }
    _offeringStatus = SubscriptionOfferingStatus.loading;
    notifyListeners();
    try {
      _packages
        ..clear()
        ..addAll(await gateway.loadPackages());
      _offeringStatus = _packages.isEmpty
          ? SubscriptionOfferingStatus.unavailable
          : SubscriptionOfferingStatus.available;
    } on PlatformException catch (error, stackTrace) {
      debugPrint('Loading subscription offering failed: $error\n$stackTrace');
      _offeringStatus = SubscriptionOfferingStatus.failed;
    } finally {
      notifyListeners();
    }
  }

  Future<SubscriptionActionResult> purchase(String packageIdentifier) async {
    final gateway = _gateway;
    if (gateway == null) return SubscriptionActionResult.notConfigured;
    if (isBusy) return SubscriptionActionResult.alreadyRunning;

    _isPurchasing = true;
    notifyListeners();
    try {
      final hasPlus = await gateway.purchase(packageIdentifier);
      _isPlusActive = hasPlus;
      return hasPlus
          ? SubscriptionActionResult.success
          : SubscriptionActionResult.failed;
    } on PlatformException catch (error, stackTrace) {
      if (_isPurchaseCancelled(error)) {
        return SubscriptionActionResult.cancelled;
      }
      debugPrint('Subscription purchase failed: $error\n$stackTrace');
      return SubscriptionActionResult.failed;
    } finally {
      _isPurchasing = false;
      notifyListeners();
    }
  }

  Future<SubscriptionActionResult> restorePurchases() async {
    final gateway = _gateway;
    if (gateway == null) return SubscriptionActionResult.notConfigured;
    if (isBusy) return SubscriptionActionResult.alreadyRunning;

    _isRestoring = true;
    notifyListeners();
    try {
      final hasPlus = await gateway.restorePlusEntitlement();
      _isPlusActive = hasPlus;
      return hasPlus
          ? SubscriptionActionResult.success
          : SubscriptionActionResult.noActiveSubscription;
    } on PlatformException catch (error, stackTrace) {
      debugPrint('Restoring purchases failed: $error\n$stackTrace');
      return SubscriptionActionResult.failed;
    } finally {
      _isRestoring = false;
      notifyListeners();
    }
  }

  static bool _isPurchaseCancelled(PlatformException error) {
    try {
      return PurchasesErrorHelper.getErrorCode(error) ==
          PurchasesErrorCode.purchaseCancelledError;
    } on FormatException {
      return false;
    }
  }
}

class _RevenueCatSubscriptionGateway implements SubscriptionGateway {
  Package? _monthlyPackage;
  Package? _annualPackage;

  @override
  Future<List<SubscriptionPackageOption>> loadPackages() async {
    final offering = (await Purchases.getOfferings()).current;
    _monthlyPackage = offering?.monthly;
    _annualPackage = offering?.annual;
    return [
      if (_monthlyPackage case final package?)
        SubscriptionPackageOption(
          identifier: package.identifier,
          period: SubscriptionPeriod.monthly,
          localizedPrice: package.storeProduct.priceString,
        ),
      if (_annualPackage case final package?)
        SubscriptionPackageOption(
          identifier: package.identifier,
          period: SubscriptionPeriod.annual,
          localizedPrice: package.storeProduct.priceString,
        ),
    ];
  }

  @override
  Future<bool> purchase(String packageIdentifier) async {
    final package = switch (packageIdentifier) {
      final id when id == _monthlyPackage?.identifier => _monthlyPackage,
      final id when id == _annualPackage?.identifier => _annualPackage,
      _ => null,
    };
    if (package == null) {
      throw PlatformException(
        code: 'offerings_error',
        message: 'The selected subscription package is no longer available.',
      );
    }
    final result = await Purchases.purchase(PurchaseParams.package(package));
    return result.customerInfo.entitlements.active.containsKey(
      plusEntitlementId,
    );
  }

  @override
  Future<bool> restorePlusEntitlement() async {
    final customerInfo = await Purchases.restorePurchases();
    return customerInfo.entitlements.active.containsKey(plusEntitlementId);
  }
}
