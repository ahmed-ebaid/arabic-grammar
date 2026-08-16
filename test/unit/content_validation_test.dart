import 'dart:convert';
import 'dart:io';

import 'package:arabic_grammar/core/content/content_decoder.dart';
import 'package:arabic_grammar/core/content/content_repository.dart';
import 'package:arabic_grammar/core/content/content_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('content decoding and validation', () {
    test('loads the bilingual sample lesson', () {
      final catalog = ContentDecoder.decode(_sampleSource());
      final issues = ContentValidator.validate(catalog);

      expect(issues, isEmpty);
      expect(catalog.lessons, hasLength(3));
      expect(catalog.lessons.first.title.en, 'Why endings change');
      expect(catalog.lessons.first.title.ar, 'لماذا تتغيَّر أواخر الكلمات؟');
      expect(
        catalog.lessons.first.sections.last.examples.single.tokens,
        hasLength(2),
      );
    });

    test('rejects the draft from a release catalog', () {
      final catalog = ContentDecoder.decode(_sampleSource());
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

    test('requires reviewer metadata for approved lessons', () {
      final json = _sampleJson();
      final review = _lesson(json)['review'] as Map<String, Object?>;
      review['status'] = 'approved';

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
    final catalog = await const ContentRepository().load();

    expect(catalog.schemaVersion, 1);
    expect(catalog.lessons, isEmpty);
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
