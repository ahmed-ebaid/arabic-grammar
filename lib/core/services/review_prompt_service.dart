import 'package:hive_flutter/hive_flutter.dart';

import '../storage/storage_keys.dart';

class ReviewPromptService {
  ReviewPromptService({Box<dynamic>? settingsBox})
    : _settingsBox = settingsBox ?? _defaultBox();

  static const settingsBoxName = StorageKeys.settingsBox;
  static const learningDaysKey = StorageKeys.reviewPromptLearningDays;
  static const lastAttemptKey = StorageKeys.reviewPromptLastAttempt;
  static const eligibleLearningDays = 3;
  static const cooldown = Duration(days: 120);

  final Box<dynamic>? _settingsBox;
  final Set<String> _memoryDays = {};
  String? _memoryLastAttempt;

  static Box<dynamic>? _defaultBox() =>
      Hive.isBoxOpen(settingsBoxName) ? Hive.box(settingsBoxName) : null;

  Set<String> get learningDays {
    final value = _settingsBox?.get(learningDaysKey, defaultValue: <String>[]);
    return {..._memoryDays, if (value is List) ...value.whereType<String>()};
  }

  bool get isEligible => learningDays.length >= eligibleLearningDays;

  bool shouldRequestAtLaunch({DateTime? now}) {
    if (!isEligible) return false;
    final lastAttemptValue =
        _memoryLastAttempt ?? _settingsBox?.get(lastAttemptKey);
    if (lastAttemptValue is! String) return true;
    final lastAttempt = DateTime.tryParse(lastAttemptValue);
    if (lastAttempt == null) return true;
    return (now ?? DateTime.now()).difference(lastAttempt) >= cooldown;
  }

  Future<void> recordMeaningfulLearningDay({DateTime? date}) async {
    final days = learningDays;
    if (days.length >= eligibleLearningDays) return;

    final now = date ?? DateTime.now();
    final dayKey =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    if (days.add(dayKey)) {
      _memoryDays.add(dayKey);
      await _settingsBox?.put(learningDaysKey, days.toList()..sort());
    }
  }

  Future<void> recordPromptAttempt({DateTime? now}) async {
    final value = (now ?? DateTime.now()).toIso8601String();
    _memoryLastAttempt = value;
    await _settingsBox?.put(lastAttemptKey, value);
  }

  Future<bool> requestAtLaunch({
    DateTime? now,
    required Future<bool> Function() isAvailable,
    required Future<void> Function() requestReview,
  }) async {
    if (!shouldRequestAtLaunch(now: now) || !await isAvailable()) {
      return false;
    }
    await recordPromptAttempt(now: now);
    await requestReview();
    return true;
  }
}
