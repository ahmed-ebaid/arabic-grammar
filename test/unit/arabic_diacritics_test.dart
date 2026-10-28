import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

    expect(find.byType(HarakaGlyph), findsOneWidget);
    expect(tester.widget<HarakaGlyph>(find.byType(HarakaGlyph)).mark, '\u064F');
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('uses shared standalone marks on ${platform.name}', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: platform),
          home: const Scaffold(
            body: Column(
              children: [
                ArabicDiacriticsText('الضمة: ُ الفتحة: َ الكسرة: ِ السكون: ْ'),
                ArabicDiacriticsText('ـُ'),
                ArabicDiacriticsText('الطَّالِبُ'),
              ],
            ),
          ),
        ),
      );

      expect(
        tester
            .widgetList<HarakaGlyph>(find.byType(HarakaGlyph))
            .map((glyph) => glyph.mark),
        ['\u064F', '\u064E', '\u0650', '\u0652', '\u064F'],
      );
      expect(find.text('الطَّالِبُ'), findsOneWidget);
    });
  }

  testWidgets('damma has a hollow loop and a tail separated from its carrier', (
    tester,
  ) async {
    const key = ValueKey('damma');
    await tester.pumpWidget(
      const Center(
        child: RepaintBoundary(
          key: key,
          child: HarakaGlyph(mark: '\u064F', color: Colors.blue),
        ),
      ),
    );

    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(key),
    );
    expect(boundary.size, const Size(28, 36));
    for (final scale in [1.0, 3.0]) {
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: scale);
        try {
          final pixels = (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!;
          int alphaAt(int x, int y) => pixels.getUint8(
            ((y * scale).floor() * image.width + (x * scale).floor()) * 4 + 3,
          );

          expect(
            alphaAt(15, 8),
            lessThan(16),
            reason: 'The loop must remain hollow, allowing edge antialiasing.',
          );
          expect(alphaAt(13, 8), greaterThan(100));
          expect(alphaAt(11, 14), greaterThan(150));
          expect(
            alphaAt(14, 16),
            0,
            reason: 'The tail must not touch the base.',
          );
          expect(alphaAt(14, 18), greaterThan(100));
          expect(alphaAt(2, 18), 0, reason: 'The carrier must stay short.');
          expect(alphaAt(14, 20), 0, reason: 'The carrier must stay thin.');
        } finally {
          image.dispose();
        }
      });
    }
  });
}
