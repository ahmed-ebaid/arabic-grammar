import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/content_models.dart';
import '../../core/progress/lesson_progress_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../practice/practice_rewards.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({
    required this.progressController,
    this.contentCatalog,
    super.key,
  });

  final ContentCatalog? contentCatalog;
  final LessonProgressController progressController;

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late final Future<ContentCatalog> _catalog = widget.contentCatalog == null
      ? _loadCatalog()
      : Future.value(widget.contentCatalog);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ContentCatalog>(
      future: _catalog,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(AppLocalizations.of(context).contentLoadError),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return AnimatedBuilder(
          animation: widget.progressController,
          builder: (context, _) => _Dashboard(
            catalog: snapshot.data!,
            progressController: widget.progressController,
          ),
        );
      },
    );
  }

  static Future<ContentCatalog> _loadCatalog() async {
    final source = await rootBundle.loadString('content/drafts/lesson_01.json');
    return ContentCatalog.fromJson(jsonDecode(source));
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.catalog, required this.progressController});

  final ContentCatalog catalog;
  final LessonProgressController progressController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final learningColors = Theme.of(context).extension<LearningColors>()!;
    final lessonsById = {
      for (final lesson in catalog.lessons) lesson.id: lesson,
    };
    final mastered = catalog.lessons
        .where((lesson) => progressController.isMastered(lesson.id))
        .length;
    final started = catalog.lessons
        .where(
          (lesson) =>
              progressController.stepFor(lesson.id) > 0 ||
              progressController.attemptsFor(lesson.id) > 0,
        )
        .length;
    final practiceAccuracy = progressController.practiceTotalAnswered == 0
        ? 0
        : ((progressController.practiceTotalCorrect /
                      progressController.practiceTotalAnswered) *
                  100)
              .round();
    final dailyAnswered = min(progressController.practiceDailyAnswered, 10);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          color: learningColors.sunshineContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.insights,
                  size: 52,
                  color: learningColors.onSunshineContainer,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.progressTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.progressCurriculumSummary(
                    mastered,
                    catalog.lessons.length,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                LinearProgressIndicator(
                  value: mastered / catalog.lessons.length,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(999),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            _MetricCard(
              icon: Icons.play_lesson_outlined,
              value: '$started',
              label: l10n.progressLessonsStarted,
            ),
            _MetricCard(
              icon: Icons.star,
              value: '${progressController.practiceTotalStars}',
              label: l10n.progressPracticeStars,
            ),
            _MetricCard(
              icon: Icons.track_changes,
              value: '$dailyAnswered/10',
              label: l10n.progressDailyGoal,
            ),
            _MetricCard(
              icon: Icons.check_circle_outline,
              value: '$practiceAccuracy%',
              label: l10n.progressPracticeAccuracy,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          l10n.progressLevelsTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        for (final level in catalog.levels)
          _LevelProgressCard(
            level: level,
            lessons: lessonsById,
            languageCode: languageCode,
            progressController: progressController,
          ),
        const SizedBox(height: 16),
        Text(
          l10n.practiceRewardsTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        PracticeRewardsWrap(progressController: progressController),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(height: 6),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _LevelProgressCard extends StatelessWidget {
  const _LevelProgressCard({
    required this.level,
    required this.lessons,
    required this.languageCode,
    required this.progressController,
  });

  final CurriculumLevel level;
  final Map<String, Lesson> lessons;
  final String languageCode;
  final LessonProgressController progressController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mastered = level.lessonIds
        .where(progressController.isMastered)
        .length;
    final averageMastery =
        level.lessonIds
            .map(progressController.masteryFor)
            .fold<int>(0, (sum, mastery) => sum + mastery) /
        level.lessonIds.length;
    final nextLesson = level.lessonIds
        .map((id) => lessons[id]!)
        .where((lesson) => !progressController.isMastered(lesson.id))
        .firstOrNull;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text('${level.order}')),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    level.title.forLanguage(languageCode),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text('$mastered/${level.lessonIds.length}'),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: mastered / level.lessonIds.length,
              minHeight: 9,
              borderRadius: BorderRadius.circular(999),
            ),
            const SizedBox(height: 8),
            Text(l10n.progressAverageMastery(averageMastery.round())),
            if (nextLesson != null) ...[
              const SizedBox(height: 4),
              Text(
                l10n.progressNextLesson(
                  nextLesson.title.forLanguage(languageCode),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
