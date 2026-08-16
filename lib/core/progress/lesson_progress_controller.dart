import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../storage/storage_keys.dart';

class LessonProgressController extends ChangeNotifier {
  LessonProgressController(this._box);

  LessonProgressController.inMemory() : _box = null;

  final Box<dynamic>? _box;
  final Map<String, int> _steps = {};
  final Set<String> _completedLessons = {};

  int stepFor(String lessonId) {
    return _steps[lessonId] ??
        (_box?.get(StorageKeys.lessonStep(lessonId)) as int? ?? 0);
  }

  bool isCompleted(String lessonId) {
    return _completedLessons.contains(lessonId) ||
        (_box?.get(StorageKeys.lessonCompleted(lessonId)) as bool? ?? false);
  }

  Future<void> saveStep(String lessonId, int step) async {
    _steps[lessonId] = step;
    await _box?.put(StorageKeys.lessonStep(lessonId), step);
    notifyListeners();
  }

  Future<void> complete(String lessonId, int finalStep) async {
    _steps[lessonId] = finalStep;
    _completedLessons.add(lessonId);
    await _box?.putAll({
      StorageKeys.lessonStep(lessonId): finalStep,
      StorageKeys.lessonCompleted(lessonId): true,
    });
    notifyListeners();
  }

  Future<void> restart(String lessonId) async {
    _steps[lessonId] = 0;
    _completedLessons.remove(lessonId);
    await _box?.putAll({
      StorageKeys.lessonStep(lessonId): 0,
      StorageKeys.lessonCompleted(lessonId): false,
    });
    notifyListeners();
  }
}
