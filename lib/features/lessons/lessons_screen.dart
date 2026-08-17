import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/content_models.dart';
import '../../core/progress/lesson_progress_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'lesson_detail_screen.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({
    required this.progressController,
    this.contentCatalog,
    super.key,
  });

  final ContentCatalog? contentCatalog;
  final LessonProgressController progressController;

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
          animation: widget.progressController,
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
    return [
      Card(
        color: learningColors.coralContainer,
        child: ListTile(
          contentPadding: const EdgeInsets.all(20),
          leading: Icon(
            Icons.school_outlined,
            size: 36,
            color: learningColors.onCoralContainer,
          ),
          title: Text(level.title.forLanguage(languageCode)),
          subtitle: Text(
            '${level.description.forLanguage(languageCode)}\n'
            '${languageCode == 'ar' ? 'أتقن 70% من كل درس لفتح الدرس التالي.' : 'Reach 70% mastery in each lesson to unlock the next.'}',
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
          onTap: () => _openLesson(entry.$2),
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
        ),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }
}

class _PathNode extends StatelessWidget {
  const _PathNode({
    required this.lesson,
    required this.languageCode,
    required this.mastery,
    required this.unlocked,
    required this.onTap,
  });

  final Lesson lesson;
  final String languageCode;
  final int mastery;
  final bool unlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mastered = mastery >= 70;
    final colors = Theme.of(context).extension<LearningColors>()!;
    final nodeColor = !unlocked
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : mastered
        ? Colors.green
        : Theme.of(context).colorScheme.primary;
    return Semantics(
      button: unlocked,
      enabled: unlocked,
      label: '${lesson.title.forLanguage(languageCode)}, $mastery%',
      child: InkWell(
        onTap: unlocked ? onTap : null,
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
                    color: unlocked
                        ? colors.sunshineContainer
                        : Theme.of(context).colorScheme.outlineVariant,
                    width: 7,
                  ),
                  boxShadow: unlocked
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
                  !unlocked
                      ? Icons.lock_rounded
                      : mastered
                      ? Icons.star_rounded
                      : Icons.play_arrow_rounded,
                  color: unlocked
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
                !unlocked
                    ? (languageCode == 'ar'
                          ? 'مغلق حتى إتقان الدرس السابق'
                          : 'Locked until the previous lesson is mastered')
                    : mastery > 0
                    ? (languageCode == 'ar'
                          ? 'الإتقان: $mastery%'
                          : 'Mastery: $mastery%')
                    : (languageCode == 'ar'
                          ? '${lesson.estimatedMinutes} دقائق'
                          : '${lesson.estimatedMinutes} min'),
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
