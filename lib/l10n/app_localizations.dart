import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'إعراب'**
  String get appName;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @lessonsTab.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessonsTab;

  /// No description provided for @practiceTab.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceTab;

  /// No description provided for @progressTab.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTab;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn why Arabic endings change'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Build the grammar instincts to read Arabic correctly, even when the vowel marks are not written.'**
  String get welcomeBody;

  /// No description provided for @exampleLabel.
  ///
  /// In en, this message translates to:
  /// **'A first look'**
  String get exampleLabel;

  /// No description provided for @exampleSentence.
  ///
  /// In en, this message translates to:
  /// **'الطَّالِبُ مُجْتَهِدٌ'**
  String get exampleSentence;

  /// No description provided for @exampleExplanation.
  ///
  /// In en, this message translates to:
  /// **'Both words end with damma because this is a basic nominal sentence.'**
  String get exampleExplanation;

  /// No description provided for @startLearning.
  ///
  /// In en, this message translates to:
  /// **'Start learning'**
  String get startLearning;

  /// No description provided for @moduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Beginner foundations'**
  String get moduleTitle;

  /// No description provided for @moduleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'59 guided lessons'**
  String get moduleSubtitle;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Curriculum content is coming in the next phase.'**
  String get comingSoon;

  /// No description provided for @lessonNumber.
  ///
  /// In en, this message translates to:
  /// **'Lesson {number}'**
  String lessonNumber(int number);

  /// No description provided for @estimatedMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String estimatedMinutes(int minutes);

  /// No description provided for @objectivesTitle.
  ///
  /// In en, this message translates to:
  /// **'What you will learn'**
  String get objectivesTitle;

  /// No description provided for @vocalizedLabel.
  ///
  /// In en, this message translates to:
  /// **'With vowel marks'**
  String get vocalizedLabel;

  /// No description provided for @unvocalizedLabel.
  ///
  /// In en, this message translates to:
  /// **'Without vowel marks'**
  String get unvocalizedLabel;

  /// No description provided for @wordAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Word analysis'**
  String get wordAnalysisTitle;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @stateLabel.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get stateLabel;

  /// No description provided for @signLabel.
  ///
  /// In en, this message translates to:
  /// **'Sign'**
  String get signLabel;

  /// No description provided for @endingLabel.
  ///
  /// In en, this message translates to:
  /// **'Ending'**
  String get endingLabel;

  /// No description provided for @reasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Why'**
  String get reasonLabel;

  /// No description provided for @lessonPracticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Try it'**
  String get lessonPracticeTitle;

  /// No description provided for @contentLoadError.
  ///
  /// In en, this message translates to:
  /// **'The lesson could not be loaded.'**
  String get contentLoadError;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @checkAnswer.
  ///
  /// In en, this message translates to:
  /// **'Check answer'**
  String get checkAnswer;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @quickCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick check'**
  String get quickCheckTitle;

  /// No description provided for @chooseTopicPrompt.
  ///
  /// In en, this message translates to:
  /// **'Which word is the topic (mubtada)?'**
  String get chooseTopicPrompt;

  /// No description provided for @correctAnswerTitle.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correctAnswerTitle;

  /// No description provided for @incorrectAnswerTitle.
  ///
  /// In en, this message translates to:
  /// **'Not quite yet'**
  String get incorrectAnswerTitle;

  /// No description provided for @exploreWordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore the sentence'**
  String get exploreWordsTitle;

  /// No description provided for @exploreWordsBody.
  ///
  /// In en, this message translates to:
  /// **'Tap each word to see its role, state, sign, ending, and reason.'**
  String get exploreWordsBody;

  /// No description provided for @lessonCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson complete!'**
  String get lessonCompleteTitle;

  /// No description provided for @lessonCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'You noticed how word endings can reveal a word\'s job in a sentence.'**
  String get lessonCompleteBody;

  /// No description provided for @restartLesson.
  ///
  /// In en, this message translates to:
  /// **'Practice again'**
  String get restartLesson;

  /// No description provided for @returnToLessons.
  ///
  /// In en, this message translates to:
  /// **'Back to lessons'**
  String get returnToLessons;

  /// No description provided for @stepProgress.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepProgress(int current, int total);

  /// No description provided for @practiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceTitle;

  /// No description provided for @practiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Exercises will unlock with each lesson.'**
  String get practiceSubtitle;

  /// No description provided for @practiceFamilySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Build your grammar strength, earn stars, and unlock badges—one question at a time.'**
  String get practiceFamilySubtitle;

  /// No description provided for @practiceDailyGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s goal'**
  String get practiceDailyGoalTitle;

  /// No description provided for @practiceDailyGoalProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} of {goal} questions'**
  String practiceDailyGoalProgress(int current, int goal);

  /// No description provided for @practiceMixedTitle.
  ///
  /// In en, this message translates to:
  /// **'Mixed review'**
  String get practiceMixedTitle;

  /// No description provided for @practiceMixedBody.
  ///
  /// In en, this message translates to:
  /// **'Review varied questions from lessons you have unlocked or attempted.'**
  String get practiceMixedBody;

  /// No description provided for @practiceWeakAreasTitle.
  ///
  /// In en, this message translates to:
  /// **'Strengthen weak areas'**
  String get practiceWeakAreasTitle;

  /// No description provided for @practiceWeakAreasBody.
  ///
  /// In en, this message translates to:
  /// **'Review items due today first, then lessons below 70% mastery and question types you previously missed.'**
  String get practiceWeakAreasBody;

  /// No description provided for @practiceRewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your badges'**
  String get practiceRewardsTitle;

  /// No description provided for @practiceBadgeFirstSteps.
  ///
  /// In en, this message translates to:
  /// **'First Steps'**
  String get practiceBadgeFirstSteps;

  /// No description provided for @practiceBadgePerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect Ten'**
  String get practiceBadgePerfect;

  /// No description provided for @practiceBadgeHabit.
  ///
  /// In en, this message translates to:
  /// **'Practice Habit'**
  String get practiceBadgeHabit;

  /// No description provided for @practiceBadgeGrammarStar.
  ///
  /// In en, this message translates to:
  /// **'Grammar Star'**
  String get practiceBadgeGrammarStar;

  /// No description provided for @practiceCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice complete!'**
  String get practiceCompleteTitle;

  /// No description provided for @practiceScore.
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total} correct'**
  String practiceScore(int correct, int total);

  /// No description provided for @practiceStarsEarned.
  ///
  /// In en, this message translates to:
  /// **'You earned {stars} stars'**
  String practiceStarsEarned(int stars);

  /// No description provided for @practiceAgain.
  ///
  /// In en, this message translates to:
  /// **'Practice again'**
  String get practiceAgain;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Your progress'**
  String get progressTitle;

  /// No description provided for @progressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your learning progress will stay on this device.'**
  String get progressSubtitle;

  /// No description provided for @progressCurriculumSummary.
  ///
  /// In en, this message translates to:
  /// **'{mastered} of {total} lessons mastered'**
  String progressCurriculumSummary(int mastered, int total);

  /// No description provided for @progressLessonsStarted.
  ///
  /// In en, this message translates to:
  /// **'Lessons started'**
  String get progressLessonsStarted;

  /// No description provided for @progressPracticeStars.
  ///
  /// In en, this message translates to:
  /// **'Practice stars'**
  String get progressPracticeStars;

  /// No description provided for @progressDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get progressDailyGoal;

  /// No description provided for @progressPracticeAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Practice accuracy'**
  String get progressPracticeAccuracy;

  /// No description provided for @progressLevelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress by level'**
  String get progressLevelsTitle;

  /// No description provided for @progressAverageMastery.
  ///
  /// In en, this message translates to:
  /// **'Average mastery: {percent}%'**
  String progressAverageMastery(int percent);

  /// No description provided for @progressNextLesson.
  ///
  /// In en, this message translates to:
  /// **'Next: {lesson}'**
  String progressNextLesson(String lesson);

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About & credits'**
  String get aboutTitle;

  /// No description provided for @aboutPurposeTitle.
  ///
  /// In en, this message translates to:
  /// **'Our purpose'**
  String get aboutPurposeTitle;

  /// No description provided for @aboutPurposeBody.
  ///
  /// In en, this message translates to:
  /// **'إعراب teaches learners to infer Arabic word endings from grammar, word form, and context. Lessons move gradually from vocalized examples to independent reading without vowel marks.'**
  String get aboutPurposeBody;

  /// No description provided for @aboutCompanyTitle.
  ///
  /// In en, this message translates to:
  /// **'Developed by Ebaid LLC'**
  String get aboutCompanyTitle;

  /// No description provided for @aboutCompanyBody.
  ///
  /// In en, this message translates to:
  /// **'Ebaid LLC develops practical educational technology that makes structured learning more accessible. It created and publishes إعراب, including the app\'s original software, lesson explanations, examples, translations, feedback, and exercises.'**
  String get aboutCompanyBody;

  /// No description provided for @aboutResourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Resources and attribution'**
  String get aboutResourcesTitle;

  /// No description provided for @aboutReviewersTitle.
  ///
  /// In en, this message translates to:
  /// **'Teacher reviewers'**
  String get aboutReviewersTitle;

  /// No description provided for @aboutReviewersPending.
  ///
  /// In en, this message translates to:
  /// **'Qualified teachers who approve curriculum content will be credited here with their permission. Current beta lessons are still pending review.'**
  String get aboutReviewersPending;

  /// No description provided for @aboutContentStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Content status'**
  String get aboutContentStatusTitle;

  /// No description provided for @aboutContentVersion.
  ///
  /// In en, this message translates to:
  /// **'Curriculum version'**
  String get aboutContentVersion;

  /// No description provided for @aboutDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This app is a learning aid and does not replace instruction from a qualified Arabic teacher. Draft analyses may change during review.'**
  String get aboutDisclaimer;

  /// No description provided for @aboutContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Support and legal information'**
  String get aboutContactTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @glossaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Grammar glossary'**
  String get glossaryTitle;

  /// No description provided for @glossarySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search Arabic, English, or transliteration'**
  String get glossarySearchHint;

  /// No description provided for @glossaryNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching grammar terms.'**
  String get glossaryNoResults;

  /// No description provided for @glossaryLessonLinks.
  ///
  /// In en, this message translates to:
  /// **'Connected to {count} lessons'**
  String glossaryLessonLinks(int count);

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @bookmarksTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved items'**
  String get bookmarksTitle;

  /// No description provided for @bookmarksEmpty.
  ///
  /// In en, this message translates to:
  /// **'Bookmark a lesson, worked example, or glossary term to find it here.'**
  String get bookmarksEmpty;

  /// No description provided for @bookmarkedLessons.
  ///
  /// In en, this message translates to:
  /// **'Saved lessons'**
  String get bookmarkedLessons;

  /// No description provided for @bookmarkedExamples.
  ///
  /// In en, this message translates to:
  /// **'Saved examples'**
  String get bookmarkedExamples;

  /// No description provided for @bookmarkedTerms.
  ///
  /// In en, this message translates to:
  /// **'Saved glossary terms'**
  String get bookmarkedTerms;

  /// No description provided for @addBookmark.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get addBookmark;

  /// No description provided for @removeBookmark.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved items'**
  String get removeBookmark;

  /// No description provided for @listen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listen;

  /// No description provided for @textSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSizeTitle;

  /// No description provided for @textSizeBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a comfortable reading size. This setting applies throughout the app.'**
  String get textSizeBody;

  /// No description provided for @textSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get textSizeSmall;

  /// No description provided for @textSizeDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get textSizeDefault;

  /// No description provided for @textSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get textSizeLarge;

  /// No description provided for @textSizeLargest.
  ///
  /// In en, this message translates to:
  /// **'Largest'**
  String get textSizeLargest;

  /// No description provided for @learningIllustrationLabel.
  ///
  /// In en, this message translates to:
  /// **'A cheerful Arabic learning card'**
  String get learningIllustrationLabel;

  /// No description provided for @celebrationIllustrationLabel.
  ///
  /// In en, this message translates to:
  /// **'A colorful Arabic grammar celebration'**
  String get celebrationIllustrationLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
