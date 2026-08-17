// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'إعراب';

  @override
  String get homeTab => 'الرئيسية';

  @override
  String get lessonsTab => 'الدروس';

  @override
  String get practiceTab => 'التدريب';

  @override
  String get progressTab => 'التقدم';

  @override
  String get welcomeTitle => 'تعلَّم لماذا تتغيَّر أواخر الكلمات';

  @override
  String get welcomeBody =>
      'ابنِ أساسًا نحويًّا يساعدك على قراءة العربية قراءة صحيحة، حتى عندما لا تُكتب الحركات.';

  @override
  String get exampleLabel => 'نظرة أولى';

  @override
  String get exampleSentence => 'الطَّالِبُ مُجْتَهِدٌ';

  @override
  String get exampleExplanation =>
      'انتهت الكلمتان بالضمة لأن هذه جملة اسمية بسيطة.';

  @override
  String get startLearning => 'ابدأ التعلُّم';

  @override
  String get moduleTitle => 'أساسيات المبتدئين';

  @override
  String get moduleSubtitle => '٥٩ درسًا إرشاديًّا';

  @override
  String get comingSoon => 'سيُضاف محتوى المنهج في المرحلة التالية.';

  @override
  String lessonNumber(int number) {
    return 'الدرس $number';
  }

  @override
  String estimatedMinutes(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String get objectivesTitle => 'ماذا ستتعلَّم؟';

  @override
  String get vocalizedLabel => 'بالحركات';

  @override
  String get unvocalizedLabel => 'دون حركات';

  @override
  String get wordAnalysisTitle => 'تحليل الكلمات';

  @override
  String get roleLabel => 'الوظيفة';

  @override
  String get stateLabel => 'الحالة';

  @override
  String get signLabel => 'العلامة';

  @override
  String get endingLabel => 'حركة الآخر';

  @override
  String get reasonLabel => 'السبب';

  @override
  String get lessonPracticeTitle => 'جرِّب';

  @override
  String get contentLoadError => 'تعذَّر تحميل الدرس.';

  @override
  String get continueLabel => 'تابع';

  @override
  String get checkAnswer => 'تحقَّق من الإجابة';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get quickCheckTitle => 'تحقُّق سريع';

  @override
  String get chooseTopicPrompt => 'أيُّ كلمة هي المبتدأ؟';

  @override
  String get correctAnswerTitle => 'أحسنت!';

  @override
  String get incorrectAnswerTitle => 'ليس بعد';

  @override
  String get exploreWordsTitle => 'استكشف الجملة';

  @override
  String get exploreWordsBody =>
      'اضغط على كل كلمة لترى وظيفتها وحالتها وعلامتها وحركة آخرها وسبب إعرابها.';

  @override
  String get lessonCompleteTitle => 'أتممت الدرس!';

  @override
  String get lessonCompleteBody =>
      'لاحظتَ كيف يمكن لحركة آخر الكلمة أن تدل على وظيفتها في الجملة.';

  @override
  String get restartLesson => 'تدرَّب مرة أخرى';

  @override
  String get returnToLessons => 'العودة إلى الدروس';

  @override
  String stepProgress(int current, int total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get practiceTitle => 'التدريب';

  @override
  String get practiceSubtitle => 'ستُفتح التدريبات مع كل درس.';

  @override
  String get practiceFamilySubtitle =>
      'قوِّ مهارتك النحوية، واجمع النجوم، وافتح الشارات سؤالًا بعد سؤال.';

  @override
  String get practiceDailyGoalTitle => 'هدف اليوم';

  @override
  String practiceDailyGoalProgress(int current, int goal) {
    return '$current من $goal أسئلة';
  }

  @override
  String get practiceMixedTitle => 'مراجعة متنوعة';

  @override
  String get practiceMixedBody =>
      'راجع أسئلة متنوعة من الدروس التي فتحتها أو بدأت بها.';

  @override
  String get practiceWeakAreasTitle => 'تقوية مواطن الضعف';

  @override
  String get practiceWeakAreasBody =>
      'ابدأ بمراجعات اليوم، ثم بالدروس التي يقل إتقانها عن ٧٠٪ وبأنواع الأسئلة التي أخطأت فيها سابقًا.';

  @override
  String get practiceRewardsTitle => 'شاراتك';

  @override
  String get practiceBadgeFirstSteps => 'الخطوات الأولى';

  @override
  String get practiceBadgePerfect => 'عشرة كاملة';

  @override
  String get practiceBadgeHabit => 'عادة التدريب';

  @override
  String get practiceBadgeGrammarStar => 'نجم النحو';

  @override
  String get practiceCompleteTitle => 'أتممت التدريب!';

  @override
  String practiceScore(int correct, int total) {
    return '$correct إجابات صحيحة من $total';
  }

  @override
  String practiceStarsEarned(int stars) {
    return 'حصلت على $stars نجوم';
  }

  @override
  String get practiceAgain => 'تدرّب مرة أخرى';

  @override
  String get progressTitle => 'تقدُّمك';

  @override
  String get progressSubtitle => 'سيبقى تقدُّمك التعليمي على هذا الجهاز.';

  @override
  String progressCurriculumSummary(int mastered, int total) {
    return 'أتقنت $mastered درسًا من أصل $total';
  }

  @override
  String get progressLessonsStarted => 'الدروس التي بدأتها';

  @override
  String get progressPracticeStars => 'نجوم التدريب';

  @override
  String get progressDailyGoal => 'هدف اليوم';

  @override
  String get progressPracticeAccuracy => 'دقة التدريب';

  @override
  String get progressLevelsTitle => 'التقدّم حسب المستوى';

  @override
  String progressAverageMastery(int percent) {
    return 'متوسط الإتقان: $percent٪';
  }

  @override
  String progressNextLesson(String lesson) {
    return 'التالي: $lesson';
  }

  @override
  String get aboutTitle => 'عن التطبيق وشكر المساهمين';

  @override
  String get aboutPurposeTitle => 'هدفنا';

  @override
  String get aboutPurposeBody =>
      'يعلّم تطبيق «إعراب» المتعلّم كيف يستدلّ بالنحو وبنية الكلمة والسياق على حركة آخرها. وتنتقل الدروس تدريجيًّا من الأمثلة المشكولة إلى القراءة المستقلة دون حركات.';

  @override
  String get aboutCompanyTitle => 'تطوير ونشر شركة Ebaid LLC';

  @override
  String get aboutCompanyBody =>
      'تطوّر شركة Ebaid LLC تقنيات تعليمية عملية تجعل التعلّم المنظّم أيسر وصولًا. وقد أنشأت الشركة تطبيق «إعراب» وتنشره، بما في ذلك برمجياته الأصلية وشروح دروسه وأمثلته وترجماته وتعليقاته وتمارينه.';

  @override
  String get aboutResourcesTitle => 'المصادر ونسب الفضل';

  @override
  String get aboutReviewersTitle => 'المعلّمون المراجعون';

  @override
  String get aboutReviewersPending =>
      'ستُذكر هنا أسماء المعلّمين المؤهلين الذين يعتمدون محتوى المنهج، بعد الحصول على إذنهم. وما زالت دروس النسخة التجريبية قيد المراجعة.';

  @override
  String get aboutContentStatusTitle => 'حالة المحتوى';

  @override
  String get aboutContentVersion => 'إصدار المنهج';

  @override
  String get aboutDisclaimer =>
      'هذا التطبيق وسيلة تعليمية ولا يغني عن المعلّم المؤهل. وقد تتغيّر التحليلات الأولية أثناء المراجعة.';

  @override
  String get aboutContactTitle => 'الدعم والمعلومات القانونية';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get close => 'إغلاق';

  @override
  String get more => 'المزيد';

  @override
  String get glossaryTitle => 'معجم النحو';

  @override
  String get glossarySearchHint =>
      'ابحث بالعربية أو الإنجليزية أو النقل الصوتي';

  @override
  String get glossaryNoResults => 'لا توجد مصطلحات نحوية مطابقة.';

  @override
  String glossaryLessonLinks(int count) {
    return 'مرتبط بـ $count دروس';
  }

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get bookmarksTitle => 'العناصر المحفوظة';

  @override
  String get bookmarksEmpty =>
      'احفظ درسًا أو مثالًا محللًا أو مصطلحًا لتجده هنا.';

  @override
  String get bookmarkedLessons => 'الدروس المحفوظة';

  @override
  String get bookmarkedExamples => 'الأمثلة المحفوظة';

  @override
  String get bookmarkedTerms => 'مصطلحات المعجم المحفوظة';

  @override
  String get addBookmark => 'حفظ';

  @override
  String get removeBookmark => 'إزالة من المحفوظات';

  @override
  String get listen => 'استمع';

  @override
  String get textSizeTitle => 'حجم النص';

  @override
  String get textSizeBody =>
      'اختر حجمًا مريحًا للقراءة. يسري هذا الإعداد على التطبيق كله.';

  @override
  String get textSizeSmall => 'صغير';

  @override
  String get textSizeDefault => 'افتراضي';

  @override
  String get textSizeLarge => 'كبير';

  @override
  String get textSizeLargest => 'الأكبر';

  @override
  String get learningIllustrationLabel => 'بطاقة مبهجة لتعلّم العربية';

  @override
  String get celebrationIllustrationLabel => 'احتفال ملوّن بإنجاز نحوي';
}
