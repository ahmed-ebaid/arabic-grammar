import 'dart:convert';
import 'dart:io';

import 'package:arabic_grammar/app.dart';
import 'package:arabic_grammar/core/config/app_environment.dart';
import 'package:arabic_grammar/core/localization/locale_controller.dart';
import 'package:arabic_grammar/core/models/content_models.dart';
import 'package:arabic_grammar/core/progress/lesson_progress_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'renders the Arabic-only shell without language or speaker controls',
    (tester) async {
      final localeController = LocaleController.inMemory(const Locale('ar'));

      await tester.pumpWidget(
        ArabicGrammarApp(
          environment: const AppEnvironment(AppFlavor.production),
          localeController: localeController,
          lessonProgressController: LessonProgressController.inMemory(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('تعلَّم لماذا تتغيَّر أواخر الكلمات'), findsOneWidget);
      expect(find.text('الطَّالِبُ مُجْتَهِدٌ'), findsOneWidget);
      expect(find.text('الدروس'), findsOneWidget);
      expect(find.text('Learn why Arabic endings change'), findsNothing);
      expect(find.byTooltip('اللغة'), findsNothing);
      expect(find.byIcon(Icons.volume_up_outlined), findsNothing);

      expect(
        tester
            .widget<Directionality>(find.byType(Directionality).first)
            .textDirection,
        TextDirection.rtl,
      );
    },
  );

  testWidgets('opens lesson 1 from home', (tester) async {
    await tester.pumpWidget(
      ArabicGrammarApp(
        environment: const AppEnvironment(AppFlavor.production),
        localeController: LocaleController.inMemory(),
        lessonProgressController: LessonProgressController.inMemory(),
        contentCatalog: _draftCatalog(),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('ابدأ التعلُّم'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('ابدأ التعلُّم'));
    await tester.pumpAndSettle();

    expect(find.text('المستوى الأول: أساس القراءة'), findsOneWidget);
    expect(find.text('لماذا تتغيَّر أواخر الكلمات؟'), findsOneWidget);

    await tester.tap(find.text('لماذا تتغيَّر أواخر الكلمات؟'));
    await tester.pumpAndSettle();

    expect(find.text('ماذا ستتعلَّم؟'), findsOneWidget);
    expect(find.text('تابع'), findsOneWidget);
  });

  testWidgets('shows curriculum sources and review status in About', (
    tester,
  ) async {
    await tester.pumpWidget(
      ArabicGrammarApp(
        environment: const AppEnvironment(AppFlavor.production),
        localeController: LocaleController.inMemory(),
        lessonProgressController: LessonProgressController.inMemory(),
        contentCatalog: _draftCatalog(),
      ),
    );

    await tester.tap(find.byTooltip('المزيد'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('عن التطبيق وشكر المساهمين'));
    await tester.pumpAndSettle();

    expect(find.text('عن التطبيق وشكر المساهمين'), findsOneWidget);
    expect(find.text('تطوير ونشر شركة إبيد ذ.م.م.'), findsOneWidget);
    expect(find.text('الآجرومية'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('المعلّمون المراجعون'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('المعلّمون المراجعون'), findsOneWidget);
    expect(
      find.textContaining('وما زالت دروس النسخة التجريبية قيد المراجعة'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('الآجرومية'),
      -300,
      scrollable: find.byType(Scrollable).last,
    );

    expect(find.text('الآجرومية'), findsOneWidget);
    expect(find.textContaining('ابن آجروم'), findsOneWidget);
  });

  testWidgets('searches and bookmarks bilingual glossary terms', (
    tester,
  ) async {
    await tester.pumpWidget(
      ArabicGrammarApp(
        environment: const AppEnvironment(AppFlavor.production),
        localeController: LocaleController.inMemory(),
        lessonProgressController: LessonProgressController.inMemory(),
        contentCatalog: _draftCatalog(),
      ),
    );

    await tester.tap(find.byTooltip('المزيد'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('معجم النحو'));
    await tester.pumpAndSettle();

    expect(find.text('معجم النحو'), findsOneWidget);
    await tester.enterText(find.byType(SearchBar), 'mubtada');
    await tester.pumpAndSettle();
    expect(find.text('المبتدأ'), findsOneWidget);

    await tester.tap(find.byTooltip('حفظ').first);
    await tester.pumpAndSettle();
    expect(find.byTooltip('إزالة من المحفوظات'), findsOneWidget);
  });

  testWidgets('starts a ten-question mixed practice session', (tester) async {
    await tester.pumpWidget(
      ArabicGrammarApp(
        environment: const AppEnvironment(AppFlavor.production),
        localeController: LocaleController.inMemory(),
        lessonProgressController: LessonProgressController.inMemory(),
        contentCatalog: _draftCatalog(),
      ),
    );

    await tester.tap(find.text('التدريب'));
    await tester.pumpAndSettle();

    expect(find.text('مراجعة متنوعة'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('تقوية مواطن الضعف'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('تقوية مواطن الضعف'), findsOneWidget);
    expect(find.text('٠ من ١٠ أسئلة'), findsOneWidget);

    await tester.ensureVisible(find.text('مراجعة متنوعة'));
    await tester.tap(find.text('مراجعة متنوعة'));
    await tester.pumpAndSettle();

    expect(find.text('١/١٠'), findsOneWidget);
    expect(find.text('لماذا تتغيَّر أواخر الكلمات؟'), findsOneWidget);
  });

  testWidgets('shows curriculum and practice metrics in Progress', (
    tester,
  ) async {
    final progress = LessonProgressController.inMemory();
    await progress.complete('lesson_01', 6, mastery: 80);
    await progress.recordPracticeSession(answered: 10, correct: 8);

    await tester.pumpWidget(
      ArabicGrammarApp(
        environment: const AppEnvironment(AppFlavor.production),
        localeController: LocaleController.inMemory(),
        lessonProgressController: progress,
        contentCatalog: _draftCatalog(),
      ),
    );

    await tester.tap(find.text('التقدم'));
    await tester.pumpAndSettle();

    expect(find.text('أتقنت ١ درسًا من أصل ٥٩'), findsOneWidget);
    expect(find.text('نجوم التدريب'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('التقدّم حسب المستوى'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('التقدّم حسب المستوى'), findsOneWidget);
    expect(find.text('المستوى الأول: أساس القراءة'), findsOneWidget);
    expect(find.text('١/٧'), findsOneWidget);
  });

  testWidgets('explains an incorrect answer and allows a retry', (
    tester,
  ) async {
    await tester.pumpWidget(
      ArabicGrammarApp(
        environment: const AppEnvironment(AppFlavor.production),
        localeController: LocaleController.inMemory(),
        lessonProgressController: LessonProgressController.inMemory(),
        contentCatalog: _draftCatalog(),
      ),
    );

    await tester.tap(find.text('الدروس'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('لماذا تتغيَّر أواخر الكلمات؟'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      await tester.ensureVisible(find.text('تابع'));
      await tester.tap(find.text('تابع'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('الطالبُ'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('تابع'));
    await tester.tap(find.text('تابع'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('الفتحة: َ'));
    await tester.tap(find.text('الفتحة: َ'));
    await tester.pump();
    await tester.ensureVisible(find.text('تحقَّق من الإجابة'));
    await tester.tap(find.text('تحقَّق من الإجابة'));
    await tester.pumpAndSettle();

    expect(find.text('ليس بعد'), findsOneWidget);
    expect(find.text('حاول مرة أخرى'), findsOneWidget);

    await tester.ensureVisible(find.text('حاول مرة أخرى'));
    await tester.tap(find.text('حاول مرة أخرى'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('الضمة: ُ'));
    await tester.tap(find.text('الضمة: ُ'));
    await tester.pump();
    await tester.ensureVisible(find.text('تحقَّق من الإجابة'));
    await tester.tap(find.text('تحقَّق من الإجابة'));
    await tester.pumpAndSettle();

    expect(find.text('أحسنت!'), findsOneWidget);
    expect(find.text('تابع'), findsOneWidget);
  });

  testWidgets('navigates lesson steps and gates next on a solved question', (
    tester,
  ) async {
    await tester.pumpWidget(
      ArabicGrammarApp(
        environment: const AppEnvironment(AppFlavor.production),
        localeController: LocaleController.inMemory(),
        lessonProgressController: LessonProgressController.inMemory(),
        contentCatalog: _draftCatalog(),
      ),
    );

    await tester.tap(find.text('الدروس'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('لماذا تتغيَّر أواخر الكلمات؟'));
    await tester.pumpAndSettle();

    expect(_navEnabled(tester, 'lessonPreviousStep'), isFalse);
    expect(_navEnabled(tester, 'lessonNextStep'), isTrue);

    await tester.tap(find.byKey(const ValueKey('lessonNextStep')));
    await tester.pumpAndSettle();
    expect(find.text('الخطوة ٢ من ٩'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('lessonPreviousStep')));
    await tester.pumpAndSettle();
    expect(find.text('الخطوة ١ من ٩'), findsOneWidget);
    expect(find.text('ماذا ستتعلَّم؟'), findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await tester.ensureVisible(find.text('تابع'));
      await tester.tap(find.text('تابع'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('الطالبُ'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('تابع'));
    await tester.tap(find.text('تابع'));
    await tester.pumpAndSettle();

    expect(find.text('تحقُّق سريع'), findsOneWidget);
    expect(_navEnabled(tester, 'lessonNextStep'), isFalse);

    await tester.ensureVisible(find.text('الضمة: ُ'));
    await tester.tap(find.text('الضمة: ُ'));
    await tester.pump();
    await tester.ensureVisible(find.text('تحقَّق من الإجابة'));
    await tester.tap(find.text('تحقَّق من الإجابة'));
    await tester.pumpAndSettle();

    expect(_navEnabled(tester, 'lessonNextStep'), isTrue);

    await tester.tap(find.byKey(const ValueKey('lessonNextStep')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('lessonPreviousStep')));
    await tester.pumpAndSettle();

    expect(find.text('أحسنت!'), findsOneWidget);
    expect(_navEnabled(tester, 'lessonNextStep'), isTrue);
  });

  testWidgets('locks lesson 2 until lesson 1 reaches 70 percent', (
    tester,
  ) async {
    final progress = LessonProgressController.inMemory();
    await tester.pumpWidget(
      ArabicGrammarApp(
        environment: const AppEnvironment(AppFlavor.production),
        localeController: LocaleController.inMemory(),
        lessonProgressController: progress,
        contentCatalog: _draftCatalog(),
      ),
    );

    await tester.tap(find.text('الدروس'));
    await tester.pumpAndSettle();
    expect(find.text('مغلق حتى إتقان الدرس السابق'), findsOneWidget);

    await progress.complete('lesson_01', 0, mastery: 75);
    await tester.pumpAndSettle();

    expect(find.text('الإتقان: ٧٥%'), findsOneWidget);
    expect(find.text('مغلق حتى إتقان الدرس السابق'), findsNothing);
  });
}

ContentCatalog _draftCatalog() {
  final source = File('content/drafts/lesson_01.json').readAsStringSync();
  return ContentCatalog.fromJson(jsonDecode(source));
}

bool _navEnabled(WidgetTester tester, String key) {
  final button = tester.widget<TextButton>(find.byKey(ValueKey(key)));
  return button.onPressed != null;
}
