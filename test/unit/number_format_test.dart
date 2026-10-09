import 'package:arabic_grammar/core/localization/number_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Arabic minute forms', () {
    test('uses the plural form for counts from three through ten', () {
      expect(arabicMinuteForm(3), ArabicMinuteForm.plural);
      expect(arabicMinuteForm(9), ArabicMinuteForm.plural);
      expect(arabicMinuteForm(10), ArabicMinuteForm.plural);
    });

    test('uses the singular form for other counts', () {
      expect(arabicMinuteForm(1), ArabicMinuteForm.singular);
      expect(arabicMinuteForm(2), ArabicMinuteForm.singular);
      expect(arabicMinuteForm(11), ArabicMinuteForm.singular);
      expect(arabicMinuteForm(12), ArabicMinuteForm.singular);
    });
  });
}
