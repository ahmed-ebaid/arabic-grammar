abstract final class StorageKeys {
  static const settingsBox = 'settings';
  static const progressBox = 'progress';
  static const locale = 'locale';
  static const textScale = 'accessibility.textScale';
  static const bookmarkPrefix = 'bookmark.';
  static const reviewPrefix = 'review.';

  static String lessonStep(String lessonId) => 'lesson.$lessonId.step';
  static String lessonCompleted(String lessonId) =>
      'lesson.$lessonId.completed';

  static String lessonMastery(String lessonId) => 'lesson.$lessonId.mastery';

  static String lessonAttempts(String lessonId) => 'lesson.$lessonId.attempts';

  static String lessonAnswer(String lessonId, String exerciseId) =>
      'lesson.$lessonId.answer.$exerciseId';

  static const practiceTotalAnswered = 'practice.totalAnswered';
  static const practiceTotalCorrect = 'practice.totalCorrect';
  static const practiceSessionsCompleted = 'practice.sessionsCompleted';
  static const practiceBestScore = 'practice.bestScore';
  static const practiceTotalStars = 'practice.totalStars';
  static const practiceDailyDate = 'practice.dailyDate';
  static const practiceDailyAnswered = 'practice.dailyAnswered';

  static String bookmark(String type, String id) => '$bookmarkPrefix$type.$id';

  static String reviewStage(String lessonId, String exerciseId) =>
      '$reviewPrefix$lessonId.$exerciseId.stage';

  static String reviewDue(String lessonId, String exerciseId) =>
      '$reviewPrefix$lessonId.$exerciseId.due';
}
