// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'إعراب';

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
  String lessonNumber(int number) {
    return 'Lesson $number';
  }

  @override
  String estimatedMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get objectivesTitle => 'What you will learn';

  @override
  String get vocalizedLabel => 'With vowel marks';

  @override
  String get unvocalizedLabel => 'Without vowel marks';

  @override
  String get wordAnalysisTitle => 'Word analysis';

  @override
  String get roleLabel => 'Role';

  @override
  String get stateLabel => 'State';

  @override
  String get signLabel => 'Sign';

  @override
  String get endingLabel => 'Ending';

  @override
  String get reasonLabel => 'Why';

  @override
  String get lessonPracticeTitle => 'Try it';

  @override
  String get contentLoadError => 'The lesson could not be loaded.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get checkAnswer => 'Check answer';

  @override
  String get tryAgain => 'Try again';

  @override
  String get quickCheckTitle => 'Quick check';

  @override
  String get chooseTopicPrompt => 'Which word is the topic (mubtada)?';

  @override
  String get correctAnswerTitle => 'Correct!';

  @override
  String get incorrectAnswerTitle => 'Not quite yet';

  @override
  String get exploreWordsTitle => 'Explore the sentence';

  @override
  String get exploreWordsBody =>
      'Tap each word to see its role, state, sign, ending, and reason.';

  @override
  String get lessonCompleteTitle => 'Lesson complete!';

  @override
  String get lessonCompleteBody =>
      'You noticed how word endings can reveal a word\'s job in a sentence.';

  @override
  String get restartLesson => 'Practice again';

  @override
  String get returnToLessons => 'Back to lessons';

  @override
  String stepProgress(int current, int total) {
    return 'Step $current of $total';
  }

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
