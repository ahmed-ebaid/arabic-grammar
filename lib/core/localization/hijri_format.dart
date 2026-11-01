import 'package:flutter/widgets.dart';

import '../services/hijri_calendar_service.dart';
import 'number_format.dart';

/// Localized Hijri month names, indexed by month - 1.
const Map<String, List<String>> hijriMonthNames = {
  'en': [
    'Muharram',
    'Safar',
    'Rabi al-Awwal',
    'Rabi al-Thani',
    'Jumada al-Ula',
    'Jumada al-Akhirah',
    'Rajab',
    'Shaban',
    'Ramadan',
    'Shawwal',
    'Dhu al-Qadah',
    'Dhu al-Hijjah',
  ],
  'ar': [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ],
};

const Map<String, String> _hijriEraSuffix = {'en': 'AH', 'ar': 'هـ'};

String formatHijriDate(BuildContext context, HijriDate date) {
  final locale = Localizations.localeOf(context);
  return formatHijriDateForLocale(
    date,
    locale,
    day: localizedNumber(context, date.day),
    year: _plainLocalizedDigits(locale.languageCode, date.year),
  );
}

String formatHijriDateForLocale(
  HijriDate date,
  Locale locale, {
  String? day,
  String? year,
}) {
  final code = locale.languageCode;
  final months = hijriMonthNames[code] ?? hijriMonthNames['en']!;
  final suffix = _hijriEraSuffix[code] ?? _hijriEraSuffix['en']!;
  final formattedDay = day ?? _plainLocalizedDigits(code, date.day);
  final formattedYear = year ?? _plainLocalizedDigits(code, date.year);
  final month = months[date.month - 1];
  return '$formattedDay $month $formattedYear $suffix';
}

String _plainLocalizedDigits(String languageCode, int value) {
  if (languageCode != 'ar') return value.toString();
  const arabicIndic = '٠١٢٣٤٥٦٧٨٩';
  return value
      .toString()
      .split('')
      .map((digit) => arabicIndic[int.parse(digit)])
      .join();
}
