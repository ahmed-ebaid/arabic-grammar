import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arabic_grammar/core/localization/arabic_diacritics.dart';

void main() {
  group('makeArabicDiacriticsVisible', () {
    test('renders standalone marks on a tatweel carrier', () {
      expect(
        makeArabicDiacriticsVisible('الضمة الظاهرة (ُ)'),
        'الضمة الظاهرة (ـُ)',
      );
    });

    test('replaces the colon before a standalone mark with parentheses', () {
      expect(makeArabicDiacriticsVisible('الضمة: ُ'), 'الضمة (ـُ)');
      expect(makeArabicDiacriticsVisible('Damma: ُ'), 'Damma (ـُ)');
    });

    test('leaves marks attached to Arabic letters unchanged', () {
      expect(makeArabicDiacriticsVisible('الطَّالِبُ'), 'الطَّالِبُ');
    });

    test('adds only one carrier for a sequence of standalone marks', () {
      expect(makeArabicDiacriticsVisible('(ُّ)'), '(ـُّ)');
    });
  });

  testWidgets('emphasizes detached marks in rich text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(body: ArabicDiacriticsText('الضمة: ُ والطالبُ')),
      ),
    );

    final richText = tester.widget<RichText>(
      find.descendant(
        of: find.byType(ArabicDiacriticsText),
        matching: find.byType(RichText),
      ),
    );
    final root = richText.text as TextSpan;
    final spans = <TextSpan>[];
    void collectSpans(InlineSpan span) {
      if (span is TextSpan) {
        spans.add(span);
        for (final child in span.children ?? const <InlineSpan>[]) {
          collectSpans(child);
        }
      }
    }

    collectSpans(root);
    final emphasizedMark = spans.singleWhere((span) => span.text == 'ـُ');

    expect(root.toPlainText(), 'الضمة (ـُ) والطالبُ');
    expect(emphasizedMark.style?.fontSize, greaterThan(14));
    expect(emphasizedMark.style?.fontWeight, FontWeight.w700);
  });
}
