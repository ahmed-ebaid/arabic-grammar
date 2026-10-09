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
  String get grammarStateRaf => 'Raf';

  @override
  String get grammarStateNasb => 'Nasb';

  @override
  String get grammarStateJarr => 'Jarr';

  @override
  String get grammarStateJazm => 'Jazm';

  @override
  String get grammarStateIndeclinable => 'Indeclinable';

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
  String get pathContinueTitle => 'Continue your path';

  @override
  String get pathCompleteTitle => 'Path checkpoint complete';

  @override
  String pathMastery(String percent) {
    return '$percent% mastery';
  }

  @override
  String get pathContinueAction => 'Continue lesson';

  @override
  String get moduleTitle => 'Beginner foundations';

  @override
  String get moduleSubtitle => '59 guided lessons';

  @override
  String get comingSoon => 'Curriculum content is coming in the next phase.';

  @override
  String lessonNumber(String number) {
    return 'Lesson $number';
  }

  @override
  String estimatedMinutes(String minutes) {
    return '$minutes min';
  }

  @override
  String estimatedMinutesPlural(String minutes) {
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
  String get learningModeSimpleQuestionTitle => 'Choose an answer';

  @override
  String get learningModeDetailedQuestionTitle => 'Check the rule';

  @override
  String get learningModeAdultQuestionTitle => 'Apply the rule';

  @override
  String get learningModeDetailedQuestionHint =>
      'Identify the word\'s role and ending before you choose.';

  @override
  String get learningModeAdultQuestionHint =>
      'Use syntax, morphology, and context to justify the best reading.';

  @override
  String get chooseTopicPrompt => 'Which word is the topic (mubtada)?';

  @override
  String get correctAnswerTitle => 'Correct!';

  @override
  String get correctAnswerCelebration => 'You got it! Keep going.';

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
  String get previousStep => 'Previous';

  @override
  String get nextStep => 'Next';

  @override
  String get nextStepLocked => 'Answer this question to continue';

  @override
  String stepProgress(String current, String total) {
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
  String practiceDailyGoalProgress(String current, String goal) {
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
  String practiceScore(String correct, String total) {
    return '$correct of $total correct';
  }

  @override
  String practiceStarsEarned(String stars) {
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
  String progressCurriculumSummary(String mastered, String total) {
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
  String get progressStreak => 'Day streak';

  @override
  String get progressTotalXp => 'Total XP';

  @override
  String get progressLevelsTitle => 'Progress by level';

  @override
  String progressAverageMastery(String percent) {
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
      'إعراب teaches learners to infer Arabic word endings from grammar, word form, and context. Lessons move gradually from examples to independent reading without vowel marks.';

  @override
  String get aboutCompanyTitle => 'Developed by Ebaid LLC';

  @override
  String get aboutCompanyBody =>
      'Ebaid LLC develops practical educational technology that makes structured learning more accessible. It created and publishes إعراب, including the app\'s original software, lesson explanations, examples, translations, feedback, and exercises.';

  @override
  String get aboutResourcesTitle => 'Resources and attribution';

  @override
  String get aboutResourceTitleLabel => 'Resource';

  @override
  String get aboutResourceAuthorLabel => 'Author';

  @override
  String get aboutResourceCitationLabel => 'Source note';

  @override
  String get aboutReviewersTitle => 'Teacher reviewers';

  @override
  String get aboutReviewerName => 'د. شريف محمد الصادق';

  @override
  String get aboutReviewerCredentials =>
      'Lecturer in Linguistics, Faculty of Islamic and Arabic Studies for Men in Cairo, Al-Azhar University';

  @override
  String get aboutReviewersPending =>
      'Current beta lessons are still under review and have not yet been approved.';

  @override
  String get aboutContentStatusTitle => 'Content status';

  @override
  String get aboutContentVersion => 'Curriculum version';

  @override
  String get aboutDisclaimer =>
      'This app is a learning aid and does not replace instruction from a qualified Arabic teacher. Draft analyses may change during review.';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get close => 'Close';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get restorePurchasesChecking => 'Checking for previous purchases…';

  @override
  String get restorePurchasesSuccess => 'Your subscription has been restored.';

  @override
  String get restorePurchasesNoneFound =>
      'No active subscription was found for this store account.';

  @override
  String get restorePurchasesUnavailable =>
      'Purchase restoration is not configured yet.';

  @override
  String get restorePurchasesError =>
      'Could not restore your subscription. Check your connection and try again.';

  @override
  String get plusTitle => 'إعراب Plus';

  @override
  String get plusDescription =>
      'Continue your grammar journey with advanced study.';

  @override
  String get plusBenefitLessons => 'Unlock Level 2 and all following levels.';

  @override
  String get plusBenefitPractice =>
      'Practice across a wider range of grammar topics.';

  @override
  String get plusBenefitExplanations =>
      'Explore extended explanations and examples.';

  @override
  String get plusLevelNotice =>
      'إعراب Plus subscription required for this level.';

  @override
  String get plusRequired => 'Subscribe to إعراب Plus to unlock this level.';

  @override
  String get plusMonthly => 'Monthly subscription';

  @override
  String get plusAnnual => 'Annual subscription';

  @override
  String get plusPerMonth => 'Renews every month';

  @override
  String get plusPerYear => 'Renews every year';

  @override
  String get plusPurchaseAction => 'Subscribe';

  @override
  String get plusPurchaseSuccess => 'إعراب Plus is now active.';

  @override
  String get plusPurchaseCancelled => 'Purchase cancelled.';

  @override
  String get plusPurchaseChecking => 'Checking subscription…';

  @override
  String get plusPurchaseError =>
      'The subscription could not be completed. Please try again.';

  @override
  String get plusNotConfigured =>
      'Subscriptions are not available right now. Please try again later.';

  @override
  String get plusOfferingUnavailable =>
      'No subscription packages are currently available.';

  @override
  String get plusOfferingError => 'Could not load subscription packages.';

  @override
  String get plusRenewalDisclosure =>
      'Payment is charged through your app store and renews automatically unless cancelled in the store subscription settings before renewal.';

  @override
  String get plusPrivacyPolicy => 'Privacy Policy';

  @override
  String get plusTermsOfUse => 'Terms of Use';

  @override
  String get plusConfigurationError =>
      'Subscriptions could not be configured. Please try again later.';

  @override
  String get plusExternalLinkError =>
      'Could not open this page. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get more => 'More';

  @override
  String get glossaryTitle => 'Grammar glossary';

  @override
  String get glossarySearchHint => 'Search Arabic, English, or transliteration';

  @override
  String get glossaryNoResults => 'No matching grammar terms.';

  @override
  String glossaryLessonLinks(String count) {
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
  String get learningModeTitle => 'Learning style';

  @override
  String get learningModeBody =>
      'Choose how much explanation you want to see in lessons.';

  @override
  String get learningModeSimple => 'Simple';

  @override
  String get learningModeDetailed => 'Detailed';

  @override
  String get learningModeAdult => 'Adult';

  @override
  String get learnerProfileTitle => 'Learner profile';

  @override
  String get learnerProfileBody =>
      'This helps us shape the pace and encouragement for your learning path.';

  @override
  String get learnerProfileYoung => 'Young learner';

  @override
  String get learnerProfileGeneral => 'General learner';

  @override
  String get learnerProfileChange => 'Change profile';

  @override
  String get learningIllustrationLabel => 'A cheerful Arabic learning card';

  @override
  String get celebrationIllustrationLabel =>
      'A colorful Arabic grammar celebration';

  @override
  String homeStreakDays(String days) {
    return '$days-day streak';
  }

  @override
  String homeTotalXp(String xp) {
    return '$xp XP';
  }

  @override
  String streakMilestoneTitle(String days) {
    return '$days-day streak!';
  }

  @override
  String get streakMilestoneBody =>
      'Keep it up. Come back tomorrow to extend it.';

  @override
  String get perfectScoreMilestoneTitle => 'Perfect score!';

  @override
  String get perfectScoreMilestoneBody =>
      'You answered every question correctly.';

  @override
  String practiceXpEarned(String xp) {
    return '+$xp XP';
  }
}
