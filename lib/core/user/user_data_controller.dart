import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../storage/storage_keys.dart';

enum BookmarkType { lesson, example, glossary }

enum LearnerProfile { youngLearner, generalLearner }

enum LearningMode { simple, detailed, adult }

class UserDataController extends ChangeNotifier {
  UserDataController(this._box)
    : _textScale = (_boxValue<double>(_box, StorageKeys.textScale) ?? 1.0)
          .clamp(0.9, 1.4),
      _learnerProfile = _profileValue(
        _box?.get(StorageKeys.learnerProfile),
        _box?.get(StorageKeys.learningMode),
      );

  UserDataController.inMemory()
    : _box = null,
      _textScale = 1.0,
      _learnerProfile = LearnerProfile.youngLearner;

  final Box<dynamic>? _box;
  final Set<String> _bookmarks = {};
  final Map<String, int> _reviewStages = {};
  final Map<String, DateTime> _reviewDueDates = {};
  double _textScale;
  LearnerProfile _learnerProfile;

  double get textScale => _textScale;
  // Without persistence there is nothing to onboard into, so skip the prompt.
  bool get hasLearnerProfile =>
      _box?.containsKey(StorageKeys.learnerProfile) ?? true;
  LearnerProfile get learnerProfile => _learnerProfile;
  LearningMode get learningMode => switch (_learnerProfile) {
    LearnerProfile.youngLearner => LearningMode.simple,
    LearnerProfile.generalLearner => LearningMode.adult,
  };

  Future<void> setTextScale(double value) async {
    final normalized = value.clamp(0.9, 1.4);
    if (_textScale == normalized) return;
    _textScale = normalized;
    await _box?.put(StorageKeys.textScale, normalized);
    notifyListeners();
  }

  Future<void> setLearnerProfile(LearnerProfile profile) async {
    if (_learnerProfile == profile) return;
    _learnerProfile = profile;
    await _box?.put(StorageKeys.learnerProfile, profile.name);
    notifyListeners();
  }

  bool isBookmarked(BookmarkType type, String id) {
    final key = StorageKeys.bookmark(type.name, id);
    return _bookmarks.contains(key) || (_box?.get(key) as bool? ?? false);
  }

  Future<void> toggleBookmark(BookmarkType type, String id) async {
    final key = StorageKeys.bookmark(type.name, id);
    if (isBookmarked(type, id)) {
      _bookmarks.remove(key);
      await _box?.delete(key);
    } else {
      _bookmarks.add(key);
      await _box?.put(key, true);
    }
    notifyListeners();
  }

  Set<String> bookmarkedIds(BookmarkType type) {
    final prefix = '${StorageKeys.bookmarkPrefix}${type.name}.';
    final stored =
        _box?.keys.whereType<String>().where(
          (key) => key.startsWith(prefix) && _box.get(key) == true,
        ) ??
        const Iterable<String>.empty();
    return {
      ..._bookmarks.where((key) => key.startsWith(prefix)),
      ...stored,
    }.map((key) => key.substring(prefix.length)).toSet();
  }

  bool isReviewDue(String lessonId, String exerciseId, {DateTime? now}) {
    final due = reviewDue(lessonId, exerciseId);
    return due != null && !due.isAfter(now ?? DateTime.now());
  }

  DateTime? reviewDue(String lessonId, String exerciseId) {
    final key = StorageKeys.reviewDue(lessonId, exerciseId);
    final cached = _reviewDueDates[key];
    if (cached != null) return cached;
    final stored = _box?.get(key) as String?;
    return stored == null ? null : DateTime.tryParse(stored);
  }

  int reviewStage(String lessonId, String exerciseId) {
    final key = StorageKeys.reviewStage(lessonId, exerciseId);
    return _reviewStages[key] ?? (_box?.get(key) as int? ?? -1);
  }

  Future<void> recordReviewResult(
    String lessonId,
    String exerciseId, {
    required bool correct,
    DateTime? now,
  }) async {
    const intervals = [1, 3, 7, 14];
    final currentStage = reviewStage(lessonId, exerciseId);
    final nextStage = correct ? (currentStage + 1).clamp(0, 3) : 0;
    final due = (now ?? DateTime.now()).add(
      Duration(days: intervals[nextStage]),
    );
    final stageKey = StorageKeys.reviewStage(lessonId, exerciseId);
    final dueKey = StorageKeys.reviewDue(lessonId, exerciseId);
    _reviewStages[stageKey] = nextStage;
    _reviewDueDates[dueKey] = due;
    await _box?.putAll({stageKey: nextStage, dueKey: due.toIso8601String()});
    notifyListeners();
  }

  static T? _boxValue<T>(Box<dynamic>? box, String key) => box?.get(key) as T?;

  static LearnerProfile _profileValue(Object? profile, Object? legacyMode) {
    if (profile == LearnerProfile.generalLearner.name) {
      return LearnerProfile.generalLearner;
    }
    if (profile == LearnerProfile.youngLearner.name) {
      return LearnerProfile.youngLearner;
    }
    return legacyMode == LearningMode.adult.name
        ? LearnerProfile.generalLearner
        : LearnerProfile.youngLearner;
  }
}
