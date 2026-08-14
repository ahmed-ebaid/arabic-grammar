import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/arabic_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.onStartLearning, super.key});

  final VoidCallback onStartLearning;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(l10n.welcomeTitle, style: textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(l10n.welcomeBody, style: textTheme.bodyLarge),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.exampleLabel,
                    style: textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ArabicText(
                    l10n.exampleSentence,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.exampleExplanation),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onStartLearning,
            icon: const Icon(Icons.arrow_forward),
            label: Text(l10n.startLearning),
          ),
        ],
      ),
    );
  }
}
