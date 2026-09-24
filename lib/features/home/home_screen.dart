import 'package:flutter/material.dart';

import '../../core/localization/number_format.dart';
import '../../core/models/content_models.dart';
import '../../core/progress/lesson_progress_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/arabic_text.dart';
import '../../shared/widgets/learning_illustration.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.onStartLearning,
    required this.progressController,
    this.contentCatalog,
    super.key,
  });

  final VoidCallback onStartLearning;
  final ContentCatalog? contentCatalog;
  final LessonProgressController progressController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final learningColors = Theme.of(context).extension<LearningColors>()!;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          LearningIllustration(semanticLabel: l10n.learningIllustrationLabel),
          const SizedBox(height: 12),
          Text(l10n.welcomeTitle, style: textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(l10n.welcomeBody, style: textTheme.bodyLarge),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: progressController,
            builder: (context, _) => Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Chip(
                  avatar: const Icon(Icons.local_fire_department, size: 18),
                  label: Text(
                    l10n.homeStreakDays(
                      localizedNumber(context, progressController.streakCount),
                    ),
                  ),
                ),
                Chip(
                  avatar: const Icon(Icons.bolt, size: 18),
                  label: Text(
                    l10n.homeTotalXp(
                      localizedNumber(context, progressController.totalXp),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: learningColors.sunshineContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.exampleLabel,
                    style: textTheme.labelLarge?.copyWith(
                      color: learningColors.onSunshineContainer,
                      fontWeight: FontWeight.w700,
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
          if (contentCatalog != null)
            AnimatedBuilder(
              animation: progressController,
              builder: (context, _) => _PathCard(
                catalog: contentCatalog!,
                progressController: progressController,
                onStartLearning: onStartLearning,
              ),
            ),
          if (contentCatalog != null) const SizedBox(height: 16),
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

class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.catalog,
    required this.progressController,
    required this.onStartLearning,
  });

  final ContentCatalog catalog;
  final LessonProgressController progressController;
  final VoidCallback onStartLearning;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lesson = catalog.lessons.firstWhere(
      (candidate) => !progressController.isCompleted(candidate.id),
      orElse: () => catalog.lessons.last,
    );
    final mastery = progressController.masteryFor(lesson.id);
    final title = progressController.isCompleted(lesson.id)
        ? l10n.pathCompleteTitle
        : l10n.pathContinueTitle;
    final colors = Theme.of(context).extension<LearningColors>()!;

    return Card(
      color: colors.blueContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.route_outlined, color: colors.onBlueContainer),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.onBlueContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              lesson.title.forLanguage(
                Localizations.localeOf(context).languageCode,
              ),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: colors.onBlueContainer),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: mastery / 100,
              backgroundColor: colors.blueContainer,
              color: colors.onBlueContainer,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.pathMastery('$mastery'),
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: colors.onBlueContainer),
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: onStartLearning,
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.pathContinueAction),
            ),
          ],
        ),
      ),
    );
  }
}
