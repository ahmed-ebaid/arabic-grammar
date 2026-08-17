import 'package:arabic_grammar/core/progress/lesson_progress_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'persists mastery and clears only the active attempt on restart',
    () async {
      final controller = LessonProgressController.inMemory();

      expect(controller.stepFor('lesson_01'), 0);
      expect(controller.isCompleted('lesson_01'), isFalse);

      await controller.saveStep('lesson_01', 3);
      expect(controller.stepFor('lesson_01'), 3);

      await controller.recordFirstAttempt(
        'lesson_01',
        'exercise_01',
        correct: true,
      );
      await controller.complete('lesson_01', 6, mastery: 75);
      expect(controller.stepFor('lesson_01'), 6);
      expect(controller.isCompleted('lesson_01'), isTrue);
      expect(controller.isMastered('lesson_01'), isTrue);
      expect(controller.masteryFor('lesson_01'), 75);
      expect(controller.attemptsFor('lesson_01'), 1);

      await controller.restart('lesson_01');
      expect(controller.stepFor('lesson_01'), 0);
      expect(controller.isCompleted('lesson_01'), isTrue);
      expect(controller.firstAttemptResult('lesson_01', 'exercise_01'), isNull);
    },
  );

  test('keeps the best mastery score across attempts', () async {
    final controller = LessonProgressController.inMemory();

    await controller.complete('lesson_01', 6, mastery: 100);
    await controller.complete('lesson_01', 6, mastery: 50);

    expect(controller.masteryFor('lesson_01'), 100);
    expect(controller.attemptsFor('lesson_01'), 2);
    expect(controller.isMastered('lesson_01'), isTrue);
  });

  test('records only the first answer in an attempt', () async {
    final controller = LessonProgressController.inMemory();

    await controller.recordFirstAttempt(
      'lesson_01',
      'exercise_01',
      correct: false,
    );
    await controller.recordFirstAttempt(
      'lesson_01',
      'exercise_01',
      correct: true,
    );

    expect(controller.firstAttemptResult('lesson_01', 'exercise_01'), isFalse);
  });

  test('keeps practice rewards separate from lesson mastery', () async {
    final controller = LessonProgressController.inMemory();

    await controller.recordPracticeSession(answered: 10, correct: 8);

    expect(controller.practiceTotalAnswered, 10);
    expect(controller.practiceTotalCorrect, 8);
    expect(controller.practiceSessionsCompleted, 1);
    expect(controller.practiceBestScore, 80);
    expect(controller.practiceTotalStars, 2);
    expect(controller.practiceDailyAnswered, 10);
    expect(controller.masteryFor('lesson_01'), 0);

    await controller.recordPracticeSession(answered: 10, correct: 10);

    expect(controller.practiceBestScore, 100);
    expect(controller.practiceTotalStars, 5);
    expect(controller.practiceDailyAnswered, 20);
  });
}
