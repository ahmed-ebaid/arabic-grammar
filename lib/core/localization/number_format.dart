import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

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

/// Selects the Arabic counted-noun form used for a duration in minutes.
enum ArabicMinuteForm { singular, plural }

ArabicMinuteForm arabicMinuteForm(int count) {
  final lastTwoDigits = count % 100;
  return lastTwoDigits >= 3 && lastTwoDigits <= 10
      ? ArabicMinuteForm.plural
      : ArabicMinuteForm.singular;
}

/// Formats a minute count with locale-appropriate digits and wording.
String localizedEstimatedMinutes(BuildContext context, int minutes) {
  final formattedMinutes = localizedNumber(context, minutes);
  final localizations = AppLocalizations.of(context);
  if (Localizations.localeOf(context).languageCode != 'ar') {
    return localizations.estimatedMinutes(formattedMinutes);
  }

  return switch (arabicMinuteForm(minutes)) {
    ArabicMinuteForm.singular => localizations.estimatedMinutes(
      formattedMinutes,
    ),
    ArabicMinuteForm.plural => localizations.estimatedMinutesPlural(
      formattedMinutes,
    ),
  };
}
