import '../../core/models/content_models.dart';
import '../../core/models/glossary_models.dart';

class AlfiyyaGlossaryEntry {
  const AlfiyyaGlossaryEntry({
    required this.word,
    required this.transliteration,
    required this.meaning,
    required this.excerpt,
    required this.lessonId,
  });

  final String word;
  final String transliteration;
  final LocalizedText meaning;
  final String excerpt;
  final String lessonId;

  GlossaryTerm get searchable => GlossaryTerm(
    id: word,
    term: LocalizedText(ar: word, en: transliteration),
    transliteration: transliteration,
    definition: meaning,
    example: LocalizedText(ar: excerpt, en: excerpt),
    lessonIds: [lessonId],
  );
}

const alfiyyaGlossary = <AlfiyyaGlossaryEntry>[
  AlfiyyaGlossaryEntry(
    word: 'عاذر',
    transliteration: 'ʿādhir',
    meaning: LocalizedText(
      ar: 'من يقبل عذر غيره أو يلتمس له العذر.',
      en: 'One who accepts or makes an excuse for someone.',
    ),
    excerpt: 'زيد عاذر من اعتذر',
    lessonId: 'lesson_03',
  ),
  AlfiyyaGlossaryEntry(
    word: 'استتر',
    transliteration: 'istatar',
    meaning: LocalizedText(
      ar: 'اختفى؛ والضمير المستتر يُفهم من صيغة الفعل والسياق.',
      en: 'Was hidden; an implicit pronoun is understood from the verb and context.',
    ),
    excerpt: 'فضمير استتر',
    lessonId: 'lesson_04',
  ),
  AlfiyyaGlossaryEntry(
    word: 'ينب',
    transliteration: 'yanub',
    meaning: LocalizedText(
      ar: 'يقع مكان غيره؛ هنا: ينوب المفعول عن الفاعل.',
      en: 'Takes another’s place; here, the object takes the subject’s place.',
    ),
    excerpt: 'إن لم ينب',
    lessonId: 'lesson_05',
  ),
  AlfiyyaGlossaryEntry(
    word: 'هاك',
    transliteration: 'hāka',
    meaning: LocalizedText(
      ar: 'خُذ؛ تُستعمل لتنبيه المخاطب إلى ما يُقدَّم له.',
      en: 'Take or here is; used to draw attention to what follows.',
    ),
    excerpt: 'هاك حروف الجر',
    lessonId: 'lesson_06',
  ),
  AlfiyyaGlossaryEntry(
    word: 'أسام',
    transliteration: 'asām',
    meaning: LocalizedText(
      ar: 'أسماء؛ صيغة استعملها الناظم في الوزن.',
      en: 'Names or nouns; a form used by the poet to fit the meter.',
    ),
    excerpt: 'وفي أسام قدروا التا',
    lessonId: 'lesson_09',
  ),
  AlfiyyaGlossaryEntry(
    word: 'قدّروا',
    transliteration: 'qaddarū',
    meaning: LocalizedText(
      ar: 'اعتبروا شيئًا غير ظاهر؛ وفي البيت قدّروا علامة التأنيث في بعض الأسماء.',
      en: 'They assumed something not expressed; here, a feminine marker in some nouns.',
    ),
    excerpt: 'قدروا التا كالكتف',
    lessonId: 'lesson_09',
  ),
  AlfiyyaGlossaryEntry(
    word: 'مضمر',
    transliteration: 'muḍmar',
    meaning: LocalizedText(
      ar: 'ضمير؛ وفي «بمضمر مضافًا» المراد اتصال الإضافة بضمير.',
      en: 'A pronoun; here the expression concerns addition to a pronoun.',
    ),
    excerpt: 'إذا بمضمر مضافا وصلا',
    lessonId: 'lesson_10',
  ),
  AlfiyyaGlossaryEntry(
    word: 'أُلِف',
    transliteration: 'ulifa',
    meaning: LocalizedText(
      ar: 'عُرِف أو اعتيد؛ وليس المراد حرف الألف.',
      en: 'Was known or customary; not the name of the letter alif.',
    ),
    excerpt: 'بعد فتح قد ألف',
    lessonId: 'lesson_10',
  ),
  AlfiyyaGlossaryEntry(
    word: 'كرما',
    transliteration: 'kuramā',
    meaning: LocalizedText(
      ar: 'كرماء؛ وصفٌ للقوم في مثال النعت.',
      en: 'Generous people; an adjective describing the people in the verse.',
    ),
    excerpt: 'بقوم كرما',
    lessonId: 'lesson_11',
  ),
  AlfiyyaGlossaryEntry(
    word: 'وانو',
    transliteration: 'wanwi',
    meaning: LocalizedText(
      ar: 'وانوِ: قَدِّر في المعنى؛ لا يلزم التلفظ بحرف الجر.',
      en: 'And understand or infer in meaning; the preposition is not necessarily spoken.',
    ),
    excerpt: 'والثاني اجرر وانو',
    lessonId: 'lesson_12',
  ),
  AlfiyyaGlossaryEntry(
    word: 'تطع',
    transliteration: 'tuṭaʿ',
    meaning: LocalizedText(
      ar: 'تُطَع: يُستجب لك أو يُقبل منك.',
      en: 'Be obeyed or have your direction followed.',
    ),
    excerpt: 'اذكر تطع',
    lessonId: 'lesson_13',
  ),
  AlfiyyaGlossaryEntry(
    word: 'عَرِيَ',
    transliteration: 'ʿariya',
    meaning: LocalizedText(
      ar: 'خلا من الشيء؛ هنا: خلا المضارع من النونين المذكورتين في السياق.',
      en: 'Was free of something; here, the present verb is free of the two specified nuns.',
    ),
    excerpt: 'إن عريا',
    lessonId: 'lesson_16',
  ),
  AlfiyyaGlossaryEntry(
    word: 'نغتبط',
    transliteration: 'naghtabiṭ',
    meaning: LocalizedText(
      ar: 'نفرح ونُسَرّ.',
      en: 'We rejoice or feel pleased.',
    ),
    excerpt: 'أوافق نغتبط',
    lessonId: 'lesson_17',
  ),
  AlfiyyaGlossaryEntry(
    word: 'المعدّى',
    transliteration: 'al-muʿaddā',
    meaning: LocalizedText(
      ar: 'المتعدّي: الفعل الذي يتجاوز أثره الفاعل إلى مفعول به.',
      en: 'Transitive: a verb whose action extends to a direct object.',
    ),
    excerpt: 'الفعل المعدى',
    lessonId: 'lesson_19',
  ),
  AlfiyyaGlossaryEntry(
    word: 'تال',
    transliteration: 'tāl',
    meaning: LocalizedText(
      ar: 'تابع أو آتٍ بعد غيره؛ وفي البيت يتعلق بالكلمة التابعة بحرف عطف.',
      en: 'Following or coming after; here, a word follows another through a conjunction.',
    ),
    excerpt: 'تال بحرف متبع',
    lessonId: 'lesson_28',
  ),
  AlfiyyaGlossaryEntry(
    word: 'اطراد',
    transliteration: 'iṭṭirād',
    meaning: LocalizedText(
      ar: 'انتظام الحكم على وجهٍ متكرر؛ وفي البيت قيدٌ لتضمّن معنى «في».',
      en: 'Regularity of a pattern; here, a qualification on conveying the sense of “in.”',
    ),
    excerpt: 'في باطراد',
    lessonId: 'lesson_29',
  ),
  AlfiyyaGlossaryEntry(
    word: 'أزمنا',
    transliteration: 'azmunan',
    meaning: LocalizedText(
      ar: 'أوقاتًا أو مددًا زمنية.',
      en: 'Times or periods of time.',
    ),
    excerpt: 'امكث أزمنا',
    lessonId: 'lesson_29',
  ),
  AlfiyyaGlossaryEntry(
    word: 'فضلة',
    transliteration: 'faḍla',
    meaning: LocalizedText(
      ar: 'مصطلح لما ليس عمدة في التركيب؛ لا يعني أنه بلا فائدة أو يجوز حذفه دائمًا.',
      en: 'A grammatical term for a non-core constituent; it does not mean unimportant or always omissible.',
    ),
    excerpt: 'الحال وصف فضلة',
    lessonId: 'lesson_30',
  ),
  AlfiyyaGlossaryEntry(
    word: 'انتخب',
    transliteration: 'intakhab',
    meaning: LocalizedText(
      ar: 'اختر؛ وفي السياق يُختار الإتباع في الاستثناء المتصل بعد النفي.',
      en: 'Choose; here, following the antecedent’s case is preferred for a connected exception after negation.',
    ),
    excerpt: 'أو كنفي انتخب',
    lessonId: 'lesson_31',
  ),
  AlfiyyaGlossaryEntry(
    word: 'مفرد',
    transliteration: 'mufrad',
    meaning: LocalizedText(
      ar: 'في باب الخبر: ما ليس جملة ولا شبه جملة، سواء كان مفردًا أو مثنى أو جمعًا من حيث العدد.',
      en: 'For a predicate, an expression that is neither a clause nor a phrase; it need not be singular in number.',
    ),
    excerpt: 'ومفردا يأتي',
    lessonId: 'lesson_34',
  ),
  AlfiyyaGlossaryEntry(
    word: 'اطّرد',
    transliteration: 'iṭṭarid',
    meaning: LocalizedText(
      ar: 'سِر على القاعدة المطّردة في السياق المذكور.',
      en: 'Follow the regular pattern in the stated context.',
    ),
    excerpt: 'الثلاثي اطرد',
    lessonId: 'lesson_36',
  ),
  AlfiyyaGlossaryEntry(
    word: 'لَبْس',
    transliteration: 'labs',
    meaning: LocalizedText(
      ar: 'التباس المعنى أو اختلاط المقصود.',
      en: 'Ambiguity or confusion about the intended meaning.',
    ),
    excerpt: 'إن لبس حذر',
    lessonId: 'lesson_42',
  ),
  AlfiyyaGlossaryEntry(
    word: 'دَنِف',
    transliteration: 'danif',
    meaning: LocalizedText(
      ar: 'مريض؛ وهو الخبر في جواب «كيف زيد؟».',
      en: 'Ill; the predicate in the answer to “How is Zayd?”',
    ),
    excerpt: 'قل دنف',
    lessonId: 'lesson_43',
  ),
  AlfiyyaGlossaryEntry(
    word: 'وُسِم',
    transliteration: 'wusima',
    meaning: LocalizedText(
      ar: 'سُمّي أو وُصِف؛ وفي البيت سُمّي الجزاء جوابًا.',
      en: 'Was named or described; here, the result is named the response.',
    ),
    excerpt: 'وجوابا وسما',
    lessonId: 'lesson_44',
  ),
  AlfiyyaGlossaryEntry(
    word: 'إثر',
    transliteration: 'ithr',
    meaning: LocalizedText(
      ar: 'بعد؛ وفي البيت يأتي التنوين بعد الفتحة.',
      en: 'After; in the verse, tanwin follows a fatḥa.',
    ),
    excerpt: 'تنوينا إثر فتح',
    lessonId: 'lesson_48',
  ),
  AlfiyyaGlossaryEntry(
    word: 'تلو',
    transliteration: 'tilw',
    meaning: LocalizedText(
      ar: 'ما يلي الشيء أو يأتي بعده.',
      en: 'What follows or comes after something.',
    ),
    excerpt: 'وتلو غير فتح',
    lessonId: 'lesson_48',
  ),
];
