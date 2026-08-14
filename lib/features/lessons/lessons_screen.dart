import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(20),
            leading: const Icon(Icons.school_outlined, size: 36),
            title: Text(l10n.moduleTitle),
            subtitle: Text('${l10n.moduleSubtitle}\n${l10n.comingSoon}'),
            isThreeLine: true,
          ),
        ),
      ],
    );
  }
}
