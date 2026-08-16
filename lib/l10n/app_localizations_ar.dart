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
  String get moduleSubtitle => '١٠ دروس إرشادية';

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
  String get progressTitle => 'تقدُّمك';

  @override
  String get progressSubtitle => 'سيبقى تقدُّمك التعليمي على هذا الجهاز.';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get close => 'إغلاق';
}
