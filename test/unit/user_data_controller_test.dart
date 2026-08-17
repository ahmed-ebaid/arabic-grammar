import 'package:arabic_grammar/core/user/user_data_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stores bookmarks by content type', () async {
    final controller = UserDataController.inMemory();

    await controller.toggleBookmark(BookmarkType.lesson, 'lesson_01');
    await controller.toggleBookmark(BookmarkType.example, 'example_01');

    expect(controller.isBookmarked(BookmarkType.lesson, 'lesson_01'), isTrue);
    expect(controller.bookmarkedIds(BookmarkType.lesson), {'lesson_01'});
    expect(controller.bookmarkedIds(BookmarkType.example), {'example_01'});

    await controller.toggleBookmark(BookmarkType.lesson, 'lesson_01');
    expect(controller.isBookmarked(BookmarkType.lesson, 'lesson_01'), isFalse);
  });

  test('uses 1, 3, 7, and 14 day spaced review intervals', () async {
    final controller = UserDataController.inMemory();
    final start = DateTime.utc(2026, 8, 17);

    await controller.recordReviewResult(
      'lesson_01',
      'exercise_01',
      correct: false,
      now: start,
    );
    expect(controller.reviewStage('lesson_01', 'exercise_01'), 0);
    expect(
      controller.reviewDue('lesson_01', 'exercise_01'),
      start.add(const Duration(days: 1)),
    );

    await controller.recordReviewResult(
      'lesson_01',
      'exercise_01',
      correct: true,
      now: start,
    );
    expect(controller.reviewStage('lesson_01', 'exercise_01'), 1);
    expect(
      controller.reviewDue('lesson_01', 'exercise_01'),
      start.add(const Duration(days: 3)),
    );

    await controller.recordReviewResult(
      'lesson_01',
      'exercise_01',
      correct: true,
      now: start,
    );
    expect(
      controller.reviewDue('lesson_01', 'exercise_01'),
      start.add(const Duration(days: 7)),
    );

    await controller.recordReviewResult(
      'lesson_01',
      'exercise_01',
      correct: true,
      now: start,
    );
    expect(
      controller.reviewDue('lesson_01', 'exercise_01'),
      start.add(const Duration(days: 14)),
    );
  });

  test('schedules a newly correct item for one-day review', () async {
    final controller = UserDataController.inMemory();
    final start = DateTime.utc(2026, 8, 17);

    await controller.recordReviewResult(
      'lesson_01',
      'exercise_02',
      correct: true,
      now: start,
    );

    expect(controller.reviewStage('lesson_01', 'exercise_02'), 0);
    expect(
      controller.reviewDue('lesson_01', 'exercise_02'),
      start.add(const Duration(days: 1)),
    );
  });

  test('changes app text scale within supported bounds', () async {
    final controller = UserDataController.inMemory();

    await controller.setTextScale(1.4);
    expect(controller.textScale, 1.4);

    await controller.setTextScale(2);
    expect(controller.textScale, 1.4);
  });
}
