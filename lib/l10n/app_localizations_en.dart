// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Arabic Grammar';

  @override
  String get homeTab => 'Home';

  @override
  String get lessonsTab => 'Lessons';

  @override
  String get practiceTab => 'Practice';

  @override
  String get progressTab => 'Progress';

  @override
  String get welcomeTitle => 'Learn why Arabic endings change';

  @override
  String get welcomeBody =>
      'Build the grammar instincts to read Arabic correctly, even when the vowel marks are not written.';

  @override
  String get exampleLabel => 'A first look';

  @override
  String get exampleSentence => 'الطَّالِبُ مُجْتَهِدٌ';

  @override
  String get exampleExplanation =>
      'Both words end with damma because this is a basic nominal sentence.';

  @override
  String get startLearning => 'Start learning';

  @override
  String get moduleTitle => 'Beginner foundations';

  @override
  String get moduleSubtitle => '10 guided lessons';

  @override
  String get comingSoon => 'Curriculum content is coming in the next phase.';

  @override
  String get practiceTitle => 'Practice';

  @override
  String get practiceSubtitle => 'Exercises will unlock with each lesson.';

  @override
  String get progressTitle => 'Your progress';

  @override
  String get progressSubtitle =>
      'Your learning progress will stay on this device.';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get close => 'Close';
}
