import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/localization/number_format.dart';
import '../../core/models/content_models.dart';
import '../../core/progress/lesson_progress_controller.dart';
import '../../core/subscriptions/subscription_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/user/user_data_controller.dart';
import '../../l10n/app_localizations.dart';
import '../subscriptions/plus_paywall_screen.dart';
import 'lesson_detail_screen.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({
    required this.progressController,
    required this.subscriptionController,
    required this.userDataController,
    this.contentCatalog,
    super.key,
  });

  final ContentCatalog? contentCatalog;
  final LessonProgressController progressController;
  final SubscriptionController subscriptionController;
  final UserDataController userDataController;

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  late final Future<ContentCatalog> _catalog = widget.contentCatalog == null
      ? _loadCatalog()
      : Future.value(widget.contentCatalog);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final learningColors = Theme.of(context).extension<LearningColors>()!;
    final languageCode = Localizations.localeOf(context).languageCode;

    return FutureBuilder<ContentCatalog>(
      future: _catalog,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.contentLoadError, textAlign: TextAlign.center),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final catalog = snapshot.data!;
        return AnimatedBuilder(
          animation: Listenable.merge([
            widget.progressController,
            widget.subscriptionController,
          ]),
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              for (final level in catalog.levels)
                ..._buildLevel(
                  context,
                  level,
                  catalog.lessons,
                  languageCode,
                  learningColors,
                ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildLevel(
    BuildContext context,
    CurriculumLevel level,
    List<Lesson> allLessons,
    String languageCode,
    LearningColors learningColors,
  ) {
    final lessonsById = {for (final lesson in allLessons) lesson.id: lesson};
    final lessons = level.lessonIds
        .map((lessonId) => lessonsById[lessonId]!)
        .toList(growable: false);
    final isPlusLevel = level.order > 1;
    final hasPlus = widget.subscriptionController.isPlusActive;
    return [
      Card(
        color: isPlusLevel
            ? learningColors.blueContainer
            : learningColors.coralContainer,
        child: ListTile(
          contentPadding: const EdgeInsets.all(20),
          leading: Icon(
            Icons.school_outlined,
            size: 36,
            color: isPlusLevel
                ? learningColors.onBlueContainer
                : learningColors.onCoralContainer,
          ),
          title: Text(
            level.title.forLanguage(languageCode),
            style: TextStyle(
              color: isPlusLevel
                  ? learningColors.onBlueContainer
                  : learningColors.onCoralContainer,
            ),
          ),
          subtitle: Text(
            '${level.description.forLanguage(languageCode)}\n'
            '${isPlusLevel && !hasPlus
                ? AppLocalizations.of(context).plusLevelNotice
                : languageCode == 'ar'
                ? 'أتقن 70% من كل درس لفتح الدرس التالي.'
                : 'Reach 70% mastery in each lesson to unlock the next.'}',
            style: TextStyle(
              color: isPlusLevel
                  ? learningColors.onBlueContainer
                  : learningColors.onCoralContainer,
            ),
          ),
        ),
      ),
      const SizedBox(height: 28),
      for (final entry in lessons.indexed) ...[
        _PathNode(
          lesson: entry.$2,
          languageCode: languageCode,
          mastery: widget.progressController.masteryFor(entry.$2.id),
          unlocked: entry.$2.prerequisites.every(
            widget.progressController.isMastered,
          ),
          premiumLocked: isPlusLevel && !hasPlus,
          onTap: () => isPlusLevel && !hasPlus
              ? _openPlusPaywall()
              : _openLesson(entry.$2),
        ),
        if (entry.$1 < lessons.length - 1)
          Center(
            child: Container(
              width: 6,
              height: 38,
              decoration: BoxDecoration(
                color: widget.progressController.isMastered(entry.$2.id)
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
      ],
      const SizedBox(height: 36),
    ];
  }

  static Future<ContentCatalog> _loadCatalog() async {
    final source = await rootBundle.loadString('content/drafts/lesson_01.json');
    return ContentCatalog.fromJson(jsonDecode(source));
  }

  Future<void> _openLesson(Lesson lesson) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LessonDetailScreen(
          lesson: lesson,
          progressController: widget.progressController,
          userDataController: widget.userDataController,
        ),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openPlusPaywall() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PlusPaywallScreen(
          subscriptionController: widget.subscriptionController,
        ),
      ),
    );
  }
}

class _PathNode extends StatelessWidget {
  const _PathNode({
    required this.lesson,
    required this.languageCode,
    required this.mastery,
    required this.unlocked,
    required this.premiumLocked,
    required this.onTap,
  });

  final Lesson lesson;
  final String languageCode;
  final int mastery;
  final bool unlocked;
  final bool premiumLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mastered = mastery >= 70;
    final canTap = premiumLocked || unlocked;
    final accessible = !premiumLocked && unlocked;
    final colors = Theme.of(context).extension<LearningColors>()!;
    final nodeColor = !unlocked
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : premiumLocked
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : mastered
        ? Colors.green
        : Theme.of(context).colorScheme.primary;
    return Semantics(
      button: canTap,
      enabled: canTap,
      label:
          '${lesson.title.forLanguage(languageCode)}, '
          '${localizedPercent(context, mastery)}',
      child: InkWell(
        onTap: canTap ? onTap : null,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: nodeColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accessible
                        ? colors.sunshineContainer
                        : Theme.of(context).colorScheme.outlineVariant,
                    width: 7,
                  ),
                  boxShadow: accessible
                      ? [
                          BoxShadow(
                            color: nodeColor.withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  !accessible
                      ? Icons.lock_rounded
                      : mastered
                      ? Icons.star_rounded
                      : Icons.play_arrow_rounded,
                  color: accessible
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 44,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                lesson.title.forLanguage(languageCode),
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 3),
              Text(
                premiumLocked
                    ? AppLocalizations.of(context).plusRequired
                    : !unlocked
                    ? (languageCode == 'ar'
                          ? 'مغلق حتى إتقان الدرس السابق'
                          : 'Locked until the previous lesson is mastered')
                    : mastery > 0
                    ? (languageCode == 'ar'
                          ? 'الإتقان: ${localizedPercent(context, mastery)}'
                          : 'Mastery: ${localizedPercent(context, mastery)}')
                    : (languageCode == 'ar'
                          ? '${localizedNumber(context, lesson.estimatedMinutes)} دقائق'
                          : '${localizedNumber(context, lesson.estimatedMinutes)} min'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
