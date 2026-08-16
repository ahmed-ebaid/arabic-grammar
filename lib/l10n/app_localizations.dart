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
  /// **'10 guided lessons'**
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
