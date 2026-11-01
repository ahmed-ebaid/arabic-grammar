import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/arabic_diacritics.dart';
import '../../core/localization/hijri_format.dart';
import '../../core/localization/number_format.dart';
import '../../core/models/content_models.dart';
import '../../core/progress/lesson_progress_controller.dart';
import '../../core/services/hijri_calendar_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/user/user_data_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/arabic_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.onStartLearning,
    required this.progressController,
    this.onContinueLesson,
    this.contentCatalog,
    super.key,
  });

  final VoidCallback onStartLearning;
  final ValueChanged<Lesson>? onContinueLesson;
  final ContentCatalog? contentCatalog;
  final LessonProgressController progressController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final learningColors = Theme.of(context).extension<LearningColors>()!;
    final userData = context.watch<UserDataController?>();
    final isYoungLearner =
        userData?.learnerProfile == LearnerProfile.youngLearner;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: learningColors.blueContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      isYoungLearner
                          ? Icons.auto_awesome_rounded
                          : Icons.auto_stories_outlined,
                      size: 32,
                      color: learningColors.onBlueContainer,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.appName,
                          key: const Key('home_brand_title'),
                          style: TextStyle(
                            fontFamily: 'AmiriQuran',
                            fontSize: 32,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                            color: learningColors.onBlueContainer,
                          ),
                        ),
                        const _HijriDateLabel(),
                        if (isYoungLearner)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              l10n.youngLearnerBanner,
                              style: textTheme.labelMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
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
                    onContinueLesson: onContinueLesson,
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

class _HijriDateLabel extends StatefulWidget {
  const _HijriDateLabel();

  @override
  State<_HijriDateLabel> createState() => _HijriDateLabelState();
}

/// Uses the device's local date, so the Hijri day follows the user's time
/// zone and rolls over at local midnight or when the app resumes.
class _HijriDateLabelState extends State<_HijriDateLabel>
    with WidgetsBindingObserver {
  Timer? _midnightTimer;
  HijriDate? _date;
  int _refreshId = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshDate();
    _scheduleMidnightRefresh();
  }

  Future<void> _refreshDate() async {
    final id = ++_refreshId;
    final date = await const HijriCalendarService().dateFor(DateTime.now());
    if (!mounted || id != _refreshId) return;
    setState(() => _date = date);
  }

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(nextMidnight.difference(now), () {
      if (!mounted) return;
      _refreshDate();
      _scheduleMidnightRefresh();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _refreshDate();
      _scheduleMidnightRefresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnightTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hijri = _date;
    if (hijri == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        formatHijriDate(context, hijri),
        key: const Key('home_hijri_date'),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
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
    this.onContinueLesson,
  });

  final ContentCatalog catalog;
  final LessonProgressController progressController;
  final VoidCallback onStartLearning;
  final ValueChanged<Lesson>? onContinueLesson;

  Lesson _targetLesson() {
    final lastId = progressController.lastActiveLessonId;
    if (lastId != null) {
      final lastLesson = catalog.lessons
          .where((candidate) => candidate.id == lastId)
          .firstOrNull;
      if (lastLesson != null &&
          !progressController.isCompleted(lastLesson.id)) {
        return lastLesson;
      }
    }
    return catalog.lessons.firstWhere(
      (candidate) => !progressController.isCompleted(candidate.id),
      orElse: () => catalog.lessons.last,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lesson = _targetLesson();
    final hasProgress =
        progressController.totalXp > 0 ||
        progressController.lastActiveLessonId != null ||
        progressController.stepFor(lesson.id) > 0;
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
              onPressed: () {
                if (hasProgress && onContinueLesson != null) {
                  onContinueLesson!(lesson);
                } else {
                  onStartLearning();
                }
              },
              icon: const Icon(Icons.play_arrow),
              label: Text(
                !hasProgress ? l10n.startLearning : l10n.pathContinueAction,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
