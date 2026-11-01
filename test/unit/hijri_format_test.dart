import 'dart:ui';

import 'package:arabic_grammar/core/localization/hijri_format.dart';
import 'package:arabic_grammar/core/services/hijri_calendar_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats Hijri date in Arabic with Arabic-Indic digits', () {
    const date = HijriDate(1447, 9, 15);
    expect(
      formatHijriDateForLocale(date, const Locale('ar')),
      '١٥ رمضان ١٤٤٧ هـ',
    );
  });

  test('formats Hijri date in English with Western digits', () {
    const date = HijriDate(1447, 12, 10);
    expect(
      formatHijriDateForLocale(date, const Locale('en')),
      '10 Dhu al-Hijjah 1447 AH',
    );
  });
}
