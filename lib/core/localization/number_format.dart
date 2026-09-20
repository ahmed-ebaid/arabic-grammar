import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Formats numbers using the digits of the active locale so Arabic renders
/// Arabic-Indic numerals (١٢٣) instead of Western ones.
///
/// `intl` maps the bare `ar` locale to Western digits, so Arabic is formatted
/// with `ar_EG`, whose numbering system uses Arabic-Indic digits.
String localizedNumber(BuildContext context, num value) {
  final locale = Localizations.localeOf(context);
  final pattern = locale.languageCode == 'ar' ? 'ar_EG' : locale.toString();
  return NumberFormat.decimalPattern(pattern).format(value);
}

/// Formats a whole-number percentage, keeping the digits locale aware.
String localizedPercent(BuildContext context, num value) {
  return '${localizedNumber(context, value)}%';
}
