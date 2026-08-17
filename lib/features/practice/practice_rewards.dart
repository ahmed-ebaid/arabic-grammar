import 'package:flutter/material.dart';

import '../../core/progress/lesson_progress_controller.dart';
import '../../l10n/app_localizations.dart';

class PracticeRewardsWrap extends StatelessWidget {
  const PracticeRewardsWrap({required this.progressController, super.key});

  final LessonProgressController progressController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        RewardBadge(
          icon: Icons.play_arrow,
          label: l10n.practiceBadgeFirstSteps,
          earned: progressController.practiceTotalAnswered >= 1,
        ),
        RewardBadge(
          icon: Icons.star,
          label: l10n.practiceBadgePerfect,
          earned: progressController.practiceBestScore == 100,
        ),
        RewardBadge(
          icon: Icons.local_fire_department,
          label: l10n.practiceBadgeHabit,
          earned: progressController.practiceSessionsCompleted >= 3,
        ),
        RewardBadge(
          icon: Icons.school,
          label: l10n.practiceBadgeGrammarStar,
          earned: progressController.practiceTotalCorrect >= 50,
        ),
      ],
    );
  }
}

class RewardBadge extends StatelessWidget {
  const RewardBadge({
    required this.icon,
    required this.label,
    required this.earned,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: earned
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      side: BorderSide.none,
    );
  }
}
