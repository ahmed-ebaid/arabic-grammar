abstract final class StorageKeys {
  static const settingsBox = 'settings';
  static const progressBox = 'progress';
  static const locale = 'locale';

  static String lessonStep(String lessonId) => 'lesson.$lessonId.step';
  static String lessonCompleted(String lessonId) =>
      'lesson.$lessonId.completed';
}
