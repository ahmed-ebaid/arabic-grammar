import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/content_models.dart';
import '../services/review_prompt_service.dart';
import '../storage/storage_keys.dart';

class LessonProgressController extends ChangeNotifier {
  LessonProgressController(
    this._box, {
    ReviewPromptService? reviewPromptService,
  }) : reviewPromptService = reviewPromptService ?? ReviewPromptService();

  LessonProgressController.inMemory({this.reviewPromptService}) : _box = null;

  static const xpPerCorrectAnswer = 10;
  static const streakMilestones = {3, 7, 14, 30, 60, 100};

  final Box<dynamic>? _box;
  final ReviewPromptService? reviewPromptService;
  final Map<String, int> _steps = {};
  final Set<String> _completedLessons = {};
  final Map<String, int> _mastery = {};
  final Map<String, int> _attempts = {};
  final Map<String, bool> _answers = {};
  final Map<String, String> _structures = {};
  final Map<String, String> _exerciseBanks = {};
  final Map<String, bool> _attemptFinished = {};
  final Map<String, String> _contentRevisions = {};
  bool _contentUpdatesInitialized = false;
  final Map<String, int> _practiceStats = {};
  String? _practiceDate;
  String? _lastActiveLessonId;

  String? get lastActiveLessonId =>
      _lastActiveLessonId ??
      _box?.get(StorageKeys.lastActiveLessonId) as String?;

  Future<void> markLessonActive(String lessonId) async {
    if (lastActiveLessonId == lessonId) {
      return;
    }
    _lastActiveLessonId = lessonId;
    await _box?.put(StorageKeys.lastActiveLessonId, lessonId);
    notifyListeners();
  }

  int stepFor(String lessonId) {
    return _steps[lessonId] ??
        (_box?.get(StorageKeys.lessonStep(lessonId)) as int? ?? 0);
  }

  /// Binds the saved position to the ordered steps and active exercise bank.
  /// Legacy positions have no reliable structure and are restarted safely.
  Future<({int step, bool repeat})> prepareLesson(Lesson lesson) async {
    final id = lesson.id;
    final storedBank =
        _exerciseBanks[id] ??
        _box?.get(StorageKeys.lessonExerciseBank(id)) as String?;
    final repeat = storedBank == null
        ? lesson.repeatExercises.isNotEmpty && attemptsFor(id).isOdd
        : storedBank == 'repeat' && lesson.repeatExercises.isNotEmpty;
    final bank = repeat ? 'repeat' : 'primary';
    final exercises = repeat ? lesson.repeatExercises : lesson.exercises;
    final structure = jsonEncode([
      'v1',
      bank,
      'objectives',
      for (final section in lesson.sections) ...[
        ['teaching', section.id],
        for (final example in section.examples) ['analysis', example.id],
      ],
      if (lesson.mindMap != null) 'mindMap',
      for (final exercise in exercises) ['exercise', exercise.id],
      'completion',
    ]);
    final previous =
        _structures[id] ??
        _box?.get(StorageKeys.lessonStructure(id)) as String?;
    final stepCount =
        2 +
        lesson.sections.length +
        lesson.sections.fold<int>(0, (sum, s) => sum + s.examples.length) +
        (lesson.mindMap == null ? 0 : 1) +
        exercises.length;
    var step = previous == structure ? stepFor(id) : 0;
    if (step < 0 || step >= stepCount) step = 0;

    // A damaged or partially saved position must never skip an unanswered item.
    final firstExercise = stepCount - exercises.length - 1;
    for (var i = 0; i < exercises.length && firstExercise + i < step; i++) {
      if (firstAttemptResult(id, exercises[i].id) == null) {
        step = firstExercise + i;
        break;
      }
    }

    _steps[id] = step;
    _structures[id] = structure;
    _exerciseBanks[id] = bank;
    final finished = previous == structure && isAttemptFinished(id);
    _attemptFinished[id] = finished;
    await _box?.putAll({
      StorageKeys.lessonStep(id): step,
      StorageKeys.lessonStructure(id): structure,
      StorageKeys.lessonExerciseBank(id): bank,
      StorageKeys.lessonAttemptFinished(id): finished,
    });
    return (step: step, repeat: repeat);
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

  bool isAttemptFinished(String lessonId) =>
      _attemptFinished[lessonId] ??
      (_box?.get(StorageKeys.lessonAttemptFinished(lessonId)) as bool? ??
          false);

  bool isMastered(String lessonId) => masteryFor(lessonId) >= 70;

  String _revisionFor(Lesson lesson) => lesson.contentRevision.isNotEmpty
      ? lesson.contentRevision
      : lesson.review.contentVersion;

  bool _hasLessonExperience(String lessonId) =>
      isCompleted(lessonId) ||
      attemptsFor(lessonId) > 0 ||
      stepFor(lessonId) > 0 ||
      (_structures[lessonId] ??
              _box?.get(StorageKeys.lessonStructure(lessonId)) as String?) !=
          null ||
      lastActiveLessonId == lessonId;

  bool hasLessonUpdate(Lesson lesson) {
    final seen =
        _contentRevisions[lesson.id] ??
        _box?.get(StorageKeys.lessonContentRevision(lesson.id)) as String?;
    return seen != null &&
        seen != _revisionFor(lesson) &&
        _hasLessonExperience(lesson.id);
  }

  Future<void> initializeLessonUpdates(List<Lesson> lessons) async {
    if (_contentUpdatesInitialized ||
        (_box?.get(StorageKeys.lessonUpdatesInitialized) as bool? ?? false)) {
      return;
    }
    final updates = <String, Object>{
      StorageKeys.lessonUpdatesInitialized: true,
    };
    for (final lesson in lessons) {
      final revision = _hasLessonExperience(lesson.id)
          ? 'legacy'
          : _revisionFor(lesson);
      _contentRevisions[lesson.id] = revision;
      updates[StorageKeys.lessonContentRevision(lesson.id)] = revision;
    }
    await _box?.putAll(updates);
    _contentUpdatesInitialized = true;
  }

  Future<void> markLessonUpdateSeen(Lesson lesson) async {
    final revision = _revisionFor(lesson);
    _contentRevisions[lesson.id] = revision;
    await _box?.put(StorageKeys.lessonContentRevision(lesson.id), revision);
    notifyListeners();
  }

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

  int get streakCount => _practiceInt(StorageKeys.streakCount);

  int get totalXp => _practiceInt(StorageKeys.totalXp);

  bool get isStreakMilestone => streakMilestones.contains(streakCount);

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
    if (correct) {
      _practiceStats[StorageKeys.totalXp] = totalXp + xpPerCorrectAnswer;
    }
    await _box?.putAll({
      key: correct,
      if (correct) StorageKeys.totalXp: totalXp,
    });
    if (correct) {
      notifyListeners();
    }
  }

  Future<void> saveStep(String lessonId, int step) async {
    _steps[lessonId] = step;
    _lastActiveLessonId = lessonId;
    await _box?.putAll({
      StorageKeys.lessonStep(lessonId): step,
      StorageKeys.lastActiveLessonId: lessonId,
    });
    notifyListeners();
  }

  Future<void> complete(
    String lessonId,
    int finalStep, {
    required int mastery,
  }) async {
    final completed = isCompleted(lessonId) || mastery >= 70;
    _steps[lessonId] = finalStep;
    _mastery[lessonId] = mastery;
    _attempts[lessonId] = attemptsFor(lessonId) + 1;
    _attemptFinished[lessonId] = true;
    _lastActiveLessonId = lessonId;
    if (completed) {
      _completedLessons.add(lessonId);
    }
    await _box?.putAll({
      StorageKeys.lessonStep(lessonId): finalStep,
      StorageKeys.lessonMastery(lessonId): mastery,
      StorageKeys.lessonAttempts(lessonId): _attempts[lessonId],
      StorageKeys.lessonAttemptFinished(lessonId): true,
      StorageKeys.lessonCompleted(lessonId): completed,
      StorageKeys.lastActiveLessonId: lessonId,
    });
    await _bumpStreakForToday();
    await reviewPromptService?.recordMeaningfulLearningDay();
    notifyListeners();
  }

  Future<void> restart(String lessonId) async {
    _steps[lessonId] = 0;
    _lastActiveLessonId = lessonId;
    final answerPrefix = 'lesson.$lessonId.answer.';
    final keys = {
      ..._answers.keys.where((key) => key.startsWith(answerPrefix)),
      ...?_box?.keys.whereType<String>().where(
        (key) => key.startsWith(answerPrefix),
      ),
    };
    _answers.removeWhere((key, _) => key.startsWith(answerPrefix));
    await _box?.deleteAll(keys);
    _structures.remove(lessonId);
    _exerciseBanks.remove(lessonId);
    _attemptFinished[lessonId] = false;
    await _box?.deleteAll([
      StorageKeys.lessonStructure(lessonId),
      StorageKeys.lessonExerciseBank(lessonId),
    ]);
    await _box?.putAll({
      StorageKeys.lessonStep(lessonId): 0,
      StorageKeys.lessonAttemptFinished(lessonId): false,
      StorageKeys.lastActiveLessonId: lessonId,
    });
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
    await _awardXp(correct * xpPerCorrectAnswer);
    await _bumpStreakForToday();
    await reviewPromptService?.recordMeaningfulLearningDay();
    notifyListeners();
  }

  Future<void> _awardXp(int amount) async {
    if (amount <= 0) {
      return;
    }
    final updated = totalXp + amount;
    _practiceStats[StorageKeys.totalXp] = updated;
    await _box?.put(StorageKeys.totalXp, updated);
  }

  Future<void> _bumpStreakForToday() async {
    final today = _dateKey(DateTime.now());
    final storedDate = _box?.get(StorageKeys.streakDate) as String?;
    if (storedDate == today) {
      return;
    }
    final yesterday = _dateKey(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    final updated = storedDate == yesterday ? streakCount + 1 : 1;
    _practiceStats[StorageKeys.streakCount] = updated;
    await _box?.putAll({
      StorageKeys.streakDate: today,
      StorageKeys.streakCount: updated,
    });
  }

  int _practiceInt(String key) =>
      _practiceStats[key] ?? (_box?.get(key) as int? ?? 0);

  static String _dateKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
