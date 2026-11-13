import 'dart:io';

import 'package:arabic_grammar/core/content/content_decoder.dart';
import 'package:arabic_grammar/core/models/content_models.dart';
import 'package:arabic_grammar/features/lessons/alfiyya_readings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalog = ContentDecoder.decode(
    File('content/drafts/lesson_01.json').readAsStringSync(),
  );
  Lesson lesson(int number) => catalog.lessons[number - 1];

  test('English prompts follow revised Arabic examples without extra cues', () {
    Exercise exercise(String id) => catalog.lessons
        .expand((lesson) => [...lesson.exercises, ...lesson.repeatExercises])
        .singleWhere((exercise) => exercise.id == id);
    final pauseQuestion = exercise('lesson-48-state-02').prompt;
    expect(pauseQuestion.en, contains('طالب مجتهد في الفصل'));
    expect(pauseQuestion.ar, contains('طالب مجتهد في الفصل'));
    final subjectQuestion = exercise('lesson-39-repeat-read-04').prompt;
    expect(subjectQuestion.en, contains('كلمت سلمى ليلى'));
    expect(subjectQuestion.ar, contains('كلمت سلمى ليلى'));
    final restrictionQuestion = exercise('lesson-49-repeat-state-01').prompt;
    expect(restrictionQuestion.en, contains('إنما العدل أساس الملك'));
    expect(restrictionQuestion.ar, contains('إنما العدل أساس الملك'));
    expect(exercise('lesson-21-recognize-01').prompt.en, isNot(contains('أن')));
    expect(exercise('lesson-24-read-03').prompt.en, isNot(contains('تتأخروا')));
    expect(
      exercise('lesson-24-repeat-read-03').prompt.en,
      isNot(contains('تلعبوا')),
    );
  });

  test('Alfiyya readings cover each level-ending lesson', () {
    expect(
      alfiyyaReadings.keys.toSet(),
      catalog.levels.map((level) => level.lessonIds.last).toSet(),
    );
    for (final entry in alfiyyaReadings.entries) {
      final readings = entry.value;
      final endLesson = catalog.lessons.singleWhere(
        (lesson) => lesson.id == entry.key,
      );
      expect(readings.length, greaterThanOrEqualTo(5));
      for (final reading in readings) {
        expect(reading.verse, contains('\n'));
        final relatedLesson = catalog.lessons.singleWhere(
          (lesson) => lesson.id == reading.lessonId,
        );
        expect(relatedLesson.order, lessThanOrEqualTo(endLesson.order));
        expect(reading.topic.ar, isNotEmpty);
        expect(reading.topic.en, isNotEmpty);
        expect(reading.explanation.ar, isNotEmpty);
        expect(reading.explanation.en, isNotEmpty);
        expect(reading.example.ar, isNotEmpty);
        expect(reading.example.en, isNotEmpty);
        if (reading.details case final details?) {
          expect(details.ar, isNotEmpty);
          expect(details.en, isNotEmpty);
        }
      }
    }
  });

  test(
    'expanded Alfiyya selections retain context and correct lesson mapping',
    () {
      AlfiyyaReading reading(String ending, String topic) =>
          alfiyyaReadings[ending]!.singleWhere(
            (reading) => reading.topic.ar == topic,
          );

      expect(
        reading('lesson_15', 'أسماء الإشارة').verse,
        contains('بذي وذه تي تا على الأنثى اقتصر'),
      );
      expect(
        reading('lesson_15', 'بناء الضمائر').verse,
        contains('وكل مضمر له البنا يجب'),
      );
      expect(
        reading('lesson_07', 'حروف الجر').details!.ar,
        contains('لغات عربية مخصوصة'),
      );
      expect(
        reading('lesson_24', 'الفعل المتعدي').details!.ar,
        contains('سياق «أعلم وأرى»'),
      );
      expect(
        reading('lesson_33', 'الاستثناء بإلّا').verse,
        contains('إتباع ما اتصل'),
      );
      expect(reading('lesson_41', 'نائب الفاعل').lessonId, 'lesson_35');
      expect(
        reading('lesson_41', 'اسم الفاعل واسم المفعول').lessonId,
        'lesson_36',
      );
      expect(
        reading('lesson_50', 'الأفعال المعتلة').verse,
        isNot(contains('المصطفى')),
      );
      expect(
        reading('lesson_50', 'الوصل والوقف').details!.ar,
        contains('التاء المربوطة'),
      );
      expect(
        reading('lesson_50', 'حذف المبتدأ أو الخبر').details!.ar,
        contains('خبر الكون العام'),
      );
    },
  );

  test('inflection and fixed endings are explained in both lessons', () {
    final first = lesson(1);
    final demonstratives = lesson(13);
    final intro = first.sections.first.body;
    for (final example in ['الطالبُ', 'الطالبَ', 'الطالبِ']) {
      expect(intro.ar, contains(example));
      expect(intro.en, contains(example));
    }
    for (final body in [intro, demonstratives.sections.first.body]) {
      for (final example in ['جاءَ هذا', 'رأيتُ هذا', 'سلّمتُ على هذا']) {
        expect(body.ar, contains(example));
        expect(body.en, contains(example));
      }
      for (final position in ['رفع', 'نصب', 'جر']) {
        expect(body.ar, contains('محل $position'));
      }
      for (final position in ['raf', 'nasb', 'jarr']) {
        expect(body.en, contains(position));
      }
    }
    for (final item in [first, demonstratives]) {
      expect(item.review.status, ReviewStatus.approved);
      expect(item.review.reviewer, 'د. شريف محمد الصادق');
      expect(item.review.reviewedAt, isNotNull);
      expect(item.sections, hasLength(2));
    }
  });

  test('mastery prompts do not reveal the case of عدد in the question', () {
    final project = lesson(41);
    final prompts = [...project.exercises, ...project.repeatExercises].where(
      (exercise) =>
          exercise.id == 'lesson-41-state-02' ||
          exercise.id == 'lesson-41-repeat-state-02',
    );
    expect(prompts, hasLength(2));
    for (final exercise in prompts) {
      expect(exercise.prompt.ar, contains('«عدد»'));
      expect(exercise.prompt.ar, isNot(contains('عددَ')));
      expect(exercise.prompt.en, contains('عدد in'));
      expect(
        exercise.options.singleWhere((option) => option.isCorrect).id,
        'nasb',
      );
    }
  });

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

  test('passive analysis preserves the vowels within the verb', () {
    for (final path in [
      'content/drafts/lesson_01.json',
      'assets/content/catalog.json',
    ]) {
      final source = ContentDecoder.decode(File(path).readAsStringSync());
      final example = source.lessons
          .singleWhere((lesson) => lesson.id == 'lesson_35')
          .sections
          .singleWhere((section) => section.id == 'report-was-written')
          .examples
          .single;
      expect(example.tokens.first.displayText, 'كُتِبَ');
      expect(example.tokens.last.displayText, 'أمسِ');
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

  test('case and ending prompts do not reveal answers with vowel marks', () {
    final marks = RegExp(r'[\u064B-\u065F\u0670]');
    for (final item in catalog.lessons) {
      for (final exercise in [...item.exercises, ...item.repeatExercises]) {
        if (exercise.type != ExerciseType.identifyState &&
            exercise.type != ExerciseType.chooseEnding) {
          continue;
        }
        expect(
          exercise.prompt.ar,
          isNot(matches(marks)),
          reason: '${item.id}/${exercise.id} Arabic prompt',
        );
        expect(
          exercise.prompt.en,
          isNot(matches(marks)),
          reason: '${item.id}/${exercise.id} English prompt',
        );
      }
    }

    final predicate = alfiyyaReadings['lesson_41']!.singleWhere(
      (reading) => reading.topic.ar == 'الخبر وأنواعه',
    );
    expect(
      predicate.verse,
      'والخبر الجزء المتم الفائدة\n'
      'كالله بر والأيادي شاهدة\n'
      'ومفردا يأتي ويأتي جملة\n'
      'حاوية معنى الذي سيقت له',
    );
    expect(
      alfiyyaReadings['lesson_33']!
          .singleWhere((reading) => reading.topic.ar == 'العدد والمعدود')
          .verse,
      'ثلاثة بالتاء قل للعشرة\n'
      'في عد ما آحاده مذكرة\n'
      'في الضد جرد والمميز اجرر\n'
      'جمعا بلفظ قلة في الأكثر',
    );
    expect(
      alfiyyaReadings['lesson_24']!
          .singleWhere((reading) => reading.topic.ar == 'الفعل المتعدي')
          .verse,
      'علامة الفعل المعدى أن تصل\n'
      'هاء ضمير غير مصدر به نحو عمل',
    );
  });

  test('case prompts do not reveal answers through written case endings', () {
    const formerCueByExercise = {
      'lesson-10-state-02': ['الطالبان', 'مجتهدان'],
      'lesson-10-repeat-state-02': ['البنتان', 'مجتهدتان'],
      'lesson-19-state-03': ['كتابا'],
      'lesson-19-repeat-state-03': ['قلما'],
      'lesson-25-state-02': ['باردا'],
      'lesson-25-repeat-state-02': ['ناجحا'],
      'lesson-30-state-02': ['ضاحكا'],
      'lesson-30-repeat-state-02': ['مسرعا'],
      'lesson-31-state-02': ['واحدا'],
      'lesson-31-repeat-state-02': ['اثنين'],
      'lesson-33-state-01': ['باردا'],
      'lesson-33-repeat-state-01': ['معتدلا'],
      'lesson-41-repeat-state-01': ['فرعا'],
      'lesson-42-state-03': ['كتابا'],
      'lesson-42-repeat-state-03': ['ما الحالة الإعرابية لكلمة «رسالة»؟'],
      'lesson-42-rule-01': ['كِتَابًا'],
      'lesson-42-repeat-rule-01': ['رِسَالَةً'],
    };
    final exercises = [
      for (final item in catalog.lessons) ...item.exercises,
      for (final item in catalog.lessons) ...item.repeatExercises,
    ];

    for (final exercise in exercises) {
      final formerCues = formerCueByExercise[exercise.id];
      if (formerCues == null) continue;
      for (final cue in formerCues) {
        expect(
          exercise.prompt.ar,
          isNot(contains(cue)),
          reason: '${exercise.id} Arabic prompt',
        );
        expect(
          exercise.prompt.en,
          isNot(contains(cue)),
          reason: '${exercise.id} English prompt',
        );
      }
    }

    for (final id in ['lesson-42-rule-01', 'lesson-42-repeat-rule-01']) {
      final exercise = exercises.singleWhere((item) => item.id == id);
      final answer = exercise.options.singleWhere((option) => option.isCorrect);
      expect(answer.label.ar, contains('مفعول به مقدّم'));
      expect(answer.label.ar, isNot(contains('حركة')));
    }
  });

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
    final bookTokens = lesson(19).sections
        .firstWhere((section) => section.id == 'teacher-gave-book')
        .examples
        .single
        .tokens;
    expect(bookTokens[1].grammaticalSign.ar, contains('«الـ» التعريف'));
    expect(bookTokens[2].grammaticalSign.ar, contains('«الـ» التعريف'));
    expect(bookTokens[1].grammaticalSign.ar, isNot(contains('«أل»')));
    expect(lesson(52).objectives.first.ar, contains('«الـ» التعريف'));
    expect(
      lesson(55).objectives[1].ar,
      'أن تتعرّف على الاختبار الثاني في البيت: وقوع الكلمة موقع ما يقبل «ال» مؤثرة.',
    );
    final indefiniteExercise = lesson(
      55,
    ).exercises.firstWhere((exercise) => exercise.id == 'lesson-55-rule-03');
    expect(
      indefiniteExercise.options.first.label.ar,
      contains('«الـ» المؤثرة'),
    );
    final idafaToken = lesson(57).sections[1].examples.first.tokens.firstWhere(
      (token) => token.text == 'اسم',
    );
    expect(idafaToken.role.ar, contains('«الـ» التعريف'));
    expect(
      lesson(52).sections[1].body.ar,
      contains('«بِالْجَرِّ وَالتَّنْوِينِ وَالنِّدَا وَأَلْ'),
    );
    expect(
      lesson(55).sections[1].examples.single.unvocalized,
      'نكرة قابل أل مؤثرا أو واقع موقع ما قد ذكرا',
    );
    expect(lesson(52).sections[1].examples.single.tokens[3].text, 'أل');
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
    expect(addition.objectives[1].ar, contains('إلا في بعض المسائل'));
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
    for (final number in [16, 46]) {
      final examples = lesson(
        number,
      ).sections.expand((section) => section.examples);
      final token = examples.first.tokens.first;
      expect(token.role.ar, 'مبتدأ');
      expect(token.role.en, 'Topic (mubtada)');
      expect(token.reason.ar, contains('الجملة الفعلية'));
    }
    final weakVerb = lesson(46).sections[1].examples[1].tokens.last;
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
        lesson(51).exercises[1].options.first.feedback.ar,
        contains('نعت مرفوع'),
      );
      expect(
        lesson(51).exercises[1].options.first.feedback.en,
        contains('adjective'),
      );
      final topic = lesson(57).sections[1].examples.first.tokens.last;
      expect(topic.text, 'تمييز');
      expect(topic.role.ar, 'مبتدأ مؤخر');
      final exercise = lesson(57).exercises[1];
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

  test('grammar explanations distinguish rules from exceptions', () {
    final pronouns = lesson(14).sections.first.body;
    expect(pronouns.ar, contains('الضمير المنفصل ظاهر'));
    expect(pronouns.ar, isNot(contains('مبتدأ أو فاعلًا مستترًا')));

    final derived = lesson(23).sections[1].body;
    for (final term in ['التعدية', 'التكثير', 'المطاوعة', 'السياق']) {
      expect(derived.ar, contains(term));
    }
    expect(derived.en, contains('depend on the verb and context'));

    final relatives = lesson(27).sections.first.body;
    for (final form in ['اللذان', 'اللتان', 'اللذين', 'اللتين']) {
      expect(relatives.ar, contains(form));
    }
    expect(relatives.ar, contains('إعراب المثنى'));
    expect(lesson(42).sections.first.body.ar, contains('بالترتيب والسياق'));
    expect(lesson(47).sections.first.body.ar, contains('معنى خاص'));
    expect(lesson(48).sections.first.body.ar, contains('«كتابًا»'));
    expect(lesson(48).sections.first.body.ar, contains('ألف عوض'));
    for (final bank in [lesson(48).exercises, lesson(48).repeatExercises]) {
      expect(bank.first.prompt.ar, isNot(contains('ً')));
    }
  });

  test(
    'applies the five clarified author passages from the updated review',
    () {
      expect(lesson(14).sections.first.body.ar, contains('الاسم أو الفعل'));
      expect(lesson(15).exercises[2].prompt.ar, contains('المدرسة…… مجتهدون'));
      expect(
        lesson(15).exercises[2].options.first.feedback.ar,
        contains('(معلموها) مبتدأ مرفوع بالواو'),
      );
      expect(
        lesson(39).exercises.first.options[1].feedback.ar,
        contains('يرفع فاعلًا وينصب مفعولًا'),
      );
      expect(lesson(48).objectives.first.ar, contains('ألف العوض'));
      final article = lesson(52).sections[1].examples.single.tokens[3];
      expect(article.role.ar, 'معطوف مجرور');
      expect(article.role.ar, isNot(contains('حرف تعريف')));
      expect(
        lesson(2).exercises[3].prompt.ar,
        'اختر العلامة المناسبة على آخر كلمة (البيت) في جملة: الطفل في البيت.',
      );
    },
  );

  test('removes headlines lesson, renumbers, and applies new author updates', () {
    expect(catalog.lessons, hasLength(58));
    expect(lesson(35).title.ar, 'المبني للمجهول');
    expect(lesson(35).prerequisites, ['lesson_34']);
    expect(lesson(37).title.ar, 'تعدد الإضافة');
    expect(
      lesson(42).sections[1].examples.single.vocalized,
      'كِتَابًا قَرَأْتُ',
    );
    expect(
      lesson(42).exercises[1].options.first.label.ar,
      'تاء الفاعل في (قرأت)',
    );
    expect(
      lesson(43).sections[1].examples.single.vocalized,
      'مَنِ الكَرِيمُ؟ مُحَمَّدٌ',
    );
    expect(lesson(43).exercises.first.options.first.label.ar, 'الخبر (كريم)');
    expect(lesson(54).sections.first.title.ar, 'قسم ثالث بطريق الاستبعاد');
    expect(
      lesson(54).sections[1].body.ar,
      contains('سواهما الحرف كهل وفي ولم'),
    );
    expect(
      lesson(54).sections[1].examples.single.tokens.first.role.ar,
      'خبر مقدم لـ(الكلم)',
    );
    expect(
      lesson(54).exercises[1].options[2].feedback.ar,
      'لا؛ لأن الفعل هو القسم الثاني.',
    );
    expect(
      lesson(20).objectives.first.ar,
      'أن تميّز بين أدوات نفي الحاضر والمستقبل (لا / لن) وأدوات نفي الماضي (ما / لم).',
    );
  });
}
