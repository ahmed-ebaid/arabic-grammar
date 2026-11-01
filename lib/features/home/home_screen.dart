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
import '../../shared/widgets/young_learner_mascot.dart';

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
    final scheme = Theme.of(context).colorScheme;
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
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              const _HijriDateLabel(),
              const SizedBox(height: 10),
              Text(l10n.welcomeTitle, style: textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(
                l10n.welcomeBody,
                style: textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              if (contentCatalog != null && contentCatalog!.lessons.isNotEmpty)
                AnimatedBuilder(
                  animation: progressController,
                  builder: (context, _) => _PathCard(
                    catalog: contentCatalog!,
                    progressController: progressController,
                    onStartLearning: onStartLearning,
                    onContinueLesson: onContinueLesson,
                    isYoungLearner: isYoungLearner,
                  ),
                )
              else
                FilledButton.icon(
                  onPressed: onStartLearning,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(l10n.startLearning),
                ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: progressController,
                builder: (context, _) => Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    Chip(
                      side: BorderSide.none,
                      backgroundColor: learningColors.sunshineContainer,
                      avatar: Icon(
                        Icons.local_fire_department,
                        size: 20,
                        color: learningColors.onSunshineContainer,
                      ),
                      label: Text(
                        l10n.homeStreakDays(
                          localizedNumber(
                            context,
                            progressController.streakCount,
                          ),
                        ),
                        style: TextStyle(
                          color: learningColors.onSunshineContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Chip(
                      side: BorderSide.none,
                      backgroundColor: learningColors.blueContainer,
                      avatar: Icon(
                        Icons.bolt,
                        size: 20,
                        color: learningColors.onBlueContainer,
                      ),
                      label: Text(
                        l10n.homeTotalXp(
                          localizedNumber(context, progressController.totalXp),
                        ),
                        style: TextStyle(
                          color: learningColors.onBlueContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Card(
                color: scheme.surfaceContainerLow,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () =>
                      ArabicSpeechHelper.instance.speak(l10n.exampleSentence),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.exampleLabel,
                              style: textTheme.labelLarge?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Icon(
                              Icons.volume_up_rounded,
                              size: 20,
                              color: scheme.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ArabicText(
                          l10n.exampleSentence,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(l10n.exampleExplanation),
                      ],
                    ),
                  ),
                ),
              ),
              if (isYoungLearner) ...[
                const SizedBox(height: 10),
                const InteractiveHarakaPlayground(),
              ],
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
    this.isYoungLearner = false,
  });

  final ContentCatalog catalog;
  final LessonProgressController progressController;
  final VoidCallback onStartLearning;
  final ValueChanged<Lesson>? onContinueLesson;
  final bool isYoungLearner;

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

    final gradientColors = isYoungLearner
        ? const [Color(0xFF0E7490), Color(0xFF0A4F63)]
        : const [Color(0xFF245B8A), Color(0xFF153A5B)];
    const lightText = Color(0xFFF5FAFD);
    const mutedLightText = Color(0xFFCDE4F5);
    final buttonFg = isYoungLearner
        ? const Color(0xFF0A4F63)
        : const Color(0xFF153A5B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(isYoungLearner ? 24 : 20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.route_outlined, color: mutedLightText),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: mutedLightText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ArabicDiacriticsText(
            lesson.title.forLanguage(
              Localizations.localeOf(context).languageCode,
            ),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: lightText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: mastery / 100,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            color: const Color(0xFFFCD34D),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.pathMastery(localizedNumber(context, mastery)),
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: mutedLightText),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: lightText,
              foregroundColor: buttonFg,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              if (hasProgress && onContinueLesson != null) {
                onContinueLesson!(lesson);
              } else {
                onStartLearning();
              }
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(
              !hasProgress ? l10n.startLearning : l10n.pathContinueAction,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
