import 'package:arabic_grammar/core/progress/lesson_progress_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('saves, completes, and restarts lesson progress in memory', () async {
    final controller = LessonProgressController.inMemory();

    expect(controller.stepFor('lesson_01'), 0);
    expect(controller.isCompleted('lesson_01'), isFalse);

    await controller.saveStep('lesson_01', 3);
    expect(controller.stepFor('lesson_01'), 3);

    await controller.complete('lesson_01', 6);
    expect(controller.stepFor('lesson_01'), 6);
    expect(controller.isCompleted('lesson_01'), isTrue);

    await controller.restart('lesson_01');
    expect(controller.stepFor('lesson_01'), 0);
    expect(controller.isCompleted('lesson_01'), isFalse);
  });
}
