import 'package:flutter/material.dart';

import '../../core/localization/arabic_diacritics.dart';
import '../../core/localization/number_format.dart';
import '../../core/models/content_models.dart';
import '../../core/progress/lesson_progress_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/arabic_text.dart';

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
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: learningColors.blueContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.auto_stories_outlined,
                    size: 32,
                    color: learningColors.onBlueContainer,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(l10n.welcomeTitle, style: textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(l10n.welcomeBody, style: textTheme.bodyLarge),
              const SizedBox(height: 24),
              if (contentCatalog != null && contentCatalog!.lessons.isNotEmpty)
                AnimatedBuilder(
                  animation: progressController,
                  builder: (context, _) => _PathCard(
                    catalog: contentCatalog!,
                    progressController: progressController,
                    onStartLearning: onStartLearning,
                  ),
                )
              else
                FilledButton.icon(
                  onPressed: onStartLearning,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(l10n.startLearning),
                ),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: progressController,
                builder: (context, _) => Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    Chip(
                      side: BorderSide.none,
                      avatar: const Icon(Icons.local_fire_department, size: 18),
                      label: Text(
                        l10n.homeStreakDays(
                          localizedNumber(
                            context,
                            progressController.streakCount,
                          ),
                        ),
                      ),
                    ),
                    Chip(
                      side: BorderSide.none,
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
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.exampleLabel,
                        style: textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
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
            ],
          ),
        ),
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
    final scheme = Theme.of(context).colorScheme;

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
            ArabicDiacriticsText(
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
              minHeight: 8,
              borderRadius: BorderRadius.circular(999),
              backgroundColor: scheme.surface,
              color: scheme.primary,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.pathMastery(localizedNumber(context, mastery)),
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: colors.onBlueContainer),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onStartLearning,
              icon: const Icon(Icons.play_arrow),
              label: Text(
                progressController.totalXp == 0
                    ? l10n.startLearning
                    : l10n.pathContinueAction,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
