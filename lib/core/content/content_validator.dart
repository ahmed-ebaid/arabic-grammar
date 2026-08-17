import '../models/content_models.dart';

class ContentValidationIssue {
  const ContentValidationIssue({required this.path, required this.message});

  final String path;
  final String message;

  @override
  String toString() => '$path: $message';
}

abstract final class ContentValidator {
  static List<ContentValidationIssue> validate(
    ContentCatalog catalog, {
    bool requireReleaseApproval = false,
  }) {
    final issues = <ContentValidationIssue>[];

    if (catalog.schemaVersion != 1) {
      issues.add(
        ContentValidationIssue(
          path: r'$.schemaVersion',
          message: 'unsupported schema version ${catalog.schemaVersion}',
        ),
      );
    }

    final lessonIds = <String>{};
    final lessonOrders = <int>{};
    final lessonsById = <String, Lesson>{};
    for (final (index, lesson) in catalog.lessons.indexed) {
      final path =
          r'$.lessons['
          '$index]';
      if (!RegExp(r'^lesson_[0-9]{2}$').hasMatch(lesson.id)) {
        issues.add(
          ContentValidationIssue(
            path: '$path.id',
            message: 'must match lesson_ followed by two digits',
          ),
        );
      }
      if (!lessonIds.add(lesson.id)) {
        issues.add(
          ContentValidationIssue(
            path: '$path.id',
            message: 'duplicate lesson id ${lesson.id}',
          ),
        );
      }
      if (lesson.order < 1 || !lessonOrders.add(lesson.order)) {
        issues.add(
          ContentValidationIssue(
            path: '$path.order',
            message: 'must be a unique positive integer',
          ),
        );
      }
      lessonsById[lesson.id] = lesson;
      _validateLesson(
        lesson,
        path,
        issues,
        requireReleaseApproval: requireReleaseApproval,
      );
    }

    final levelIds = <String>{};
    final levelOrders = <int>{};
    final assignedLessonIds = <String>{};
    for (final (index, level) in catalog.levels.indexed) {
      final path =
          r'$.levels['
          '$index]';
      if (!RegExp(r'^level_[0-9]{2}$').hasMatch(level.id)) {
        issues.add(
          ContentValidationIssue(
            path: '$path.id',
            message: 'must match level_ followed by two digits',
          ),
        );
      }
      if (!levelIds.add(level.id)) {
        issues.add(
          ContentValidationIssue(
            path: '$path.id',
            message: 'duplicate level id ${level.id}',
          ),
        );
      }
      if (level.order < 1 || !levelOrders.add(level.order)) {
        issues.add(
          ContentValidationIssue(
            path: '$path.order',
            message: 'must be a unique positive integer',
          ),
        );
      }
      if (level.lessonIds.isEmpty) {
        issues.add(
          ContentValidationIssue(
            path: '$path.lessonIds',
            message: 'must contain at least one lesson id',
          ),
        );
      }
      for (final lessonId in level.lessonIds) {
        if (!lessonIds.contains(lessonId)) {
          issues.add(
            ContentValidationIssue(
              path: '$path.lessonIds',
              message: 'unknown lesson id $lessonId',
            ),
          );
        } else if (!assignedLessonIds.add(lessonId)) {
          issues.add(
            ContentValidationIssue(
              path: '$path.lessonIds',
              message: 'lesson $lessonId is assigned to more than one level',
            ),
          );
        }
      }
    }
    if (catalog.levels.isNotEmpty &&
        assignedLessonIds.length != lessonIds.length) {
      issues.add(
        const ContentValidationIssue(
          path: r'$.levels',
          message: 'every lesson must be assigned to exactly one level',
        ),
      );
    }
    final expectedLevelOrders = List<int>.generate(
      catalog.levels.length,
      (index) => index + 1,
    );
    final actualLevelOrders = levelOrders.toList()..sort();
    if (!_sameValues(expectedLevelOrders, actualLevelOrders)) {
      issues.add(
        const ContentValidationIssue(
          path: r'$.levels',
          message: 'level order values must be contiguous starting at 1',
        ),
      );
    }

    final expectedOrders = List<int>.generate(
      catalog.lessons.length,
      (index) => index + 1,
    );
    final actualOrders = lessonOrders.toList()..sort();
    if (!_sameValues(expectedOrders, actualOrders)) {
      issues.add(
        const ContentValidationIssue(
          path: r'$.lessons',
          message: 'lesson order values must be contiguous starting at 1',
        ),
      );
    }

    for (final (index, lesson) in catalog.lessons.indexed) {
      for (final prerequisite in lesson.prerequisites) {
        final requiredLesson = lessonsById[prerequisite];
        if (requiredLesson == null) {
          issues.add(
            ContentValidationIssue(
              path:
                  r'$.lessons['
                  '$index].prerequisites',
              message: 'unknown prerequisite $prerequisite',
            ),
          );
        } else if (requiredLesson.order >= lesson.order) {
          issues.add(
            ContentValidationIssue(
              path:
                  r'$.lessons['
                  '$index].prerequisites',
              message: '$prerequisite must come before ${lesson.id}',
            ),
          );
        }
      }
    }

    return issues;
  }

  static void _validateLesson(
    Lesson lesson,
    String path,
    List<ContentValidationIssue> issues, {
    required bool requireReleaseApproval,
  }) {
    if (lesson.estimatedMinutes < 1 || lesson.estimatedMinutes > 60) {
      issues.add(
        ContentValidationIssue(
          path: '$path.estimatedMinutes',
          message: 'must be between 1 and 60',
        ),
      );
    }
    if (lesson.objectives.isEmpty) {
      issues.add(
        ContentValidationIssue(
          path: '$path.objectives',
          message: 'must contain at least one objective',
        ),
      );
    }
    if (lesson.sections.isEmpty) {
      issues.add(
        ContentValidationIssue(
          path: '$path.sections',
          message: 'must contain at least one section',
        ),
      );
    }
    if (lesson.exercises.length < 4) {
      issues.add(
        ContentValidationIssue(
          path: '$path.exercises',
          message: 'must contain at least four exercises',
        ),
      );
    }
    if (lesson.repeatExercises.length < 4) {
      issues.add(
        ContentValidationIssue(
          path: '$path.repeatExercises',
          message: 'must contain at least four alternate exercises',
        ),
      );
    }
    if (lesson.sources.isEmpty) {
      issues.add(
        ContentValidationIssue(
          path: '$path.sources',
          message: 'must contain provenance records',
        ),
      );
    }

    for (final (sourceIndex, source) in lesson.sources.indexed) {
      final url = source.url;
      if (url == null) {
        continue;
      }
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.isAbsolute || uri.host.isEmpty) {
        issues.add(
          ContentValidationIssue(
            path: '$path.sources[$sourceIndex].url',
            message: 'must be an absolute URL',
          ),
        );
      }
    }

    _validateUniqueIds(
      lesson.sections.map((section) => section.id),
      '$path.sections',
      issues,
    );
    _validateUniqueIds(
      lesson.exercises.map((exercise) => exercise.id),
      '$path.exercises',
      issues,
    );
    _validateUniqueIds(
      lesson.repeatExercises.map((exercise) => exercise.id),
      '$path.repeatExercises',
      issues,
    );
    _validateUniqueIds(
      lesson.sources.map((source) => source.id),
      '$path.sources',
      issues,
    );

    for (final (sectionIndex, section) in lesson.sections.indexed) {
      final sectionPath = '$path.sections[$sectionIndex]';
      _validateUniqueIds(
        section.examples.map((example) => example.id),
        '$sectionPath.examples',
        issues,
      );
      for (final (exampleIndex, example) in section.examples.indexed) {
        _validateExample(
          example,
          '$sectionPath.examples[$exampleIndex]',
          issues,
        );
      }
    }

    for (final (exerciseIndex, exercise) in lesson.exercises.indexed) {
      _validateExercise(exercise, '$path.exercises[$exerciseIndex]', issues);
    }
    for (final (exerciseIndex, exercise) in lesson.repeatExercises.indexed) {
      _validateExercise(
        exercise,
        '$path.repeatExercises[$exerciseIndex]',
        issues,
      );
    }
    if (lesson.repeatExercises.isNotEmpty &&
        lesson.repeatExercises.length != lesson.exercises.length) {
      issues.add(
        ContentValidationIssue(
          path: '$path.repeatExercises',
          message: 'must contain the same number of exercises as exercises',
        ),
      );
    }

    final review = lesson.review;
    if (review.status == ReviewStatus.approved) {
      if (review.reviewer == null) {
        issues.add(
          ContentValidationIssue(
            path: '$path.review.reviewer',
            message: 'is required for approved content',
          ),
        );
      }
      if (review.reviewedAt == null) {
        issues.add(
          ContentValidationIssue(
            path: '$path.review.reviewedAt',
            message: 'must be a valid ISO-8601 date for approved content',
          ),
        );
      }
    } else if (requireReleaseApproval) {
      issues.add(
        ContentValidationIssue(
          path: '$path.review.status',
          message: 'must be approved for a release build',
        ),
      );
    }
  }

  static void _validateExample(
    GrammarExample example,
    String path,
    List<ContentValidationIssue> issues,
  ) {
    var previousEnd = 0;
    for (final (tokenIndex, token) in example.tokens.indexed) {
      final tokenPath = '$path.tokens[$tokenIndex]';
      final validRange =
          token.start >= 0 &&
          token.end > token.start &&
          token.end <= example.unvocalized.length;
      if (!validRange) {
        issues.add(
          ContentValidationIssue(
            path: tokenPath,
            message: 'token span is outside the unvocalized text',
          ),
        );
        continue;
      }
      if (token.start < previousEnd) {
        issues.add(
          ContentValidationIssue(
            path: tokenPath,
            message: 'token spans must not overlap',
          ),
        );
      }
      final actualText = example.unvocalized.substring(token.start, token.end);
      if (actualText != token.text) {
        issues.add(
          ContentValidationIssue(
            path: '$tokenPath.text',
            message: 'expected "$actualText" from the declared span',
          ),
        );
      }
      previousEnd = token.end;
    }
  }

  static void _validateExercise(
    Exercise exercise,
    String path,
    List<ContentValidationIssue> issues,
  ) {
    if (exercise.options.length < 2) {
      issues.add(
        ContentValidationIssue(
          path: '$path.options',
          message: 'must contain at least two options',
        ),
      );
    }
    _validateUniqueIds(
      exercise.options.map((option) => option.id),
      '$path.options',
      issues,
    );
    final correctCount = exercise.options
        .where((option) => option.isCorrect)
        .length;
    if (correctCount != 1) {
      issues.add(
        ContentValidationIssue(
          path: '$path.options',
          message: 'must contain exactly one correct option',
        ),
      );
    }
  }

  static void _validateUniqueIds(
    Iterable<String> ids,
    String path,
    List<ContentValidationIssue> issues,
  ) {
    final seen = <String>{};
    for (final id in ids) {
      if (!seen.add(id)) {
        issues.add(
          ContentValidationIssue(path: path, message: 'duplicate id $id'),
        );
      }
    }
  }

  static bool _sameValues(List<int> first, List<int> second) {
    if (first.length != second.length) {
      return false;
    }
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) {
        return false;
      }
    }
    return true;
  }
}
