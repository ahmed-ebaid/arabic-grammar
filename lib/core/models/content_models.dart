enum LessonSectionType { introduction, workedExample, ruleSummary, checkpoint }

enum GrammarState { raf, nasb, jarr, jazm, indeclinable }

enum ExerciseType {
  chooseEnding,
  identifyRole,
  identifyState,
  matchRule,
  addTashkeel,
}

enum SourceLicenseStatus {
  publicDomain,
  licensed,
  conceptualReference,
  original,
}

enum ReviewStatus { draft, pendingReview, approved, rejected }

class LocalizedText {
  const LocalizedText({required this.en, required this.ar});

  factory LocalizedText.fromJson(Object? value, String path) {
    final json = JsonValue.object(value, path);
    JsonValue.expectKeys(json, const {'en', 'ar'}, path);
    return LocalizedText(
      en: JsonValue.requiredString(json, 'en', path),
      ar: JsonValue.requiredString(json, 'ar', path),
    );
  }

  final String en;
  final String ar;

  String forLanguage(String languageCode) => languageCode == 'ar' ? ar : en;
}

class ContentCatalog {
  const ContentCatalog({
    required this.schemaVersion,
    required this.contentVersion,
    required this.lessons,
  });

  factory ContentCatalog.fromJson(Object? value) {
    const path = r'$';
    final json = JsonValue.object(value, path);
    JsonValue.expectKeys(json, const {
      'schemaVersion',
      'contentVersion',
      'lessons',
    }, path);
    return ContentCatalog(
      schemaVersion: JsonValue.requiredInt(json, 'schemaVersion', path),
      contentVersion: JsonValue.requiredString(json, 'contentVersion', path),
      lessons: JsonValue.objectList(json, 'lessons', path).indexed
          .map(
            (entry) => Lesson.fromJson(
              entry.$2,
              r'$.lessons['
              '${entry.$1}]',
            ),
          )
          .toList(growable: false),
    );
  }

  final int schemaVersion;
  final String contentVersion;
  final List<Lesson> lessons;
}

class Lesson {
  const Lesson({
    required this.id,
    required this.order,
    required this.title,
    required this.objectives,
    required this.prerequisites,
    required this.estimatedMinutes,
    required this.sections,
    required this.exercises,
    required this.repeatExercises,
    required this.sources,
    required this.review,
  });

  factory Lesson.fromJson(Map<String, Object?> json, String path) {
    JsonValue.expectKeys(json, const {
      'id',
      'order',
      'title',
      'objectives',
      'prerequisites',
      'estimatedMinutes',
      'sections',
      'exercises',
      'repeatExercises',
      'sources',
      'review',
    }, path);
    return Lesson(
      id: JsonValue.requiredString(json, 'id', path),
      order: JsonValue.requiredInt(json, 'order', path),
      title: LocalizedText.fromJson(json['title'], '$path.title'),
      objectives: JsonValue.objectList(json, 'objectives', path).indexed
          .map(
            (entry) => LocalizedText.fromJson(
              entry.$2,
              '$path.objectives[${entry.$1}]',
            ),
          )
          .toList(growable: false),
      prerequisites: JsonValue.stringList(json, 'prerequisites', path),
      estimatedMinutes: JsonValue.requiredInt(json, 'estimatedMinutes', path),
      sections: JsonValue.objectList(json, 'sections', path).indexed
          .map(
            (entry) =>
                LessonSection.fromJson(entry.$2, '$path.sections[${entry.$1}]'),
          )
          .toList(growable: false),
      exercises: JsonValue.objectList(json, 'exercises', path).indexed
          .map(
            (entry) =>
                Exercise.fromJson(entry.$2, '$path.exercises[${entry.$1}]'),
          )
          .toList(growable: false),
      repeatExercises: json.containsKey('repeatExercises')
          ? JsonValue.objectList(json, 'repeatExercises', path).indexed
                .map(
                  (entry) => Exercise.fromJson(
                    entry.$2,
                    '$path.repeatExercises[${entry.$1}]',
                  ),
                )
                .toList(growable: false)
          : const [],
      sources: JsonValue.objectList(json, 'sources', path).indexed
          .map(
            (entry) =>
                ContentSource.fromJson(entry.$2, '$path.sources[${entry.$1}]'),
          )
          .toList(growable: false),
      review: ContentReview.fromJson(
        JsonValue.object(json['review'], '$path.review'),
        '$path.review',
      ),
    );
  }

  final String id;
  final int order;
  final LocalizedText title;
  final List<LocalizedText> objectives;
  final List<String> prerequisites;
  final int estimatedMinutes;
  final List<LessonSection> sections;
  final List<Exercise> exercises;
  final List<Exercise> repeatExercises;
  final List<ContentSource> sources;
  final ContentReview review;
}

class LessonSection {
  const LessonSection({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.examples,
  });

  factory LessonSection.fromJson(Map<String, Object?> json, String path) {
    JsonValue.expectKeys(json, const {
      'id',
      'type',
      'title',
      'body',
      'examples',
    }, path);
    return LessonSection(
      id: JsonValue.requiredString(json, 'id', path),
      type: JsonValue.enumValue(json, 'type', path, LessonSectionType.values),
      title: LocalizedText.fromJson(json['title'], '$path.title'),
      body: LocalizedText.fromJson(json['body'], '$path.body'),
      examples: JsonValue.objectList(json, 'examples', path).indexed
          .map(
            (entry) => GrammarExample.fromJson(
              entry.$2,
              '$path.examples[${entry.$1}]',
            ),
          )
          .toList(growable: false),
    );
  }

  final String id;
  final LessonSectionType type;
  final LocalizedText title;
  final LocalizedText body;
  final List<GrammarExample> examples;
}

class GrammarExample {
  const GrammarExample({
    required this.id,
    required this.vocalized,
    required this.unvocalized,
    required this.tokens,
  });

  factory GrammarExample.fromJson(Map<String, Object?> json, String path) {
    JsonValue.expectKeys(json, const {
      'id',
      'vocalized',
      'unvocalized',
      'tokens',
    }, path);
    return GrammarExample(
      id: JsonValue.requiredString(json, 'id', path),
      vocalized: JsonValue.requiredString(json, 'vocalized', path),
      unvocalized: JsonValue.requiredString(json, 'unvocalized', path),
      tokens: JsonValue.objectList(json, 'tokens', path).indexed
          .map(
            (entry) =>
                GrammarToken.fromJson(entry.$2, '$path.tokens[${entry.$1}]'),
          )
          .toList(growable: false),
    );
  }

  final String id;
  final String vocalized;
  final String unvocalized;
  final List<GrammarToken> tokens;
}

class GrammarToken {
  const GrammarToken({
    required this.text,
    required this.start,
    required this.end,
    required this.role,
    required this.grammarState,
    required this.grammaticalSign,
    required this.ending,
    required this.reason,
  });

  factory GrammarToken.fromJson(Map<String, Object?> json, String path) {
    JsonValue.expectKeys(json, const {
      'text',
      'start',
      'end',
      'role',
      'grammarState',
      'grammaticalSign',
      'ending',
      'reason',
    }, path);
    return GrammarToken(
      text: JsonValue.requiredString(json, 'text', path),
      start: JsonValue.requiredInt(json, 'start', path),
      end: JsonValue.requiredInt(json, 'end', path),
      role: LocalizedText.fromJson(json['role'], '$path.role'),
      grammarState: JsonValue.enumValue(
        json,
        'grammarState',
        path,
        GrammarState.values,
      ),
      grammaticalSign: LocalizedText.fromJson(
        json['grammaticalSign'],
        '$path.grammaticalSign',
      ),
      ending: JsonValue.requiredString(json, 'ending', path),
      reason: LocalizedText.fromJson(json['reason'], '$path.reason'),
    );
  }

  final String text;
  final int start;
  final int end;
  final LocalizedText role;
  final GrammarState grammarState;
  final LocalizedText grammaticalSign;
  final String ending;
  final LocalizedText reason;
}

class Exercise {
  const Exercise({
    required this.id,
    required this.type,
    required this.prompt,
    required this.options,
  });

  factory Exercise.fromJson(Map<String, Object?> json, String path) {
    JsonValue.expectKeys(json, const {'id', 'type', 'prompt', 'options'}, path);
    return Exercise(
      id: JsonValue.requiredString(json, 'id', path),
      type: JsonValue.enumValue(json, 'type', path, ExerciseType.values),
      prompt: LocalizedText.fromJson(json['prompt'], '$path.prompt'),
      options: JsonValue.objectList(json, 'options', path).indexed
          .map(
            (entry) =>
                ExerciseOption.fromJson(entry.$2, '$path.options[${entry.$1}]'),
          )
          .toList(growable: false),
    );
  }

  final String id;
  final ExerciseType type;
  final LocalizedText prompt;
  final List<ExerciseOption> options;
}

class ExerciseOption {
  const ExerciseOption({
    required this.id,
    required this.label,
    required this.isCorrect,
    required this.feedback,
  });

  factory ExerciseOption.fromJson(Map<String, Object?> json, String path) {
    JsonValue.expectKeys(json, const {
      'id',
      'label',
      'isCorrect',
      'feedback',
    }, path);
    return ExerciseOption(
      id: JsonValue.requiredString(json, 'id', path),
      label: LocalizedText.fromJson(json['label'], '$path.label'),
      isCorrect: JsonValue.requiredBool(json, 'isCorrect', path),
      feedback: LocalizedText.fromJson(json['feedback'], '$path.feedback'),
    );
  }

  final String id;
  final LocalizedText label;
  final bool isCorrect;
  final LocalizedText feedback;
}

class ContentSource {
  const ContentSource({
    required this.id,
    required this.title,
    required this.author,
    required this.url,
    required this.licenseStatus,
    required this.citation,
  });

  factory ContentSource.fromJson(Map<String, Object?> json, String path) {
    JsonValue.expectKeys(json, const {
      'id',
      'title',
      'author',
      'url',
      'licenseStatus',
      'citation',
    }, path);
    return ContentSource(
      id: JsonValue.requiredString(json, 'id', path),
      title: JsonValue.requiredString(json, 'title', path),
      author: JsonValue.requiredString(json, 'author', path),
      url: JsonValue.optionalString(json, 'url', path),
      licenseStatus: JsonValue.enumValue(
        json,
        'licenseStatus',
        path,
        SourceLicenseStatus.values,
      ),
      citation: JsonValue.requiredString(json, 'citation', path),
    );
  }

  final String id;
  final String title;
  final String author;
  final String? url;
  final SourceLicenseStatus licenseStatus;
  final String citation;
}

class ContentReview {
  const ContentReview({
    required this.status,
    required this.contentVersion,
    required this.reviewer,
    required this.reviewedAt,
    required this.notes,
  });

  factory ContentReview.fromJson(Map<String, Object?> json, String path) {
    JsonValue.expectKeys(json, const {
      'status',
      'contentVersion',
      'reviewer',
      'reviewedAt',
      'notes',
    }, path);
    final reviewedAtValue = JsonValue.optionalString(json, 'reviewedAt', path);
    final reviewedAt = reviewedAtValue == null
        ? null
        : DateTime.tryParse(reviewedAtValue);
    if (reviewedAtValue != null && reviewedAt == null) {
      throw FormatException('$path.reviewedAt must be an ISO-8601 date');
    }
    return ContentReview(
      status: JsonValue.enumValue(json, 'status', path, ReviewStatus.values),
      contentVersion: JsonValue.requiredString(json, 'contentVersion', path),
      reviewer: JsonValue.optionalString(json, 'reviewer', path),
      reviewedAt: reviewedAt,
      notes: JsonValue.requiredString(json, 'notes', path),
    );
  }

  final ReviewStatus status;
  final String contentVersion;
  final String? reviewer;
  final DateTime? reviewedAt;
  final String notes;
}

abstract final class JsonValue {
  static void expectKeys(
    Map<String, Object?> json,
    Set<String> allowed,
    String path,
  ) {
    final unknown = json.keys.where((key) => !allowed.contains(key)).toList();
    if (unknown.isNotEmpty) {
      throw FormatException(
        '$path contains unsupported fields: ${unknown.join(', ')}',
      );
    }
  }

  static Map<String, Object?> object(Object? value, String path) {
    if (value is! Map<String, Object?>) {
      throw FormatException('$path must be a JSON object');
    }
    return value;
  }

  static List<Map<String, Object?>> objectList(
    Map<String, Object?> json,
    String key,
    String path,
  ) {
    final value = json[key];
    if (value is! List<Object?>) {
      throw FormatException('$path.$key must be a JSON array');
    }
    return value.indexed
        .map((entry) => object(entry.$2, '$path.$key[${entry.$1}]'))
        .toList(growable: false);
  }

  static List<String> stringList(
    Map<String, Object?> json,
    String key,
    String path,
  ) {
    final value = json[key];
    if (value is! List<Object?> || value.any((entry) => entry is! String)) {
      throw FormatException('$path.$key must be an array of strings');
    }
    return value.cast<String>().toList(growable: false);
  }

  static String requiredString(
    Map<String, Object?> json,
    String key,
    String path,
  ) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$path.$key must be a non-empty string');
    }
    return value;
  }

  static String? optionalString(
    Map<String, Object?> json,
    String key,
    String path,
  ) {
    final value = json[key];
    if (value == null) {
      return null;
    }
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$path.$key must be null or a non-empty string');
    }
    return value;
  }

  static int requiredInt(Map<String, Object?> json, String key, String path) {
    final value = json[key];
    if (value is! int) {
      throw FormatException('$path.$key must be an integer');
    }
    return value;
  }

  static bool requiredBool(Map<String, Object?> json, String key, String path) {
    final value = json[key];
    if (value is! bool) {
      throw FormatException('$path.$key must be a boolean');
    }
    return value;
  }

  static T enumValue<T extends Enum>(
    Map<String, Object?> json,
    String key,
    String path,
    List<T> values,
  ) {
    final value = requiredString(json, key, path);
    for (final candidate in values) {
      if (candidate.name == value) {
        return candidate;
      }
    }
    final allowed = values.map((entry) => entry.name).join(', ');
    throw FormatException('$path.$key must be one of: $allowed');
  }
}
