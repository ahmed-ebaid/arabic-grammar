import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final learningColors = Theme.of(context).extension<LearningColors>()!;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          color: learningColors.coralContainer,
          child: ListTile(
            contentPadding: const EdgeInsets.all(20),
            leading: Icon(
              Icons.school_outlined,
              size: 36,
              color: learningColors.onCoralContainer,
            ),
            title: Text(l10n.moduleTitle),
            subtitle: Text('${l10n.moduleSubtitle}\n${l10n.comingSoon}'),
            isThreeLine: true,
          ),
        ),
      ],
    );
  }
}
