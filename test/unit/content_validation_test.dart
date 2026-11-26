import 'dart:convert';
import 'dart:io';

import 'package:arabic_grammar/core/content/content_decoder.dart';
import 'package:arabic_grammar/core/content/content_repository.dart';
import 'package:arabic_grammar/core/content/content_validator.dart';
import 'package:arabic_grammar/core/models/content_models.dart';
import 'package:arabic_grammar/core/models/glossary_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('content decoding and validation', () {
    test('lesson revision changes with content, not review metadata', () {
      final json = _sampleJson();
      final first = _lesson(json);
      final original = Lesson.fromJson(first, r'$.lessons[0]').contentRevision;
      final reordered = Map<String, Object?>.fromEntries(
        first.entries.toList().reversed,
      );
      expect(
        Lesson.fromJson(reordered, r'$.lessons[0]').contentRevision,
        original,
      );
      final review = first['review'] as Map<String, Object?>;
      review['notes'] = 'Reviewed separately';
      expect(Lesson.fromJson(first, r'$.lessons[0]').contentRevision, original);
      final title = first['title'] as Map<String, Object?>;
      title['en'] = 'Updated lesson title';
      expect(
        Lesson.fromJson(first, r'$.lessons[0]').contentRevision,
        isNot(original),
      );
    });

    test('loads the bilingual sample lesson', () {
      final catalog = ContentDecoder.decode(_sampleSource());
      final issues = ContentValidator.validate(catalog);

      expect(issues, isEmpty);
      expect(catalog.contentVersion, '1.0.1');
      expect(catalog.levels, hasLength(7));
      expect(catalog.lessons, hasLength(58));
      expect(catalog.lessons.first.title.en, 'Why endings change');
      expect(catalog.lessons.first.title.ar, 'لماذا تتغيَّر أواخر الكلمات؟');
      expect(
        catalog.lessons.first.sections[1].examples.single.tokens,
        hasLength(2),
      );
      expect(catalog.lessons.first.exercises, hasLength(10));
      expect(catalog.lessons.first.repeatExercises, hasLength(10));
      expect(
        catalog.lessons,
        everyElement(
          isA<Lesson>()
              .having(
                (lesson) => lesson.exercises.length,
                'primary exercise count',
                greaterThanOrEqualTo(4),
              )
              .having(
                (lesson) => lesson.repeatExercises.length,
                'repeat exercise count',
                greaterThanOrEqualTo(4),
              ),
        ),
      );
      for (final lesson in catalog.lessons) {
        expect(lesson.review.status, ReviewStatus.pendingReview);
        expect(lesson.review.reviewer, isNull);
        expect(
          lesson.repeatExercises,
          hasLength(lesson.exercises.length),
          reason: '${lesson.id} must rotate to a complete alternate bank',
        );
      }
      expect(catalog.lessons[6].repeatExercises, hasLength(10));
      expect(catalog.lessons.last.repeatExercises, hasLength(10));
      expect(catalog.levels.map((level) => level.lessonIds.last), [
        'lesson_07',
        'lesson_15',
        'lesson_24',
        'lesson_33',
        'lesson_41',
        'lesson_50',
        'lesson_58',
      ]);
    });

    test('rejects unapproved lessons from a release catalog', () {
      final json = _sampleJson();
      final review = _lesson(json)['review'] as Map<String, Object?>;
      review['status'] = 'pendingReview';
      final catalog = ContentDecoder.decode(jsonEncode(json));
      final issues = ContentValidator.validate(
        catalog,
        requireReleaseApproval: true,
      );

      expect(
        issues.map((issue) => issue.toString()),
        contains(
          contains('review.status: must be approved for a release build'),
        ),
      );
    });

    test('rejects missing bilingual content', () {
      final json = _sampleJson();
      final lesson = _lesson(json);
      (lesson['title'] as Map<String, Object?>).remove('ar');

      expect(
        () => ContentDecoder.decode(jsonEncode(json)),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains(r'$.lessons[0].title.ar'),
          ),
        ),
      );
    });

    test('rejects unknown fields', () {
      final json = _sampleJson();
      _lesson(json)['unexpected'] = true;

      expect(
        () => ContentDecoder.decode(jsonEncode(json)),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('unsupported fields: unexpected'),
          ),
        ),
      );
    });

    test('limits lesson mind maps to two levels below the center', () {
      final json = _sampleJson();
      Map<String, Object?> node(String label, [List<Object?>? children]) => {
        'label': {'en': label, 'ar': label},
        'children': ?children,
      };
      _lesson(json)['mindMap'] = {
        'center': {'en': 'Center', 'ar': 'المركز'},
        'branches': [
          node('A', [
            node('A1', [node('A1a')]),
          ]),
          node('B'),
        ],
      };

      final catalog = ContentDecoder.decode(jsonEncode(json));
      final issues = ContentValidator.validate(catalog);

      expect(catalog.lessons.first.mindMap!.branches, hasLength(2));
      expect(
        issues.map((issue) => issue.path),
        contains(r'$.lessons[0].mindMap.branches[0].children[0].children'),
      );
    });

    test('rejects invalid interactive vowel data', () {
      final json = _sampleJson();
      final exercises = _lesson(json)['exercises'] as List<Object?>;
      final exercise = exercises.last as Map<String, Object?>;
      exercise['targetWord'] = 'كلمتان هنا';
      final options = exercise['options'] as List<Object?>;
      (options.first as Map<String, Object?>)['id'] = 'unknown-mark';
      final issues = ContentValidator.validate(
        ContentDecoder.decode(jsonEncode(json)),
      );
      expect(
        issues.map((issue) => issue.path),
        containsAll([
          r'$.lessons[0].exercises[9].targetWord',
          r'$.lessons[0].exercises[9].options',
        ]),
      );
    });

    test('rejects invalid token spans and exercise answers', () {
      final json = _sampleJson();
      final lesson = _lesson(json);
      final sections = lesson['sections'] as List<Object?>;
      final example =
          ((sections[1] as Map<String, Object?>)['examples'] as List<Object?>)
                  .single
              as Map<String, Object?>;
      final firstToken =
          (example['tokens'] as List<Object?>).first as Map<String, Object?>;
      firstToken['end'] = 5;

      final exercise =
          (lesson['exercises'] as List<Object?>).first as Map<String, Object?>;
      for (final option in exercise['options'] as List<Object?>) {
        (option as Map<String, Object?>)['isCorrect'] = false;
      }

      final issues = ContentValidator.validate(
        ContentDecoder.decode(jsonEncode(json)),
      );
      final messages = issues.map((issue) => issue.message);

      expect(messages, contains(contains('expected "الطال"')));
      expect(messages, contains('must contain exactly one correct option'));
    });

    test('rejects a vocalized token that differs from its example', () {
      final json = _sampleJson();
      final lessons = json['lessons'] as List<Object?>;
      final lesson = lessons[34] as Map<String, Object?>;
      final sections = lesson['sections'] as List<Object?>;
      final example =
          ((sections[1] as Map<String, Object?>)['examples'] as List<Object?>)
                  .single
              as Map<String, Object?>;
      final token =
          (example['tokens'] as List<Object?>).first as Map<String, Object?>;
      token['vocalized'] = 'كَتَبَ';
      final issues = ContentValidator.validate(
        ContentDecoder.decode(jsonEncode(json)),
      );
      expect(
        issues.map((issue) => issue.toString()),
        contains(
          contains('must match token text and appear in the vocalized example'),
        ),
      );
    });

    test('requires reviewer metadata for approved lessons', () {
      final json = _sampleJson();
      final review = _lesson(json)['review'] as Map<String, Object?>;
      review['status'] = 'approved';
      review['reviewer'] = null;
      review['reviewedAt'] = null;

      final issues = ContentValidator.validate(
        ContentDecoder.decode(jsonEncode(json)),
      );

      expect(
        issues.map((issue) => issue.path),
        containsAll([
          r'$.lessons[0].review.reviewer',
          r'$.lessons[0].review.reviewedAt',
        ]),
      );
    });
  });

  test('bundled release catalog contains only releasable content', () async {
    final catalog = await const ContentRepository(
      previewUnreviewed: false,
    ).load();

    expect(catalog.schemaVersion, 1);
    expect(catalog.contentVersion, '1.0.1');
    expect(catalog.levels, hasLength(7));
    expect(catalog.lessons, hasLength(58));
  });

  test('draft question revisions do not replace approved release lessons', () {
    final draft = _sampleJson();
    final release =
        jsonDecode(File('assets/content/catalog.json').readAsStringSync())
            as Map<String, Object?>;
    final releaseLessons = {
      for (final item in release['lessons'] as List<Object?>)
        (item as Map<String, Object?>)['id'] as String: item,
    };
    const revisedIds = {
      'lesson_01',
      'lesson_03',
      'lesson_07',
      'lesson_13',
      'lesson_15',
      'lesson_30',
      'lesson_35',
      'lesson_37',
      'lesson_40',
      'lesson_41',
      'lesson_43',
      'lesson_45',
      'lesson_51',
      'lesson_52',
      'lesson_53',
      'lesson_54',
      'lesson_55',
      'lesson_56',
      'lesson_57',
      'lesson_58',
    };
    for (final item in draft['lessons'] as List<Object?>) {
      final lesson = item as Map<String, Object?>;
      if (!revisedIds.contains(lesson['id'])) continue;
      final bundled = releaseLessons[lesson['id']]!;
      final review = lesson['review'] as Map<String, Object?>;
      final bundledReview = bundled['review'] as Map<String, Object?>;
      expect(review['status'], 'pendingReview', reason: '${lesson['id']}');
      expect(bundledReview['status'], 'approved', reason: '${lesson['id']}');
      expect(
        jsonEncode(bundled),
        isNot(jsonEncode(lesson)),
        reason: '${lesson['id']}',
      );
    }
    expect(revisedIds.every(releaseLessons.containsKey), isTrue);
  });

  test(
    'production and preview contain the confirmed lesson revisions',
    () async {
      final preview = await const ContentRepository(
        previewUnreviewed: true,
      ).load();
      final production = await const ContentRepository(
        previewUnreviewed: false,
      ).load();
      for (final id in ['lesson_01', 'lesson_13']) {
        final draft = preview.lessons.singleWhere((lesson) => lesson.id == id);
        final bundled = production.lessons.singleWhere(
          (lesson) => lesson.id == id,
        );
        expect(bundled.review.status, ReviewStatus.approved);
        expect(bundled.review.contentVersion, '1.0.2');
        expect(bundled.sections.first.body.ar, draft.sections.first.body.ar);
        expect(bundled.sections.first.body.en, draft.sections.first.body.en);
        expect(bundled.sections.first.body.ar, contains('جاءَ هذا'));
        expect(bundled.sections.first.body.en, contains('جاءَ هذا'));
      }
      expect(
        ContentValidator.validate(production, requireReleaseApproval: true),
        isEmpty,
      );
    },
  );

  test(
    'teacher-approved definiteness revision is included in release',
    () async {
      final preview = await const ContentRepository(
        previewUnreviewed: true,
      ).load();
      final production = await const ContentRepository(
        previewUnreviewed: false,
      ).load();
      final draft = preview.lessons.singleWhere((l) => l.id == 'lesson_08');
      final bundled = production.lessons.singleWhere(
        (l) => l.id == 'lesson_08',
      );

      expect(draft.review.contentVersion, '1.0.2');
      expect(draft.review.status, ReviewStatus.pendingReview);
      expect(bundled.review.status, ReviewStatus.approved);
      expect(bundled.review.contentVersion, '1.0.1');
      expect(bundled.review.reviewer, 'د. شريف محمد الصادق');
      expect(draft.sections.first.body.ar, contains('رُبَّ أَخٍ'));
      expect(draft.sections.first.body.en, contains('رُبَّ أَخٍ'));
      expect(bundled.sections.first.body.ar, draft.sections.first.body.ar);
      expect(bundled.sections.first.body.en, draft.sections.first.body.en);
      expect(
        ContentValidator.validate(
          preview,
          requireReleaseApproval: true,
        ).where((issue) => issue.path.startsWith(r'$.lessons[7].')),
        isNotEmpty,
      );
    },
  );

  test('loads the bilingual grammar glossary', () {
    final source = File('assets/content/glossary.json').readAsStringSync();
    final glossary = GlossaryCatalog.fromJson(jsonDecode(source));
    final lessonIds = ContentDecoder.decode(
      _sampleSource(),
    ).lessons.map((lesson) => lesson.id).toSet();

    expect(glossary.schemaVersion, 1);
    expect(glossary.terms, hasLength(57));
    expect(
      glossary.terms.map((term) => term.id).toSet(),
      hasLength(glossary.terms.length),
    );
    expect(
      glossary.terms.every(
        (term) =>
            term.term.en.isNotEmpty &&
            term.term.ar.isNotEmpty &&
            term.definition.en.isNotEmpty &&
            term.definition.ar.isNotEmpty &&
            term.example.en.isNotEmpty &&
            term.example.ar.isNotEmpty,
      ),
      isTrue,
    );
    final mabni = glossary.terms.singleWhere((term) => term.id == 'mabni');
    expect(mabni.example.ar, contains('جاءَ هذا'));
    expect(mabni.example.ar, contains('رأيتُ هذا'));
    expect(mabni.example.ar, contains('سلّمتُ على هذا'));
    expect(
      glossary.terms.expand((term) => term.lessonIds).every(lessonIds.contains),
      isTrue,
    );
  });

  test('draft glossary covers all lessons and distinct plural forms', () {
    final glossary = GlossaryCatalog.fromJson(
      jsonDecode(
        File('content/drafts/glossary/catalog.json').readAsStringSync(),
      ),
    );
    final lessons = ContentDecoder.decode(_sampleSource()).lessons;
    final ids = glossary.terms.map((term) => term.id).toSet();
    expect(ids, hasLength(glossary.terms.length));
    expect(
      glossary.terms.every(
        (term) =>
            term.term.en.isNotEmpty &&
            term.term.ar.isNotEmpty &&
            term.definition.en.isNotEmpty &&
            term.definition.ar.isNotEmpty &&
            term.example.en.isNotEmpty &&
            term.example.ar.isNotEmpty &&
            term.lessonIds.isNotEmpty,
      ),
      isTrue,
    );
    for (final id in [
      'jam-mudhakkar-salim',
      'jam-muannath-salim',
      'jam-taksir',
    ]) {
      final plural = glossary.terms.singleWhere((term) => term.id == id);
      expect(plural.lessonIds, contains('lesson_10'));
      expect(plural.definition.ar, isNotEmpty);
      expect(plural.definition.en, isNotEmpty);
      expect(plural.example.ar, isNotEmpty);
      expect(plural.example.en, isNotEmpty);
    }
    final referenced = glossary.terms.expand((term) => term.lessonIds).toSet();
    expect(referenced, lessons.map((lesson) => lesson.id).toSet());
  });
}

String _sampleSource() {
  return File('content/drafts/lesson_01.json').readAsStringSync();
}

Map<String, Object?> _sampleJson() {
  return jsonDecode(_sampleSource()) as Map<String, Object?>;
}

Map<String, Object?> _lesson(Map<String, Object?> catalog) {
  return (catalog['lessons'] as List<Object?>).first as Map<String, Object?>;
}
