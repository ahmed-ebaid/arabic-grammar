abstract final class StorageKeys {
  static const settingsBox = 'settings';
  static const progressBox = 'progress';
  static const locale = 'locale';

  static String lessonStep(String lessonId) => 'lesson.$lessonId.step';
  static String lessonCompleted(String lessonId) =>
      'lesson.$lessonId.completed';

  static String lessonMastery(String lessonId) => 'lesson.$lessonId.mastery';

  static String lessonAttempts(String lessonId) => 'lesson.$lessonId.attempts';

  static String lessonAnswer(String lessonId, String exerciseId) =>
      'lesson.$lessonId.answer.$exerciseId';
}
