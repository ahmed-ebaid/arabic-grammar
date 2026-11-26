import 'dart:io';

import 'package:arabic_grammar/core/models/content_models.dart';
import 'package:arabic_grammar/core/progress/lesson_progress_controller.dart';
import 'package:arabic_grammar/core/services/review_prompt_service.dart';
import 'package:arabic_grammar/core/storage/storage_keys.dart';
import 'package:arabic_grammar/core/theme/app_theme.dart';
import 'package:arabic_grammar/core/user/user_data_controller.dart';
import 'package:arabic_grammar/features/lessons/lesson_detail_screen.dart';
import 'package:arabic_grammar/features/practice/practice_screen.dart';
import 'package:arabic_grammar/l10n/app_localizations.dart';
import 'package:arabic_grammar/shared/widgets/course_completion_celebration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

const text = LocalizedText(en: 'Lesson', ar: 'درس');

class CountingReviewPromptService extends ReviewPromptService {
  int completions = 0;

  @override
  Future<void> recordMeaningfulLearningDay({DateTime? date}) async {
    completions++;
  }
}

Exercise exercise(String id) => Exercise(
  id: id,
  type: ExerciseType.identifyRole,
  prompt: LocalizedText(en: 'Question $id', ar: 'سؤال $id'),
  options: const [
    ExerciseOption(
      id: 'yes',
      label: LocalizedText(en: 'Right', ar: 'صحيح'),
      isCorrect: true,
      feedback: text,
    ),
    ExerciseOption(
      id: 'no',
      label: LocalizedText(en: 'Wrong', ar: 'خطأ'),
      isCorrect: false,
      feedback: text,
    ),
  ],
);

Lesson lesson({
  String id = 'lesson',
  List<String> prerequisites = const [],
  List<String> primary = const ['a', 'b'],
  List<String> repeat = const ['x', 'y'],
  bool mindMap = false,
}) => Lesson(
  id: id,
  order: 1,
  title: text,
  objectives: const [text],
  prerequisites: prerequisites,
  estimatedMinutes: 1,
  sections: const [],
  exercises: primary.map(exercise).toList(),
  repeatExercises: repeat.map(exercise).toList(),
  sources: const [],
  review: const ContentReview(
    status: ReviewStatus.approved,
    contentVersion: '1',
    reviewer: null,
    reviewedAt: null,
    notes: '',
  ),
  mindMap: mindMap ? const LessonMindMap(center: text, branches: []) : null,
);

Widget screen(
  Lesson value,
  LessonProgressController progress, {
  List<Lesson> courseLessons = const [],
}) => MaterialApp(
  locale: const Locale('en'),
  theme: AppTheme.lightFor(youngLearner: false),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: LessonDetailScreen(
    lesson: value,
    courseLessons: courseLessons,
    progressController: progress,
    userDataController: UserDataController.inMemory(),
  ),
);

void main() {
  test(
    'legacy positions migrate without losing results, completion or XP',
    () async {
      final dir = Directory('.lesson_structure_progress_test');
      await dir.create();
      Hive.init(dir.path);
      final box = await Hive.openBox<dynamic>('progress');
      addTearDown(() async {
        await box.close();
        await dir.delete(recursive: true);
      });
      await box.putAll({
        StorageKeys.lessonStep('lesson'): 3,
        StorageKeys.lessonCompleted('lesson'): true,
        StorageKeys.lessonMastery('lesson'): 80,
        StorageKeys.lessonAttempts('lesson'): 2,
        StorageKeys.lessonAnswer('lesson', 'a'): true,
        StorageKeys.lessonCompleted('old-lesson'): true,
        StorageKeys.totalXp: 10,
      });
      var progress = LessonProgressController(box);
      expect(progress.masteryFor('old-lesson'), 100);
      final migrated = await progress.prepareLesson(
        lesson(primary: ['a', 'b', 'c'], mindMap: true),
      );
      expect(migrated.step, 0);
      expect(progress.isCompleted('lesson'), isTrue);
      expect(progress.masteryFor('lesson'), 80);
      expect(progress.attemptsFor('lesson'), 2);
      expect(progress.firstAttemptResult('lesson', 'a'), isTrue);
      await progress.recordFirstAttempt('lesson', 'a', correct: true);
      expect(progress.totalXp, 10);
      await progress.complete('lesson', 6, mastery: 0);
      progress = LessonProgressController(box);
      expect(progress.masteryFor('lesson'), 0);
      expect(progress.isMastered('lesson'), isFalse);
      expect(progress.isCompleted('lesson'), isTrue);
      expect(progress.attemptsFor('lesson'), 3);
      await progress.restart('lesson');
      await progress.recordFirstAttempt('lesson', 'a', correct: true);
      expect(progress.totalXp, 20);
      progress = LessonProgressController(box);
      await progress.restart('lesson');
      await progress.recordFirstAttempt('lesson', 'a', correct: true);
      expect(progress.totalXp, 30);
    },
  );

  test(
    'resumes stable structures and banks, but rejects shifted positions',
    () async {
      final dir = Directory('.lesson_structure_resume_test');
      await dir.create();
      Hive.init(dir.path);
      final box = await Hive.openBox<dynamic>('resume');
      addTearDown(() async {
        await box.close();
        await dir.delete(recursive: true);
      });
      var progress = LessonProgressController(box);
      final original = lesson();
      await progress.prepareLesson(original);
      await progress.recordFirstAttempt('lesson', 'a', correct: true);
      await progress.saveStep('lesson', 2);
      progress = LessonProgressController(box);
      expect((await progress.prepareLesson(original)).step, 2);
      expect((await progress.prepareLesson(lesson(mindMap: true))).step, 0);
      expect(progress.firstAttemptResult('lesson', 'a'), isTrue);
      await progress.saveStep('lesson', 4);
      expect((await progress.prepareLesson(lesson(mindMap: true))).step, 3);
      await progress.complete('lesson', 4, mastery: 75);
      progress = LessonProgressController(box);
      await progress.prepareLesson(lesson(mindMap: true));
      expect(progress.isAttemptFinished('lesson'), isTrue);
      await progress.restart('lesson');
      expect(progress.isAttemptFinished('lesson'), isFalse);
      expect((await progress.prepareLesson(original)).repeat, isTrue);
      await progress.recordFirstAttempt('lesson', 'x', correct: true);
      await progress.saveStep('lesson', 2);
      progress = LessonProgressController(box);
      final resumed = await progress.prepareLesson(original);
      expect(resumed.repeat, isTrue);
      expect(resumed.step, 2);
      expect(
        (await progress.prepareLesson(lesson(repeat: ['x', 'y', 'z']))).step,
        0,
      );
      expect(progress.masteryFor('lesson'), 75);
    },
  );

  testWidgets('added questions count and retry keeps the first result', (
    tester,
  ) async {
    final progress = LessonProgressController.inMemory();
    final original = lesson(primary: ['a', 'b']);
    await progress.prepareLesson(original);
    await progress.recordFirstAttempt('lesson', 'a', correct: true);
    await progress.saveStep('lesson', 2);
    await tester.pumpWidget(screen(lesson(primary: ['a', 'b', 'c']), progress));
    await tester.pumpAndSettle();
    expect(progress.stepFor('lesson'), 0);
    Future<void> tapText(String label) async {
      final target = find.text(label).last;
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
    }

    await tester.tap(find.byKey(const ValueKey('lessonNextStep')));
    await tester.pumpAndSettle();
    expect(find.text('Question a'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('lessonNextStep')));
    await tester.pumpAndSettle();
    await tapText('Wrong');
    await tapText('Check answer');
    await tapText('Try again');
    await tapText('Right');
    await tapText('Check answer');
    await tester.tap(find.byKey(const ValueKey('lessonNextStep')));
    await tester.pumpAndSettle();
    await tapText('Right');
    await tapText('Check answer');
    await tester.tap(find.byKey(const ValueKey('lessonNextStep')));
    await tester.pumpAndSettle();
    expect(progress.firstAttemptResult('lesson', 'b'), isFalse);
    expect(progress.masteryFor('lesson'), 67);
    expect(progress.totalXp, 20);
    expect(progress.attemptsFor('lesson'), 1);
  });

  testWidgets('four-to-ten expansion keeps unlocks and scores all ten', (
    tester,
  ) async {
    final review = CountingReviewPromptService();
    final progress = LessonProgressController.inMemory(
      reviewPromptService: review,
    );
    final ids = List.generate(10, (index) => 'q$index');
    final original = lesson(primary: ids.take(4).toList());
    await progress.prepareLesson(original);
    for (var i = 0; i < 4; i++) {
      await progress.recordFirstAttempt('lesson', ids[i], correct: i < 3);
    }
    await progress.complete('lesson', 5, mastery: 75);
    final expanded = lesson(primary: ids);
    await tester.pumpWidget(screen(expanded, progress));
    await tester.pumpAndSettle();
    expect(progress.stepFor('lesson'), 0);
    expect(progress.isCompleted('lesson'), isTrue);
    expect(progress.isMastered('lesson'), isTrue);
    expect(progress.masteryFor('lesson'), 75);
    expect(progress.attemptsFor('lesson'), 1);
    expect(progress.totalXp, 30);

    Future<void> next() async {
      await tester.tap(find.byKey(const ValueKey('lessonNextStep')));
      await tester.pumpAndSettle();
    }

    Future<void> tapText(String label) async {
      final target = find.text(label).last;
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
    }

    await next();
    for (var i = 0; i < ids.length; i++) {
      expect(find.text('Question ${ids[i]}'), findsOneWidget);
      if (i >= 3) {
        await tapText('Right');
        await tapText('Check answer');
      }
      await next();
    }
    expect(progress.firstAttemptResult('lesson', ids[3]), isFalse);
    expect(progress.masteryFor('lesson'), 90);
    expect(progress.isCompleted('lesson'), isTrue);
    expect(progress.attemptsFor('lesson'), 2);
    expect(progress.totalXp, 90);
    expect(review.completions, 2);
    await tester.tap(find.byKey(const ValueKey('lessonPreviousStep')));
    await tester.pumpAndSettle();
    await next();
    expect(progress.attemptsFor('lesson'), 2);
    expect(progress.masteryFor('lesson'), 90);
    expect(progress.totalXp, 90);
    expect(review.completions, 2);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(screen(expanded, progress));
    await tester.pumpAndSettle();
    expect(progress.stepFor('lesson'), 11);
    expect(progress.attemptsFor('lesson'), 2);
    expect(progress.totalXp, 90);
    expect(review.completions, 2);
    await tester.tap(find.byKey(const ValueKey('lessonPreviousStep')));
    await tester.pumpAndSettle();
    await next();
    expect(progress.attemptsFor('lesson'), 2);
    expect(progress.totalXp, 90);
  });

  testWidgets('alternate bank scores only its own first answers', (
    tester,
  ) async {
    final progress = LessonProgressController.inMemory();
    final value = lesson();
    await progress.prepareLesson(value);
    await progress.recordFirstAttempt('lesson', 'a', correct: true);
    await progress.complete('lesson', 3, mastery: 25);
    await progress.restart('lesson');
    await tester.pumpWidget(screen(value, progress));
    await tester.pumpAndSettle();

    Future<void> tapText(String label) async {
      final target = find.text(label).last;
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
    }

    Future<void> next() async {
      await tester.tap(find.byKey(const ValueKey('lessonNextStep')));
      await tester.pumpAndSettle();
    }

    await next();
    expect(find.text('Question x'), findsOneWidget);
    await tapText('Wrong');
    await tapText('Check answer');
    await tapText('Try again');
    await tapText('Right');
    await tapText('Check answer');
    await next();
    expect(find.text('Question y'), findsOneWidget);
    await tapText('Right');
    await tapText('Check answer');
    await next();
    expect(progress.masteryFor('lesson'), 50);
    expect(progress.firstAttemptResult('lesson', 'x'), isFalse);
    expect(progress.totalXp, 20);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(screen(value, progress));
    await tester.pumpAndSettle();
    expect(progress.stepFor('lesson'), 3);
    expect(progress.attemptsFor('lesson'), 2);
  });

  testWidgets('a previously passed course does not celebrate again', (
    tester,
  ) async {
    final value = lesson(repeat: []);
    final progress = LessonProgressController.inMemory();
    await progress.complete(value.id, 3, mastery: 100);
    await progress.complete(value.id, 3, mastery: 0);
    expect(progress.isCompleted(value.id), isTrue);
    expect(progress.isMastered(value.id), isFalse);
    await progress.restart(value.id);
    await progress.prepareLesson(value);
    for (final item in value.exercises) {
      await progress.recordFirstAttempt(value.id, item.id, correct: true);
    }
    await progress.saveStep(value.id, 2);
    await tester.pumpWidget(screen(value, progress, courseLessons: [value]));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('lessonNextStep')));
    await tester.pumpAndSettle();
    expect(progress.masteryFor(value.id), 100);
    expect(progress.attemptsFor(value.id), 3);
    expect(find.byType(CourseCompletionCelebration), findsNothing);
  });

  testWidgets('completion displays a zero latest score after retry', (
    tester,
  ) async {
    final value = lesson(primary: ['a'], repeat: []);
    final progress = LessonProgressController.inMemory();
    await progress.complete(value.id, 2, mastery: 100);
    await progress.restart(value.id);
    await tester.pumpWidget(screen(value, progress));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('lessonNextStep')));
    await tester.pumpAndSettle();
    for (final label in [
      'Wrong',
      'Check answer',
      'Try again',
      'Right',
      'Check answer',
    ]) {
      final target = find.text(label).last;
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byKey(const ValueKey('lessonNextStep')));
    await tester.pumpAndSettle();
    expect(find.text('Mastery: 0%'), findsOneWidget);
    expect(progress.masteryFor(value.id), 0);
    expect(progress.isCompleted(value.id), isTrue);
    expect(progress.totalXp, 0);
  });

  testWidgets('practice includes lessons unlocked by an earlier pass', (
    tester,
  ) async {
    final first = lesson(id: 'first', primary: [], repeat: []);
    final second = lesson(
      id: 'second',
      prerequisites: ['first'],
      primary: ['second-question'],
      repeat: [],
    );
    final catalog = ContentCatalog(
      schemaVersion: 1,
      contentVersion: '1',
      levels: const [],
      lessons: [first, second],
    );
    final progress = LessonProgressController.inMemory();
    await progress.complete(first.id, 0, mastery: 80);
    await progress.complete(first.id, 0, mastery: 0);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        theme: AppTheme.lightFor(youngLearner: false),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PracticeScreen(
            progressController: progress,
            userDataController: UserDataController.inMemory(),
            contentCatalog: catalog,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mixed review'));
    await tester.pumpAndSettle();
    expect(find.text('Question second-question'), findsOneWidget);
  });

  testWidgets('weak practice uses latest rather than previous best score', (
    tester,
  ) async {
    final first = lesson(id: 'first', primary: ['weak'], repeat: []);
    final second = lesson(
      id: 'second',
      prerequisites: ['first'],
      primary: ['other'],
      repeat: [],
    );
    final catalog = ContentCatalog(
      schemaVersion: 1,
      contentVersion: '1',
      levels: const [],
      lessons: [first, second],
    );
    final progress = LessonProgressController.inMemory();
    await progress.complete(first.id, 0, mastery: 80);
    await progress.complete(first.id, 0, mastery: 20);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        theme: AppTheme.lightFor(youngLearner: false),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PracticeScreen(
            progressController: progress,
            userDataController: UserDataController.inMemory(),
            contentCatalog: catalog,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final weak = find.text('Strengthen weak areas');
    await tester.ensureVisible(weak);
    await tester.pumpAndSettle();
    await tester.tap(weak);
    await tester.pumpAndSettle();
    expect(find.text('Question weak'), findsOneWidget);
  });
}
