import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../storage/storage_keys.dart';

class LessonProgressController extends ChangeNotifier {
  LessonProgressController(this._box);

  LessonProgressController.inMemory() : _box = null;

  final Box<dynamic>? _box;
  final Map<String, int> _steps = {};
  final Set<String> _completedLessons = {};
  final Map<String, int> _mastery = {};
  final Map<String, int> _attempts = {};
  final Map<String, bool> _answers = {};
  final Map<String, int> _practiceStats = {};
  String? _practiceDate;

  int stepFor(String lessonId) {
    return _steps[lessonId] ??
        (_box?.get(StorageKeys.lessonStep(lessonId)) as int? ?? 0);
  }

  bool isCompleted(String lessonId) {
    return _completedLessons.contains(lessonId) ||
        (_box?.get(StorageKeys.lessonCompleted(lessonId)) as bool? ?? false);
  }

  int masteryFor(String lessonId) {
    final mastery =
        _mastery[lessonId] ??
        _box?.get(StorageKeys.lessonMastery(lessonId)) as int?;
    if (mastery == null && isCompleted(lessonId)) {
      return 100;
    }
    return mastery ?? 0;
  }

  int attemptsFor(String lessonId) {
    return _attempts[lessonId] ??
        (_box?.get(StorageKeys.lessonAttempts(lessonId)) as int? ?? 0);
  }

  bool isMastered(String lessonId) => masteryFor(lessonId) >= 70;

  int get practiceTotalAnswered =>
      _practiceInt(StorageKeys.practiceTotalAnswered);

  int get practiceTotalCorrect =>
      _practiceInt(StorageKeys.practiceTotalCorrect);

  int get practiceSessionsCompleted =>
      _practiceInt(StorageKeys.practiceSessionsCompleted);

  int get practiceBestScore => _practiceInt(StorageKeys.practiceBestScore);

  int get practiceTotalStars => _practiceInt(StorageKeys.practiceTotalStars);

  int get practiceDailyAnswered {
    final today = _dateKey(DateTime.now());
    final storedDate =
        _practiceDate ?? _box?.get(StorageKeys.practiceDailyDate) as String?;
    if (storedDate != today) {
      return 0;
    }
    return _practiceInt(StorageKeys.practiceDailyAnswered);
  }

  bool? firstAttemptResult(String lessonId, String exerciseId) {
    final key = StorageKeys.lessonAnswer(lessonId, exerciseId);
    return _answers[key] ?? _box?.get(key) as bool?;
  }

  Future<void> recordFirstAttempt(
    String lessonId,
    String exerciseId, {
    required bool correct,
  }) async {
    final key = StorageKeys.lessonAnswer(lessonId, exerciseId);
    if (firstAttemptResult(lessonId, exerciseId) != null) {
      return;
    }
    _answers[key] = correct;
    await _box?.put(key, correct);
  }

  Future<void> saveStep(String lessonId, int step) async {
    _steps[lessonId] = step;
    await _box?.put(StorageKeys.lessonStep(lessonId), step);
    notifyListeners();
  }

  Future<void> complete(
    String lessonId,
    int finalStep, {
    required int mastery,
  }) async {
    final bestMastery = mastery > masteryFor(lessonId)
        ? mastery
        : masteryFor(lessonId);
    _steps[lessonId] = finalStep;
    _mastery[lessonId] = bestMastery;
    _attempts[lessonId] = attemptsFor(lessonId) + 1;
    if (bestMastery >= 70) {
      _completedLessons.add(lessonId);
    }
    await _box?.putAll({
      StorageKeys.lessonStep(lessonId): finalStep,
      StorageKeys.lessonMastery(lessonId): bestMastery,
      StorageKeys.lessonAttempts(lessonId): _attempts[lessonId],
      StorageKeys.lessonCompleted(lessonId): bestMastery >= 70,
    });
    notifyListeners();
  }

  Future<void> restart(String lessonId) async {
    _steps[lessonId] = 0;
    final answerPrefix = 'lesson.$lessonId.answer.';
    _answers.removeWhere((key, _) => key.startsWith(answerPrefix));
    final storedAnswerKeys = _box?.keys
        .whereType<String>()
        .where((key) => key.startsWith(answerPrefix))
        .toList();
    await _box?.deleteAll(storedAnswerKeys ?? const <String>[]);
    await _box?.put(StorageKeys.lessonStep(lessonId), 0);
    notifyListeners();
  }

  Future<void> recordPracticeSession({
    required int answered,
    required int correct,
  }) async {
    if (answered < 1 || correct < 0 || correct > answered) {
      throw ArgumentError('Invalid practice result: $correct/$answered');
    }

    final score = ((correct / answered) * 100).round();
    final stars = score >= 90
        ? 3
        : score >= 70
        ? 2
        : 1;
    final today = _dateKey(DateTime.now());
    final dailyAnswered = practiceDailyAnswered + answered;
    final bestScore = score > practiceBestScore ? score : practiceBestScore;

    _practiceDate = today;
    _practiceStats.addAll({
      StorageKeys.practiceTotalAnswered: practiceTotalAnswered + answered,
      StorageKeys.practiceTotalCorrect: practiceTotalCorrect + correct,
      StorageKeys.practiceSessionsCompleted: practiceSessionsCompleted + 1,
      StorageKeys.practiceBestScore: bestScore,
      StorageKeys.practiceTotalStars: practiceTotalStars + stars,
      StorageKeys.practiceDailyAnswered: dailyAnswered,
    });
    await _box?.putAll({
      StorageKeys.practiceTotalAnswered:
          _practiceStats[StorageKeys.practiceTotalAnswered],
      StorageKeys.practiceTotalCorrect:
          _practiceStats[StorageKeys.practiceTotalCorrect],
      StorageKeys.practiceSessionsCompleted:
          _practiceStats[StorageKeys.practiceSessionsCompleted],
      StorageKeys.practiceBestScore:
          _practiceStats[StorageKeys.practiceBestScore],
      StorageKeys.practiceTotalStars:
          _practiceStats[StorageKeys.practiceTotalStars],
      StorageKeys.practiceDailyDate: today,
      StorageKeys.practiceDailyAnswered: dailyAnswered,
    });
    notifyListeners();
  }

  int _practiceInt(String key) =>
      _practiceStats[key] ?? (_box?.get(key) as int? ?? 0);

  static String _dateKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
