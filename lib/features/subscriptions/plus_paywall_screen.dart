import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/subscriptions/subscription_controller.dart';
import '../../l10n/app_localizations.dart';

class PlusPaywallScreen extends StatefulWidget {
  const PlusPaywallScreen({required this.subscriptionController, super.key});

  final SubscriptionController subscriptionController;

  @override
  State<PlusPaywallScreen> createState() => _PlusPaywallScreenState();
}

class _PlusPaywallScreenState extends State<PlusPaywallScreen> {
  String? _selectedPackageId;

  @override
  void initState() {
    super.initState();
    widget.subscriptionController.loadOffering();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.plusTitle)),
      body: AnimatedBuilder(
        animation: widget.subscriptionController,
        builder: (context, _) {
          final subscription = widget.subscriptionController;
          final selectedPackage = subscription.packages
              .where((item) => item.identifier == _selectedPackageId)
              .firstOrNull;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Icon(
                Icons.workspace_premium_outlined,
                size: 54,
                color: colors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.plusTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(l10n.plusDescription, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              _BenefitRow(text: l10n.plusBenefitLessons),
              _BenefitRow(text: l10n.plusBenefitPractice),
              _BenefitRow(text: l10n.plusBenefitExplanations),
              const SizedBox(height: 20),
              _buildOfferingContent(context, subscription),
              if (selectedPackage != null) ...[
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: subscription.isBusy
                      ? null
                      : () => _purchase(selectedPackage),
                  child: subscription.isPurchasing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.plusPurchaseAction),
                ),
              ],
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: subscription.isBusy ? null : _restore,
                child: subscription.isRestoring
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.restorePurchases),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.plusRenewalDisclosure,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => _openLegalPage('privacy-policy.html'),
                    child: Text(l10n.plusPrivacyPolicy),
                  ),
                  TextButton(
                    onPressed: () => _openLegalPage('terms-of-use.html'),
                    child: Text(l10n.plusTermsOfUse),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOfferingContent(
    BuildContext context,
    SubscriptionController subscription,
  ) {
    final l10n = AppLocalizations.of(context);
    if (!subscription.isConfigured) {
      return Text(
        subscription.configurationFailed
            ? l10n.plusConfigurationError
            : l10n.plusNotConfigured,
        textAlign: TextAlign.center,
      );
    }
    return switch (subscription.offeringStatus) {
      SubscriptionOfferingStatus.notLoaded ||
      SubscriptionOfferingStatus.loading => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      SubscriptionOfferingStatus.unavailable => Text(
        l10n.plusOfferingUnavailable,
        textAlign: TextAlign.center,
      ),
      SubscriptionOfferingStatus.failed => Column(
        children: [
          Text(l10n.plusOfferingError, textAlign: TextAlign.center),
          TextButton(
            onPressed: subscription.loadOffering,
            child: Text(l10n.retry),
          ),
        ],
      ),
      SubscriptionOfferingStatus.available => Column(
        children: [
          for (final item in subscription.packages)
            _PackageChoice(
              package: item,
              selected: item.identifier == _selectedPackageId,
              onTap: () => setState(() => _selectedPackageId = item.identifier),
            ),
        ],
      ),
    };
  }

  Future<void> _purchase(SubscriptionPackageOption package) async {
    final result = await widget.subscriptionController.purchase(
      package.identifier,
    );
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    _showResult(switch (result) {
      SubscriptionActionResult.success => l10n.plusPurchaseSuccess,
      SubscriptionActionResult.cancelled => l10n.plusPurchaseCancelled,
      SubscriptionActionResult.noActiveSubscription =>
        l10n.restorePurchasesNoneFound,
      SubscriptionActionResult.notConfigured => l10n.plusNotConfigured,
      SubscriptionActionResult.alreadyRunning => l10n.plusPurchaseChecking,
      SubscriptionActionResult.failed => l10n.plusPurchaseError,
    });
  }

  Future<void> _restore() async {
    final result = await widget.subscriptionController.restorePurchases();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    _showResult(switch (result) {
      SubscriptionActionResult.success => l10n.restorePurchasesSuccess,
      SubscriptionActionResult.noActiveSubscription =>
        l10n.restorePurchasesNoneFound,
      SubscriptionActionResult.notConfigured => l10n.plusNotConfigured,
      SubscriptionActionResult.alreadyRunning => l10n.plusPurchaseChecking,
      SubscriptionActionResult.cancelled => l10n.restorePurchasesError,
      SubscriptionActionResult.failed => l10n.restorePurchasesError,
    });
  }

  void _showResult(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openLegalPage(String page) async {
    final uri = Uri.https('ahmed-ebaid.github.io', '/arabic-grammar/$page');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      _showResult(AppLocalizations.of(context).plusExternalLinkError);
    }
  }
}

class _PackageChoice extends StatelessWidget {
  const _PackageChoice({
    required this.package,
    required this.selected,
    required this.onTap,
  });

  final SubscriptionPackageOption package;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final label = switch (package.period) {
      SubscriptionPeriod.monthly => l10n.plusMonthly,
      SubscriptionPeriod.annual => l10n.plusAnnual,
    };
    final billingPeriod = switch (package.period) {
      SubscriptionPeriod.monthly => l10n.plusPerMonth,
      SubscriptionPeriod.annual => l10n.plusPerYear,
    };

    return Card(
      color: selected ? colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.titleMedium),
                    Text(billingPeriod),
                  ],
                ),
              ),
              Text(
                package.localizedPrice,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.check_circle_outline),
      title: Text(text),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
