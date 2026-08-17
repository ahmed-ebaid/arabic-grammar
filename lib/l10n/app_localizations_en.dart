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
  String get moduleSubtitle => '59 guided lessons';

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
  String get practiceFamilySubtitle =>
      'Build your grammar strength, earn stars, and unlock badges—one question at a time.';

  @override
  String get practiceDailyGoalTitle => 'Today\'s goal';

  @override
  String practiceDailyGoalProgress(int current, int goal) {
    return '$current of $goal questions';
  }

  @override
  String get practiceMixedTitle => 'Mixed review';

  @override
  String get practiceMixedBody =>
      'Review varied questions from lessons you have unlocked or attempted.';

  @override
  String get practiceWeakAreasTitle => 'Strengthen weak areas';

  @override
  String get practiceWeakAreasBody =>
      'Review items due today first, then lessons below 70% mastery and question types you previously missed.';

  @override
  String get practiceRewardsTitle => 'Your badges';

  @override
  String get practiceBadgeFirstSteps => 'First Steps';

  @override
  String get practiceBadgePerfect => 'Perfect Ten';

  @override
  String get practiceBadgeHabit => 'Practice Habit';

  @override
  String get practiceBadgeGrammarStar => 'Grammar Star';

  @override
  String get practiceCompleteTitle => 'Practice complete!';

  @override
  String practiceScore(int correct, int total) {
    return '$correct of $total correct';
  }

  @override
  String practiceStarsEarned(int stars) {
    return 'You earned $stars stars';
  }

  @override
  String get practiceAgain => 'Practice again';

  @override
  String get progressTitle => 'Your progress';

  @override
  String get progressSubtitle =>
      'Your learning progress will stay on this device.';

  @override
  String progressCurriculumSummary(int mastered, int total) {
    return '$mastered of $total lessons mastered';
  }

  @override
  String get progressLessonsStarted => 'Lessons started';

  @override
  String get progressPracticeStars => 'Practice stars';

  @override
  String get progressDailyGoal => 'Daily goal';

  @override
  String get progressPracticeAccuracy => 'Practice accuracy';

  @override
  String get progressLevelsTitle => 'Progress by level';

  @override
  String progressAverageMastery(int percent) {
    return 'Average mastery: $percent%';
  }

  @override
  String progressNextLesson(String lesson) {
    return 'Next: $lesson';
  }

  @override
  String get aboutTitle => 'About & credits';

  @override
  String get aboutPurposeTitle => 'Our purpose';

  @override
  String get aboutPurposeBody =>
      'إعراب teaches learners to infer Arabic word endings from grammar, word form, and context. Lessons move gradually from vocalized examples to independent reading without vowel marks.';

  @override
  String get aboutCompanyTitle => 'Developed by Ebaid LLC';

  @override
  String get aboutCompanyBody =>
      'Ebaid LLC develops practical educational technology that makes structured learning more accessible. It created and publishes إعراب, including the app\'s original software, lesson explanations, examples, translations, feedback, and exercises.';

  @override
  String get aboutResourcesTitle => 'Resources and attribution';

  @override
  String get aboutReviewersTitle => 'Teacher reviewers';

  @override
  String get aboutReviewersPending =>
      'Qualified teachers who approve curriculum content will be credited here with their permission. Current beta lessons are still pending review.';

  @override
  String get aboutContentStatusTitle => 'Content status';

  @override
  String get aboutContentVersion => 'Curriculum version';

  @override
  String get aboutDisclaimer =>
      'This app is a learning aid and does not replace instruction from a qualified Arabic teacher. Draft analyses may change during review.';

  @override
  String get aboutContactTitle => 'Support and legal information';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get close => 'Close';

  @override
  String get more => 'More';

  @override
  String get glossaryTitle => 'Grammar glossary';

  @override
  String get glossarySearchHint => 'Search Arabic, English, or transliteration';

  @override
  String get glossaryNoResults => 'No matching grammar terms.';

  @override
  String glossaryLessonLinks(int count) {
    return 'Connected to $count lessons';
  }

  @override
  String get clearSearch => 'Clear search';

  @override
  String get bookmarksTitle => 'Saved items';

  @override
  String get bookmarksEmpty =>
      'Bookmark a lesson, worked example, or glossary term to find it here.';

  @override
  String get bookmarkedLessons => 'Saved lessons';

  @override
  String get bookmarkedExamples => 'Saved examples';

  @override
  String get bookmarkedTerms => 'Saved glossary terms';

  @override
  String get addBookmark => 'Save';

  @override
  String get removeBookmark => 'Remove from saved items';

  @override
  String get listen => 'Listen';

  @override
  String get textSizeTitle => 'Text size';

  @override
  String get textSizeBody =>
      'Choose a comfortable reading size. This setting applies throughout the app.';

  @override
  String get textSizeSmall => 'Small';

  @override
  String get textSizeDefault => 'Default';

  @override
  String get textSizeLarge => 'Large';

  @override
  String get textSizeLargest => 'Largest';

  @override
  String get learningIllustrationLabel => 'A cheerful Arabic learning card';

  @override
  String get celebrationIllustrationLabel =>
      'A colorful Arabic grammar celebration';
}
