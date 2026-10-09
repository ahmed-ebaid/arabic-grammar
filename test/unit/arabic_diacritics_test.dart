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
}
