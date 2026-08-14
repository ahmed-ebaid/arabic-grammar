import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final learningColors = Theme.of(context).extension<LearningColors>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insights_outlined,
              size: 48,
              color: learningColors.onSunshineContainer,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.progressTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(l10n.progressSubtitle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
