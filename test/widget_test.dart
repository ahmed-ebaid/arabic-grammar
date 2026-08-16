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
    await tester.pumpAndSettle();

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
    await tester.pumpAndSettle();

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

    await tester.tap(find.text('Start learning'));
    await tester.pumpAndSettle();

    expect(find.text('Beginner foundations'), findsOneWidget);
    expect(find.text('Why endings change'), findsOneWidget);

    await tester.tap(find.text('Why endings change'));
    await tester.pumpAndSettle();

    expect(find.text('What you will learn'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
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
}

ContentCatalog _draftCatalog() {
  final source = File('content/drafts/lesson_01.json').readAsStringSync();
  return ContentCatalog.fromJson(jsonDecode(source));
}
