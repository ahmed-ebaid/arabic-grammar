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
  testWidgets('renders the bilingual application shell', (tester) async {
    final localeController = LocaleController.inMemory();

    await tester.pumpWidget(
      ArabicGrammarApp(
        environment: const AppEnvironment(AppFlavor.production),
        localeController: localeController,
        lessonProgressController: LessonProgressController.inMemory(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Learn why Arabic endings change'), findsOneWidget);
    expect(find.text('الطَّالِبُ مُجْتَهِدٌ'), findsOneWidget);
    expect(find.text('Lessons'), findsOneWidget);
    final arabicTextDirection = tester.widget<Directionality>(
      find
          .ancestor(
            of: find.text('الطَّالِبُ مُجْتَهِدٌ'),
            matching: find.byType(Directionality),
          )
          .first,
    );
    expect(arabicTextDirection.textDirection, TextDirection.rtl);

    await localeController.setLocale(const Locale('ar'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('تعلَّم لماذا تتغيَّر أواخر الكلمات'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
  });

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
      find.text('Start learning'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Start learning'));
    await tester.pumpAndSettle();

    expect(find.text('Level 1: Reading foundations'), findsOneWidget);
    expect(find.text('Why endings change'), findsOneWidget);

    await tester.tap(find.text('Why endings change'));
    await tester.pumpAndSettle();

    expect(find.text('What you will learn'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('shows curriculum sources and review status in About', (
    tester,
  ) async {
    final localeController = LocaleController.inMemory();
    await tester.pumpWidget(
      ArabicGrammarApp(
        environment: const AppEnvironment(AppFlavor.production),
        localeController: localeController,
        lessonProgressController: LessonProgressController.inMemory(),
        contentCatalog: _draftCatalog(),
      ),
    );

    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('About & credits'));
    await tester.pumpAndSettle();

    expect(find.text('About & credits'), findsOneWidget);
    expect(find.text('Developed by Ebaid LLC'), findsOneWidget);
    expect(find.text('Al-Ajurrumiyya'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Teacher reviewers'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Teacher reviewers'), findsOneWidget);
    expect(
      find.textContaining('Current beta lessons are still pending review'),
      findsOneWidget,
    );

    await localeController.setLocale(const Locale('ar'));
    await tester.pumpAndSettle();
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

    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Grammar glossary'));
    await tester.pumpAndSettle();

    expect(find.text('Grammar glossary'), findsOneWidget);
    await tester.enterText(find.byType(SearchBar), 'mubtada');
    await tester.pumpAndSettle();
    expect(find.text("Mubtada' (topic)"), findsOneWidget);

    await tester.tap(find.byTooltip('Save').first);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Remove from saved items'), findsOneWidget);
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

    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();

    expect(find.text('Mixed review'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Strengthen weak areas'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Strengthen weak areas'), findsOneWidget);
    expect(find.text('0 of 10 questions'), findsOneWidget);

    await tester.ensureVisible(find.text('Mixed review'));
    await tester.tap(find.text('Mixed review'));
    await tester.pumpAndSettle();

    expect(find.text('1/10'), findsOneWidget);
    expect(find.text('Why endings change'), findsOneWidget);
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

    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();

    expect(find.text('1 of 59 lessons mastered'), findsOneWidget);
    expect(find.text('Practice stars'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Progress by level'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Progress by level'), findsOneWidget);
    expect(find.text('Level 1: Reading foundations'), findsOneWidget);
    expect(find.text('1/7'), findsOneWidget);
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

    await tester.tap(find.text('Lessons'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Why endings change'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('الطالبُ'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Fatha: َ'));
    await tester.tap(find.text('Fatha: َ'));
    await tester.pump();
    await tester.ensureVisible(find.text('Check answer'));
    await tester.tap(find.text('Check answer'));
    await tester.pumpAndSettle();

    expect(find.text('Not quite yet'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    await tester.ensureVisible(find.text('Try again'));
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Damma: ُ'));
    await tester.tap(find.text('Damma: ُ'));
    await tester.pump();
    await tester.ensureVisible(find.text('Check answer'));
    await tester.tap(find.text('Check answer'));
    await tester.pumpAndSettle();

    expect(find.text('Correct!'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
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

    await tester.tap(find.text('Lessons'));
    await tester.pumpAndSettle();
    expect(
      find.text('Locked until the previous lesson is mastered'),
      findsOneWidget,
    );

    await progress.complete('lesson_01', 0, mastery: 75);
    await tester.pumpAndSettle();

    expect(find.text('Mastery: 75%'), findsOneWidget);
    expect(
      find.text('Locked until the previous lesson is mastered'),
      findsNothing,
    );
  });
}

ContentCatalog _draftCatalog() {
  final source = File('content/drafts/lesson_01.json').readAsStringSync();
  return ContentCatalog.fromJson(jsonDecode(source));
}
