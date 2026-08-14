import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.quiz_outlined, size: 48),
            const SizedBox(height: 16),
            Text(
              l10n.practiceTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(l10n.practiceSubtitle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
