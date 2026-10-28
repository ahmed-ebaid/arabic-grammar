import 'dart:io';

import 'package:arabic_grammar/core/content/content_decoder.dart';
import 'package:arabic_grammar/core/models/content_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalog = ContentDecoder.decode(
    File('content/drafts/lesson_01.json').readAsStringSync(),
  );
  Lesson lesson(int number) => catalog.lessons[number - 1];

  test('token display does not repeat letters already in an ending', () {
    const cases = [
      ('الطالب', 'ُ', 'الطالبُ'),
      ('الطالبان', 'َانِ', 'الطالبَانِ'),
      ('مجتهدان', 'َانِ', 'مجتهدَانِ'),
      ('المعلمون', 'ُونَ', 'المعلمُونَ'),
      ('معلموها', 'ُو', 'معلمُوها'),
      ('زاروا', 'وا', 'زاروا'),
      ('موسى', 'ى', 'موسى'),
      ('كتابا', 'ًا', 'كتابًا'),
      ('كتاب', 'ًا', 'كتابًا'),
      ('إن', 'َّ', 'إنَّ'),
    ];
    for (final (text, ending, expected) in cases) {
      final token = GrammarToken(
        text: text,
        start: 0,
        end: text.length,
        role: const LocalizedText(en: 'Topic', ar: 'مبتدأ'),
        grammarState: GrammarState.raf,
        grammaticalSign: const LocalizedText(en: 'Damma', ar: 'الضمة'),
        ending: ending,
        reason: const LocalizedText(en: 'Example', ar: 'مثال'),
      );
      expect(token.displayText, expected, reason: '$text + $ending');
    }
  });

  test(
    'every analysis token preserves its original letters when displayed',
    () {
      final marks = RegExp(r'[\u064B-\u065F\u0670]');
      for (final item in catalog.lessons) {
        for (final section in item.sections) {
          for (final example in section.examples) {
            for (final token in example.tokens) {
              expect(
                token.displayText.replaceAll(marks, ''),
                token.text,
                reason: '${item.id}: ${token.text} + ${token.ending}',
              );
            }
          }
        }
      }
    },
  );

  test('indefiniteness question tests acceptance of the article', () {
    final exercise = lesson(8).repeatExercises[2];
    expect(exercise.prompt.ar, contains('تنكير'));
    expect(
      exercise.options.singleWhere((o) => o.isCorrect).label.ar,
      'أنها تقبل «الـ»',
    );
    expect(
      exercise.options.singleWhere((o) => o.isCorrect).feedback.ar,
      contains('المؤثرة في التعريف'),
    );
  });

  test('article notation omits hamza in prose but preserves quoted verses', () {
    expect(lesson(8).objectives.first.ar, contains('«الـ»'));
    expect(lesson(12).objectives[1].ar, contains('«الـ»'));
    expect(lesson(53).sections.first.body.ar, contains('«ال»'));
    expect(lesson(56).sections.first.body.ar, contains('«ال»'));
    expect(
      lesson(56).sections[1].examples.single.unvocalized,
      'نكرة قابل أل مؤثرا أو واقع موقع ما قد ذكرا',
    );
    expect(lesson(53).sections[1].examples.single.tokens[3].text, 'أل');
  });

  test('dual formation is distinct from its actual case sign', () {
    final tokens = lesson(10).sections[1].examples.single.tokens;
    expect(tokens.map((t) => t.grammaticalSign.ar), everyElement('الألف'));
    expect(tokens.map((t) => t.grammaticalSign.en), everyElement('Alif'));
    expect(tokens.map((t) => t.displayText), ['الطالبَانِ', 'مجتهدَانِ']);
    expect(lesson(10).sections.first.body.ar, contains('ينصب ويجر بالياء'));
    for (final exercise in [
      lesson(10).exercises[2],
      lesson(10).repeatExercises[2],
    ]) {
      final answer = exercise.options.singleWhere((o) => o.isCorrect);
      expect(answer.label.ar, startsWith('المُهَنْدِس'));
      expect(answer.label.en, answer.label.ar);
      expect(answer.feedback.ar, contains('ينصب بالياء'));
      expect(exercise.options.map((o) => o.label.ar).toSet(), hasLength(3));
    }
    expect(
      lesson(10).repeatExercises.last.prompt.ar,
      contains('العامل مجتهدات'),
    );
    expect(
      lesson(10).repeatExercises.last.options.first.feedback.ar,
      contains('مرفوع بالضمة'),
    );
  });

  test('semantic idafa is qualified rather than overgeneralized', () {
    final addition = lesson(12);
    expect(addition.objectives[1].ar, contains('الإضافة المعنوية'));
    expect(addition.objectives[1].en, contains('semantic idafa'));
    final token = addition.sections[1].examples.single.tokens.first;
    expect(token.role.ar, 'مبتدأ وهو مضاف');
    expect(token.grammaticalSign.ar, contains('بلا تنوين'));
    expect(addition.sections.first.body.ar, contains('الإضافة اللفظية'));
  });

  test('demonstrative and substitute have separate grammatical roles', () {
    final demonstratives = lesson(13);
    final tokens = demonstratives.sections[1].examples.single.tokens;
    expect(tokens.first.role.ar, contains('في محل رفع مبتدأ'));
    expect(tokens[1].role.ar, 'بدل');
    expect(tokens[1].role.en, 'Substitute (badal)');
    for (final bank in [
      demonstratives.exercises,
      demonstratives.repeatExercises,
    ]) {
      for (final exercise in bank.skip(2)) {
        final answer = exercise.options.singleWhere((o) => o.isCorrect);
        expect(answer.feedback.ar, contains('بدل مرفوع'));
        expect(answer.feedback.en, contains('substitute in raf'));
      }
    }
  });

  test('noun before verb is a topic, not the verbal subject', () {
    for (final number in [16, 47]) {
      final examples = lesson(
        number,
      ).sections.expand((section) => section.examples);
      final token = examples.first.tokens.first;
      expect(token.role.ar, 'مبتدأ');
      expect(token.role.en, 'Topic (mubtada)');
      expect(token.reason.ar, contains('الجملة الفعلية'));
    }
    final weakVerb = lesson(47).sections[1].examples[1].tokens.last;
    expect(weakVerb.text, 'الولد');
    expect(weakVerb.role.ar, 'فاعل');
  });

  test('number example has a delayed topic and distinct case options', () {
    final numbers = lesson(32);
    final token = numbers.sections[1].examples.single.tokens.first;
    expect(token.role.ar, contains('مبتدأ مؤخر'));
    expect(token.reason.ar, contains('في الصف'));
    for (final bank in [numbers.exercises, numbers.repeatExercises]) {
      final exercise = bank.last;
      expect(exercise.options.map((o) => o.label.ar).toSet(), hasLength(3));
      expect(exercise.options[1].label.ar, endsWith('ٌ'));
      expect(exercise.options[1].feedback.ar, contains('لا مرفوع'));
    }
  });

  test(
    'Alfiyya adjective and pre-verbal topic analyses agree with answers',
    () {
      expect(
        lesson(52).exercises[1].options.first.feedback.ar,
        contains('نعت مرفوع'),
      );
      expect(
        lesson(52).exercises[1].options.first.feedback.en,
        contains('adjective'),
      );
      final topic = lesson(58).sections[1].examples.first.tokens.last;
      expect(topic.text, 'تمييز');
      expect(topic.role.ar, 'مبتدأ مؤخر');
      final exercise = lesson(58).exercises[1];
      expect(exercise.prompt.ar, contains('المبتدأ'));
      expect(exercise.prompt.en, contains('topic'));
      expect(exercise.options.first.label.ar, 'تمييز');
      expect(exercise.options.first.feedback.en, contains('topic'));
    },
  );

  test('newer imperative and basic triliteral material is preserved', () {
    expect(lesson(16).title.en, contains('imperative'));
    expect(lesson(16).sections.any((s) => s.title.ar == 'فعل الأمر'), isTrue);
    expect(lesson(23).sections.first.body.ar, contains('فَعَلَ'));
    expect(lesson(23).sections.first.body.ar, contains('فَعِلَ'));
    expect(lesson(23).sections.first.body.ar, contains('فَعُلَ'));
    for (final number in [16, 23]) {
      expect(
        lesson(number).repeatExercises,
        hasLength(lesson(number).exercises.length),
      );
    }
  });

  test('clarification passages have not imported incomplete reviewer text', () {
    expect(
      lesson(14).sections.first.body.ar,
      isNot(contains('الاسم أو الفعل')),
    );
    expect(lesson(15).exercises[2].prompt.ar, contains('معلموها'));
    expect(
      lesson(40).exercises.first.options[1].feedback.ar,
      isNot(contains('يرفع المبتدأ وينصب الخبر')),
    );
    expect(lesson(49).objectives.first.ar, isNot(contains('لأنه لا يوقف')));
    final article = lesson(53).sections[1].examples.single.tokens[3];
    expect(article.role.ar, startsWith('اسم (يسمي'));
    expect(article.role.ar, isNot(contains('حرف تعريف')));
  });
}
