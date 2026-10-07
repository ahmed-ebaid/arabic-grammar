import 'dart:convert';
import 'dart:io';

import 'package:arabic_grammar/app.dart';
import 'package:arabic_grammar/core/config/app_environment.dart';
import 'package:arabic_grammar/core/localization/locale_controller.dart';
import 'package:arabic_grammar/core/models/content_models.dart';
import 'package:arabic_grammar/core/progress/lesson_progress_controller.dart';
import 'package:arabic_grammar/core/theme/app_theme.dart';
import 'package:arabic_grammar/features/home/home_screen.dart';
import 'package:arabic_grammar/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Level 2 opens the Plus offer when billing is unconfigured', (
    tester,
  ) async {
    final catalog = _draftCatalog();
    await tester.pumpWidget(
      ArabicGrammarApp(
        environment: const AppEnvironment(AppFlavor.production),
        localeController: LocaleController.inMemory(),
        lessonProgressController: LessonProgressController.inMemory(),
        contentCatalog: catalog,
      ),
    );

    await tester.tap(find.text('الدروس'));
    await tester.pumpAndSettle();
    final levelTwo = catalog.levels.firstWhere((level) => level.order == 2);
    final premiumLesson = catalog.lessons.firstWhere(
      (lesson) => lesson.id == levelTwo.lessonIds.first,
    );
    final premiumTitle = find.text(premiumLesson.title.ar);
    await tester.scrollUntilVisible(
      premiumTitle,
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await Scrollable.ensureVisible(
      tester.element(premiumTitle),
      alignment: 0.25,
    );
    await tester.pumpAndSettle();
    await tester.tap(premiumTitle);
    await tester.pumpAndSettle();

    expect(find.text('إعراب بلس'), findsWidgets);
    expect(
      find.text('الاشتراكات غير متاحة حاليًّا. حاول لاحقًا.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('offers purchase restore and explains when not configured', (
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
    await tester.tap(find.text('استعادة الاشتراكات'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('استعادة الاشتراكات غير مهيأة بعد.'), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    testWidgets('home prioritizes learning in $brightness on a small phone', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var starts = 0;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 800),
              textScaler: TextScaler.linear(1.4),
            ),
            child: Scaffold(
              body: HomeScreen(
                contentCatalog: _draftCatalog(),
                progressController: LessonProgressController.inMemory(),
                onStartLearning: () => starts++,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('ابدأ التعلُّم'),
        100,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('ابدأ التعلُّم'), findsOneWidget);
      expect(find.text('تابع الدرس'), findsNothing);
      expect(find.textContaining('٠'), findsWidgets);
      await tester.ensureVisible(find.text('ابدأ التعلُّم'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ابدأ التعلُّم'));
      expect(starts, 1);
      await tester.scrollUntilVisible(
        find.text('الطَّالِبُ مُجْتَهِدٌ'),
        200,
        scrollable: find.byType(Scrollable),
      );
      expect(tester.takeException(), isNull);
    });
  }

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
    expect(
      find.textContaining('من الأمثلة إلى القراءة المستقلة'),
      findsOneWidget,
    );
    expect(find.textContaining('الأمثلة المشكولة'), findsNothing);
    expect(find.text('تطوير ونشر Ebaid LLC'), findsOneWidget);
    expect(find.textContaining('شركة إبيد'), findsNothing);
    expect(find.text('الآجرومية'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('المعلّمون المراجعون'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('المعلّمون المراجعون'), findsOneWidget);
    expect(find.text('د. شريف محمد الصادق'), findsOneWidget);
    expect(
      find.text(
        'مدرس اللغويات بكلية الدراسات الإسلامية والعربية للبنين بالقاهرة جامعة الأزهر',
      ),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.textContaining('ما زالت دروس النسخة التجريبية قيد المراجعة'),
      150,
      scrollable: find.byType(Scrollable),
    );
    expect(
      find.textContaining('ما زالت دروس النسخة التجريبية قيد المراجعة'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('حالة المحتوى'),
      250,
      scrollable: find.byType(Scrollable),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('الدعم والمعلومات القانونية'), findsNothing);
    expect(find.textContaining('ahmed@ebaidllc.com'), findsNothing);
    expect(
      find.textContaining('ahmed-ebaid.github.io/arabic-grammar'),
      findsNothing,
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
    final secondLesson = find.text(_draftCatalog().lessons[1].title.ar);
    await tester.scrollUntilVisible(
      secondLesson,
      100,
      scrollable: find.byType(Scrollable).last,
    );
    final secondNode = find.ancestor(
      of: secondLesson,
      matching: find.byType(InkWell),
    );
    expect(
      find.descendant(
        of: secondNode,
        matching: find.text('مغلق حتى إتقان الدرس السابق'),
      ),
      findsOneWidget,
    );

    await progress.complete('lesson_01', 0, mastery: 75);
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: secondNode,
        matching: find.text('مغلق حتى إتقان الدرس السابق'),
      ),
      findsNothing,
    );
    await tester.scrollUntilVisible(
      find.text('الإتقان: ٧٥%'),
      -100,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('الإتقان: ٧٥%'), findsOneWidget);
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
