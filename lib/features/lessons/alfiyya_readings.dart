import '../../core/models/content_models.dart';

class AlfiyyaReading {
  const AlfiyyaReading({
    required this.lessonId,
    required this.topic,
    required this.verse,
    required this.explanation,
    required this.example,
    this.details,
  });

  final String lessonId;
  final LocalizedText topic;
  final String verse;
  final LocalizedText explanation;
  final LocalizedText example;
  final LocalizedText? details;
}

const _wordClasses = AlfiyyaReading(
  lessonId: 'lesson_02',
  topic: LocalizedText(ar: 'أقسام الكلمة', en: 'Word classes'),
  verse: 'كلامنا لفظ مفيد كاستقم\nواسم وفعل ثم حرف الكلم',
  explanation: LocalizedText(
    ar: 'الكلام يفيد معنى تامًّا، وأقسام الكلمة اسم وفعل وحرف.',
    en: 'Speech conveys a complete meaning; words are nouns, verbs, or particles.',
  ),
  example: LocalizedText(
    ar: 'في «ذهبَ الطالبُ إلى المدرسةِ»: «ذهب» فعل، و«الطالب» اسم، و«إلى» حرف.',
    en: 'In ذهبَ الطالبُ إلى المدرسةِ: ذهب is a verb, الطالب a noun, and إلى a particle.',
  ),
);

const _topicAndPredicate = AlfiyyaReading(
  lessonId: 'lesson_03',
  topic: LocalizedText(ar: 'المبتدأ والخبر', en: 'Topic and predicate'),
  verse: 'مبتدأ زيد وعاذر خبر\nإن قلت زيد عاذر من اعتذر',
  explanation: LocalizedText(
    ar: 'في المثال الذي يذكره ابن مالك، «زيدٌ» مبتدأ و«عاذرٌ» خبر، وكلاهما مرفوع.',
    en: 'In Ibn Malik’s example, زيد is the topic and عاذر is its predicate; both are in raf.',
  ),
  example: LocalizedText(
    ar: 'الطالبُ مجتهدٌ: «الطالبُ» مبتدأ و«مجتهدٌ» خبر.',
    en: 'الطالبُ مجتهدٌ: الطالبُ is the topic (mubtada), and مجتهدٌ the predicate.',
  ),
);

const _nounSigns = AlfiyyaReading(
  lessonId: 'lesson_52',
  topic: LocalizedText(ar: 'علامات الاسم', en: 'Signs of a noun'),
  verse: 'بالجر والتنوين والندا وأل\nومسند للاسم تمييز حصل',
  explanation: LocalizedText(
    ar: 'من علامات الاسم الجر والتنوين والنداء وقبول «الـ» التعريف والإسناد إليه.',
    en: 'Nouns can be recognized by jarr, tanwin, the vocative, the definite article, and predication.',
  ),
  example: LocalizedText(
    ar: '«كتابٌ» يقبل التنوين، و«الكتابُ» يقبل «الـ» التعريف.',
    en: 'كتابٌ accepts tanwin, and الكتابُ accepts the definite article ال.',
  ),
);

const _verbSigns = AlfiyyaReading(
  lessonId: 'lesson_53',
  topic: LocalizedText(ar: 'علامات الفعل', en: 'Signs of a verb'),
  verse: 'بتا فعلت وأتت ويا افعلي\nونون أقبلن فعل ينجلي',
  explanation: LocalizedText(
    ar: 'من علامات الفعل تاء الفاعل وتاء التأنيث الساكنة وياء المخاطبة ونون التوكيد.',
    en: 'Verb markers include the subject ta, silent feminine ta, addressee ya, and emphatic nun.',
  ),
  example: LocalizedText(
    ar: 'كتبْتُ، وكتبَتْ، واكتبِي: علامات تدل على الفعل.',
    en: 'كتبْتُ, كتبَتْ, and اكتبِي contain markers that identify verbs.',
  ),
);

const _indefinite = AlfiyyaReading(
  lessonId: 'lesson_08',
  topic: LocalizedText(
    ar: 'النكرة والمعرفة',
    en: 'Indefinite and definite nouns',
  ),
  verse: 'نكرة قابل أل مؤثرا\nأو واقع موقع ما قد ذكرا',
  explanation: LocalizedText(
    ar: 'من علامات النكرة قبول «الـ» التي تفيد التعريف، أو وقوعها موقع ما يقبلها.',
    en: 'An indefinite noun may accept the defining article or stand in place of a noun that does.',
  ),
  example: LocalizedText(
    ar: 'كتابٌ ← الكتابُ: أفادت «الـ» التعريف.',
    en: 'كتابٌ becomes الكتابُ: ال makes the noun definite.',
  ),
);

const _idafaVerse =
    'نونا تلي الإعراب أو تنوينا\nمما تضيف احذف كطور سينا\nوالثاني اجرر وانو من أو في إذا\nلم يصلح إلا ذاك واللام خذا';

const _idafa = AlfiyyaReading(
  lessonId: 'lesson_12',
  topic: LocalizedText(ar: 'الإضافة', en: 'Idafa'),
  verse: _idafaVerse,
  explanation: LocalizedText(
    ar: 'يحذف التنوين أو نون المثنى والجمع من المضاف، ويجر المضاف إليه.',
    en: 'Idafa removes tanwin or the dual/plural nun from the first noun; the second noun is in jarr.',
  ),
  example: LocalizedText(
    ar: 'كتابُ الطالبِ، ومعلّما المدرسةِ: «الطالبِ» و«المدرسةِ» مضاف إليهما.',
    en: 'In كتابُ الطالبِ and معلّما المدرسةِ, الطالبِ and المدرسةِ are mudaf ilayh.',
  ),
  details: LocalizedText(
    ar: 'يشير باقي المقطع إلى العلاقات المعنوية بين الاسمين، التي قد يوضحها تقدير «من» أو «في» أو اللام. وليس المقصود إدخال حرف جر فعلي بين المضاف والمضاف إليه.',
    en: 'The remaining lines discuss semantic relationships suggested by min, fi, or li. These are interpretations, not prepositions actually inserted between the nouns.',
  ),
);

const alfiyyaReadings = <String, List<AlfiyyaReading>>{
  'lesson_07': [
    _wordClasses,
    _topicAndPredicate,
    AlfiyyaReading(
      lessonId: 'lesson_04',
      topic: LocalizedText(ar: 'الفعل والفاعل', en: 'Verb and subject'),
      verse: 'وبعد فعل فاعل فإن ظهر\nفهو وإلا فضمير استتر',
      explanation: LocalizedText(
        ar: 'للفعل فاعل؛ فقد يكون اسمًا ظاهرًا أو ضميرًا مستترًا يفهم من الفعل والسياق.',
        en: 'A verb has a subject, which may be explicit or an implicit pronoun understood from the verb and context.',
      ),
      example: LocalizedText(
        ar: 'كتبَ الطالبُ: الفاعل ظاهر. اكتبْ: الفاعل ضمير مستتر تقديره «أنت».',
        en: 'كتبَ الطالبُ has an explicit subject. In اكتبْ, the subject is the implied pronoun أنت.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_05',
      topic: LocalizedText(ar: 'المفعول به', en: 'Direct object'),
      verse: 'فانصب به مفعوله إن لم ينب\nعن فاعل نحو تدبرت الكتب',
      explanation: LocalizedText(
        ar: 'ينصب الفعل المتعدي مفعوله به، ما لم يقع المفعول نائبًا عن الفاعل في البناء للمجهول.',
        en: 'A transitive verb puts its direct object in nasb, unless the object takes the subject’s place in a passive construction.',
      ),
      example: LocalizedText(
        ar: 'قرأَ الطفلُ الكتابَ: «الكتابَ» مفعول به منصوب.',
        en: 'قرأَ الطفلُ الكتابَ: الكتابَ is a direct object in nasb.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_06',
      topic: LocalizedText(ar: 'حروف الجر', en: 'Prepositions'),
      verse:
          'هاك حروف الجر وهي من إلى\nحتى خلا حاشا عدا في عن على\nمذ منذ رب اللام كي واو وتا\nوالكاف والبا ولعل ومتى',
      explanation: LocalizedText(
        ar: 'يجمع المقطع حروف الجر. نركّز هنا على المألوف منها، مثل «من» و«إلى» و«في» و«على» والباء واللام.',
        en: 'The passage lists prepositions. Focus first on familiar ones such as min, ila, fi, ala, bi, and li.',
      ),
      example: LocalizedText(
        ar: 'ذهبَ الطالبُ إلى المدرسةِ: «المدرسةِ» اسم مجرور بـ«إلى».',
        en: 'ذهبَ الطالبُ إلى المدرسةِ: المدرسةِ is a noun in jarr after إلى.',
      ),
      details: LocalizedText(
        ar: 'ليست كل الألفاظ المذكورة شائعة بالقدر نفسه أو عاملة في كل سياق؛ فجر «لعل» و«متى» وارد في لغات عربية مخصوصة، ولـ«خلا» و«عدا» استعمالات فعلية أيضًا.',
        en: 'Not every listed word commonly acts as a preposition. Prepositional lalla and mata belong to particular dialectal usages; khala and ada can also be verbs.',
      ),
    ),
  ],
  'lesson_15': [
    _indefinite,
    AlfiyyaReading(
      lessonId: 'lesson_09',
      topic: LocalizedText(ar: 'المذكر والمؤنث', en: 'Masculine and feminine'),
      verse: 'علامة التأنيث تاء أو ألف\nوفي أسام قدروا التا كالكتف',
      explanation: LocalizedText(
        ar: 'من علامات التأنيث التاء والألف، وقد يكون الاسم مؤنثًا من غير علامة ظاهرة.',
        en: 'Feminine markers include ta and alif; some feminine nouns have no visible marker.',
      ),
      example: LocalizedText(
        ar: '«طالبة» فيها تاء التأنيث، و«شمس» مؤنثة بلا علامة ظاهرة.',
        en: 'طالبة has a feminine ta marker; شمس is feminine without a visible marker.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_10',
      topic: LocalizedText(ar: 'المثنى', en: 'The dual'),
      verse:
          'بالألف ارفع المثنى وكلا\nإذا بمضمر مضافا وصلا\nوتخلف اليا في جميعها الألف\nجرا ونصبا بعد فتح قد ألف',
      explanation: LocalizedText(
        ar: 'يرفع المثنى بالألف وينصب ويجر بالياء. والبيتان مختاران من مقطع أطول عن المثنى وملحقاته.',
        en: 'The dual is marked by alif in raf and ya in nasb and jarr. These selected verses come from a longer discussion of the dual.',
      ),
      example: LocalizedText(
        ar: 'جاءَ الطالبانِ، ورأيتُ الطالبَينِ، وسلّمتُ على الطالبَينِ.',
        en: 'جاءَ الطالبانِ, رأيتُ الطالبَينِ, and سلّمتُ على الطالبَينِ show the dual in raf, nasb, and jarr.',
      ),
      details: LocalizedText(
        ar: 'يرتبط حكم «كلا» في البيت بإضافتها إلى ضمير، مثل «كلاهما». و«في جميعها» يعود إلى ألفاظ سبق ذكرها في المقطع الكامل، لا إلى جميع الأسماء.',
        en: 'The rule for kila requires addition to a pronoun, as in كلاهما. “In all of them” refers to previously listed forms, not to all nouns.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_10',
      topic: LocalizedText(
        ar: 'جمع المذكر السالم',
        en: 'Sound masculine plural',
      ),
      verse: 'وارفع بواو وبيا اجرر وانصب\nسالم جمع عامر ومذنب',
      explanation: LocalizedText(
        ar: 'يرفع جمع المذكر السالم بالواو، وينصب ويجر بالياء.',
        en: 'The sound masculine plural uses waw in raf and ya in nasb and jarr.',
      ),
      example: LocalizedText(
        ar: 'حضرَ المعلّمونَ، ورأيتُ المعلّمينَ، وسلّمتُ على المعلّمينَ.',
        en: 'حضرَ المعلّمونَ, رأيتُ المعلّمينَ, and سلّمتُ على المعلّمينَ show the sound masculine plural in raf, nasb, and jarr.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_11',
      topic: LocalizedText(
        ar: 'مطابقة الصفة للموصوف',
        en: 'Adjective agreement',
      ),
      verse: 'وليعط في التعريف والتنكير ما\nلما تلا كامرر بقوم كرما',
      explanation: LocalizedText(
        ar: 'تتبع الصفة موصوفها في التعريف والتنكير، كما تعلمت في درس المطابقة.',
        en: 'An adjective agrees with the noun it describes in definiteness.',
      ),
      example: LocalizedText(
        ar: 'طالبٌ مجتهدٌ، والطالبُ المجتهدُ: الصفة توافق الموصوف في التعريف والتنكير.',
        en: 'In طالبٌ مجتهدٌ and الطالبُ المجتهدُ, the adjective agrees with the noun in definiteness.',
      ),
    ),
    _idafa,
    AlfiyyaReading(
      lessonId: 'lesson_13',
      topic: LocalizedText(ar: 'أسماء الإشارة', en: 'Demonstratives'),
      verse:
          'بذا لمفرد مذكر أشر\nبذي وذه تي تا على الأنثى اقتصر\nوذان تان للمثنى المرتفع\nوفي سواه ذين تين اذكر تطع',
      explanation: LocalizedText(
        ar: 'يذكر المقطع ألفاظ الإشارة للمفرد والمثنى. للمثنى «ذانِ» و«تانِ» في الرفع، و«ذينِ» و«تينِ» في النصب والجر.',
        en: 'The passage gives singular and dual demonstratives: dhan and tan in raf, and dhayn and tayn in nasb and jarr.',
      ),
      example: LocalizedText(
        ar: 'هذا طالبٌ، وهذه طالبةٌ، وهذانِ طالبانِ، ورأيتُ هذينِ الطالبَينِ.',
        en: 'هذا طالبٌ, هذه طالبةٌ, هذانِ طالبانِ, and رأيتُ هذينِ الطالبَينِ illustrate singular and dual demonstratives.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_14',
      topic: LocalizedText(ar: 'بناء الضمائر', en: 'Pronouns are indeclinable'),
      verse: 'وكل مضمر له البنا يجب\nولفظ ما جر كلفظ ما نصب',
      explanation: LocalizedText(
        ar: 'الضمائر مبنية، وقد يتغير محلها الإعرابي مع ثبات صورتها. وصور الضمائر المشتركة بين النصب والجر واحدة.',
        en: 'Pronouns are indeclinable: their grammatical position can change while their form remains fixed. Object and genitive pronoun forms coincide.',
      ),
      example: LocalizedText(
        ar: 'في «أكرمَني» الياء في محل نصب مفعول به، وفي «كتابي» في محل جر مضاف إليه.',
        en: 'In أكرمَني, the ya pronoun functions as a direct object in nasb; in كتابي, it functions as mudaf ilayh in jarr.',
      ),
    ),
  ],
  'lesson_24': [
    AlfiyyaReading(
      lessonId: 'lesson_16',
      topic: LocalizedText(
        ar: 'الماضي والمضارع والأمر',
        en: 'Past, present, and imperative',
      ),
      verse:
          'وفعل أمر ومضي بنيا\nوأعربوا مضارعا إن عريا\nمن نون توكيد مباشر ومن\nنون إناث كيرعن من فتن',
      explanation: LocalizedText(
        ar: 'الماضي والأمر مبنيان، والمضارع معرب في الأصل، إلا عند اتصاله بنون التوكيد المباشرة أو نون النسوة.',
        en: 'Past and imperative verbs are indeclinable. The present is normally inflected, except with a directly attached emphatic nun or the feminine plural nun.',
      ),
      example: LocalizedText(
        ar: 'كتبَ، واكتبْ؛ ويكتبُ، ولن يكتبَ، ولم يكتبْ.',
        en: 'Compare كتبَ and اكتبْ with يكتبُ, لن يكتبَ, and لم يكتبْ.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_17',
      topic: LocalizedText(
        ar: 'الضمير المستتر',
        en: 'Implicit subject pronouns',
      ),
      verse: 'ومن ضمير الرفع ما يستتر\nكافعل أوافق نغتبط إذ تشكر',
      explanation: LocalizedText(
        ar: 'قد لا يظهر الفاعل لفظًا؛ فتدل عليه صيغة الفعل والسياق.',
        en: 'A subject pronoun can be implicit, understood from the verb form and context.',
      ),
      example: LocalizedText(
        ar: 'أكتبُ: الفاعل ضمير مستتر تقديره «أنا».',
        en: 'In أكتبُ, the subject is the implied pronoun أنا.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_19',
      topic: LocalizedText(ar: 'الفعل المتعدي', en: 'Transitive verbs'),
      verse: 'علامة الفعل المعدى أن تصل\nهاء ضمير غير مصدر به نحو عمل',
      explanation: LocalizedText(
        ar: 'من علامات الفعل المتعدي اتصاله بهاء ضمير تعود على مفعول به، لا على مصدر الفعل.',
        en: 'One test for a transitive verb is attachment of an object pronoun ha referring to something other than the verb’s verbal noun.',
      ),
      example: LocalizedText(
        ar: 'قرأتُ الكتابَ ← قرأتُه: الهاء تعود على الكتاب.',
        en: 'قرأتُ الكتابَ becomes قرأتُه: the ha pronoun refers back to الكتاب.',
      ),
      details: LocalizedText(
        ar: 'البيت «والثان منهما كثاني اثني كسا» في سياق «أعلم وأرى»، وليس تعريفًا مستقلًّا للفعل ذي المفعولين. وللمقارنة: «أعطى المعلّمُ الطالبَ كتابًا» مفعولاه ليس أصلهما مبتدأ وخبرًا، بخلاف «ظننتُ الطالبَ مجتهدًا».',
        en: 'The line beginning والثان منهما belongs to the discussion of alama and ara, not a standalone definition of two-object verbs. Compare أعطى المعلم الطالب كتابا with ظننت الطالب مجتهدا: only the latter objects originate as topic and predicate.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_21',
      topic: LocalizedText(ar: 'نصب المضارع', en: 'Nasb of the present verb'),
      verse: 'وبلن انصبه وكي كذا بأن\nلا بعد علم والتي من بعد ظن',
      explanation: LocalizedText(
        ar: 'تنصب «لن» و«كي» و«أنْ» المصدرية الفعل المضارع.',
        en: 'Lan, kay, and the infinitival an put the present-tense verb in nasb.',
      ),
      example: LocalizedText(
        ar: 'لن أتأخرَ، وأريدُ أنْ أتعلّمَ.',
        en: 'لن أتأخرَ and أريدُ أنْ أتعلّمَ illustrate present-tense verbs after nasb particles.',
      ),
      details: LocalizedText(
        ar: 'يتصل آخر البيت والبيت التالي بالتمييز بين «أنْ» المصدرية و«أنْ» المخففة من الثقيلة بعد أفعال العلم والظن. نكتفي هنا بالأمثلة الواضحة للمصدرية، ولا نجعل الجزء الأخير قاعدة مستقلة.',
        en: 'The end of the verse continues into a distinction between infinitival an and an reduced from anna after verbs of knowing and supposing. The basic examples here use infinitival an.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_22',
      topic: LocalizedText(
        ar: 'الجزم والأمر والنهي',
        en: 'Jazm, commands, and prohibition',
      ),
      verse: 'بلا ولام طالبا ضع جزما\nفي الفعل هكذا بلم ولما',
      explanation: LocalizedText(
        ar: 'تجزم «لا» الناهية ولام الأمر و«لم» و«لمّا» الفعل المضارع. أما «لا» النافية فلا تجزمه.',
        en: 'Prohibitive la, the command lam, lam, and lamma put the present in jazm. Negative la does not.',
      ),
      example: LocalizedText(
        ar: 'لا تتأخرْ، ولْيكتبْ، ولم يكتبْ.',
        en: 'لا تتأخرْ, لْيكتبْ, and لم يكتبْ illustrate present-tense verbs in jazm.',
      ),
    ),
  ],
  'lesson_33': [
    AlfiyyaReading(
      lessonId: 'lesson_25',
      topic: LocalizedText(ar: 'كان وأخواتها', en: 'Kana and its sisters'),
      verse: 'ترفع كان المبتدا اسما والخبر\nتنصبه ككان سيدا عمر',
      explanation: LocalizedText(
        ar: 'ترفع كان اسمها وتنصب خبرها؛ وفي مثال البيت تقدم الخبر «سيدًا» على الاسم «عمرُ».',
        en: 'Kana puts its noun in raf and its predicate in nasb. In the verse’s example, the predicate precedes the noun.',
      ),
      example: LocalizedText(
        ar: 'كانَ الطالبُ مجتهدًا: «الطالبُ» اسم كان و«مجتهدًا» خبرها.',
        en: 'كانَ الطالبُ مجتهدًا: الطالبُ is the noun of kana, and مجتهدًا its predicate.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_26',
      topic: LocalizedText(ar: 'إنّ وأخواتها', en: 'Inna and its sisters'),
      verse: 'لإن أن ليت لكن لعل\nكأن عكس ما لكان من عمل',
      explanation: LocalizedText(
        ar: 'إنّ وأنّ وليت ولكنّ ولعلّ وكأنّ تنصب الاسم وترفع الخبر، بعكس عمل كان.',
        en: 'Inna, anna, layta, lakinna, lalla, and kaanna put their noun in nasb and their predicate in raf, reversing kana’s pattern.',
      ),
      example: LocalizedText(
        ar: 'إنّ الطالبَ مجتهدٌ: «الطالبَ» اسم إنّ و«مجتهدٌ» خبرها.',
        en: 'إنّ الطالبَ مجتهدٌ: الطالبَ is the noun of inna, and مجتهدٌ its predicate.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_27',
      topic: LocalizedText(ar: 'الأسماء الموصولة', en: 'Relative pronouns'),
      verse: 'موصول الأسماء الذي الأنثى التي\nواليا إذا ما ثنيا لا تثبت',
      explanation: LocalizedText(
        ar: '«الذي» للمفرد المذكر و«التي» للمفردة المؤنثة. وفي التثنية تأتي «اللذان» و«اللتان» رفعًا، و«اللذين» و«اللتين» نصبًا وجرًّا.',
        en: 'Alladhi and allati are singular relatives. Their duals are اللذان and اللتان in raf, and اللذين and اللتين in nasb and jarr.',
      ),
      example: LocalizedText(
        ar: 'جاءَ الطالبُ الذي نجحَ: «نجح» صلة الموصول.',
        en: 'جاءَ الطالبُ الذي نجحَ: نجح is the relative clause.',
      ),
      details: LocalizedText(
        ar: 'يشير حذف الياء إلى بناء صيغ التثنية من «الذي» و«التي»، وليس إلى حذف ياء «اللذين» و«اللتين» في النصب والجر.',
        en: 'Dropping ya refers to forming the dual from الذي and التي, not deleting the ya of اللذين or اللتين in nasb and jarr.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_28',
      topic: LocalizedText(ar: 'حروف العطف', en: 'Coordinating particles'),
      verse: 'تال بحرف متبع عطف النسق\nكاخصص بود وثناء من صدق',
      explanation: LocalizedText(
        ar: 'يتبع المعطوف ما قبله في الإعراب بواسطة حرف عطف، مثل الواو.',
        en: 'A coordinated word follows the grammatical case of the preceding word through a coordinating particle such as waw.',
      ),
      example: LocalizedText(
        ar: 'جاءَ خالدٌ وعليٌّ: «عليٌّ» معطوف مرفوع.',
        en: 'جاءَ خالدٌ وعليٌّ: عليٌّ is coordinated with خالدٌ and is in raf.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_29',
      topic: LocalizedText(
        ar: 'ظرف الزمان والمكان',
        en: 'Time and place adverbs',
      ),
      verse: 'الظرف وقت أو مكان ضمنا\nفي باطراد كهنا امكث أزمنا',
      explanation: LocalizedText(
        ar: 'يدل الظرف على زمان الحدث أو مكانه متضمنًا معنى «في» على الوجه المذكور.',
        en: 'An adverb indicates the time or place of an event, conveying the sense of “in” in the specified construction.',
      ),
      example: LocalizedText(
        ar: 'جلستُ أمامَ البيتِ صباحًا: «أمامَ» ظرف مكان و«صباحًا» ظرف زمان.',
        en: 'جلستُ أمامَ البيتِ صباحًا: أمامَ is an adverb of place, and صباحًا an adverb of time.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_30',
      topic: LocalizedText(ar: 'الحال', en: 'Circumstantial expressions'),
      verse: 'الحال وصف فضلة منتصب\nمفهم في حال كفردا أذهب',
      explanation: LocalizedText(
        ar: 'تبيّن الحال هيئة صاحبها عند وقوع الحدث، وتكون منصوبة في مثل هذه الأمثلة.',
        en: 'A circumstantial expression describes its referent’s condition during the event and is in nasb in these examples.',
      ),
      example: LocalizedText(
        ar: 'رجعَ الطالبُ مسرورًا: «مسرورًا» حال منصوبة.',
        en: 'رجعَ الطالبُ مسرورًا: مسرورًا is a circumstantial expression (hal) in nasb.',
      ),
      details: LocalizedText(
        ar: '«فضلة» مصطلح نحوي، ولا يعني أن الحال عديمة الأهمية للمعنى أو يجوز حذفها في كل سياق.',
        en: 'Fadla is a grammatical term, not a claim that the circumstance is unimportant or can always be omitted.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_31',
      topic: LocalizedText(ar: 'الاستثناء بإلّا', en: 'Exception with illa'),
      verse:
          'ما استثنت إلا مع تمام ينتصب\nوبعد نفي أو كنفي انتخب\nإتباع ما اتصل وانصب ما انقطع\nوعن تميم فيه إبدال وقع',
      explanation: LocalizedText(
        ar: 'ينصب المستثنى بإلّا في الاستثناء التام المثبت. وبعد النفي في الاستثناء المتصل يجوز الإتباع أو النصب، والإتباع مختار.',
        en: 'In a complete affirmative exception the excepted noun is in nasb. After negation, a connected exception may follow the antecedent’s case or take nasb; following is preferred.',
      ),
      example: LocalizedText(
        ar: 'حضرَ الطلابُ إلّا خالدًا: استثناء تام مثبت، فـ«خالدًا» منصوب.',
        en: 'حضرَ الطلابُ إلّا خالدًا is a complete affirmative exception construction, so خالدًا is in nasb.',
      ),
      details: LocalizedText(
        ar: '«ما حضرَ إلّا خالدٌ» استثناء مفرغ: «خالدٌ» فاعل مرفوع. أما بقية المقطع فتفصّل المتصل والمنقطع وبعض اختلاف الاستعمال.',
        en: 'In ما حضر إلا خالد, the exception is incomplete and خالد is the subject in raf. The remaining lines distinguish connected and disconnected exceptions and variations of usage.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_32',
      topic: LocalizedText(
        ar: 'العدد والمعدود',
        en: 'Numbers and counted nouns',
      ),
      verse:
          'ثلاثة بالتاء قل للعشرة\nفي عد ما آحاده مذكرة\nفي الضد جرد والمميز اجرر\nجمعا بلفظ قلة في الأكثر',
      explanation: LocalizedText(
        ar: 'تخالف الأعداد من ثلاثة إلى عشرة جنس مفرد المعدود، ويأتي المعدود جمعًا مجرورًا في هذا التركيب.',
        en: 'Numbers three through ten have the opposite gender to the singular counted noun; the counted noun is plural and in jarr.',
      ),
      example: LocalizedText(
        ar: 'ثلاثةُ كتبٍ وثلاثُ طالباتٍ: نراعي جنس المفرد «كتاب» و«طالبة».',
        en: 'In ثلاثةُ كتبٍ and ثلاثُ طالباتٍ, consider the gender of the singular nouns كتاب and طالبة.',
      ),
    ),
  ],
  'lesson_41': [
    AlfiyyaReading(
      lessonId: 'lesson_34',
      topic: LocalizedText(
        ar: 'الخبر وأنواعه',
        en: 'The predicate and its forms',
      ),
      verse:
          'والخبر الجزء المتم الفائدة\nكالله بر والأيادي شاهدة\nومفردا يأتي ويأتي جملة\nحاوية معنى الذي سيقت له',
      explanation: LocalizedText(
        ar: 'يتم الخبر معنى الجملة، وقد يكون مفردًا أو جملة؛ والبيتان مختاران من باب الابتداء.',
        en: 'The predicate completes the sentence’s meaning and may be a single expression or a clause. These are selected verses from the topic-and-predicate chapter.',
      ),
      example: LocalizedText(
        ar: 'الطالبُ مجتهدٌ، والطالبُ يقرأُ: الخبر مفرد في الأولى وجملة في الثانية.',
        en: 'In الطالبُ مجتهدٌ, the predicate is a single word; in الطالبُ يقرأُ, it is a clause.',
      ),
      details: LocalizedText(
        ar: '«مفرد» هنا يعني غير جملة ولا شبه جملة، وليس المقصود مقابلة المثنى والجمع.',
        en: 'Mufrad here means not a clause or prepositional/adverbial phrase; it does not mean singular rather than dual or plural.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_35',
      topic: LocalizedText(ar: 'نائب الفاعل', en: 'The passive subject'),
      verse: 'ينوب مفعول به عن فاعل\nفيما له كنيل خير نائل',
      explanation: LocalizedText(
        ar: 'في البناء للمجهول ينوب المفعول به عن الفاعل، فيصير مرفوعًا.',
        en: 'In the passive, the direct object takes the subject’s place and is in raf.',
      ),
      example: LocalizedText(
        ar: 'قرأَ الطالبُ الكتابَ ← قُرِئَ الكتابُ: «الكتابُ» نائب فاعل مرفوع.',
        en: 'قرأَ الطالبُ الكتابَ becomes قُرِئَ الكتابُ: الكتابُ is the passive subject (naib al-fail) in raf.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_36',
      topic: LocalizedText(ar: 'المصدر', en: 'The verbal noun'),
      verse: 'المصدر اسم ما سوى الزمان من\nمدلولي الفعل كأمن من أمن',
      explanation: LocalizedText(
        ar: 'يدل المصدر على الحدث دون أن يدل بصيغته على زمن معيّن، بخلاف الفعل.',
        en: 'A verbal noun names an event without encoding a particular tense, unlike a verb.',
      ),
      example: LocalizedText(
        ar: 'كتبَ ← كتابةٌ: «كتابة» مصدر يدل على الحدث.',
        en: 'كتبَ gives the verbal noun كتابةٌ, which denotes the action.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_36',
      topic: LocalizedText(
        ar: 'اسم الفاعل واسم المفعول',
        en: 'Active and passive participles',
      ),
      verse:
          'كفاعل صغ اسم فاعل إذا\nمن ذي ثلاثة يكون كغذا\nوفي اسم مفعول الثلاثي اطرد\nزنة مفعول كآت من قصد',
      explanation: LocalizedText(
        ar: 'بيتان مختاران من باب أبنية أسماء الفاعلين والمفعولين: من أمثلتهما «كاتب» و«مكتوب».',
        en: 'Two selected verses on participle formation: كاتب and مكتوب illustrate active and passive patterns.',
      ),
      example: LocalizedText(
        ar: 'كتبَ الكاتبُ رسالةً مكتوبةً: «الكاتب» اسم فاعل و«مكتوبة» اسم مفعول.',
        en: 'كتبَ الكاتبُ رسالةً مكتوبةً: الكاتب is an active participle, and مكتوبة a passive participle.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_37',
      topic: LocalizedText(ar: 'تعدد الإضافة', en: 'Chained idafa'),
      verse: _idafaVerse,
      explanation: LocalizedText(
        ar: 'في سلسلة الإضافة يكون الاسم الأوسط مضافًا إليه بالنسبة إلى ما قبله، ومضافًا بالنسبة إلى ما بعده.',
        en: 'In a chained idafa, the middle noun is genitive relative to the preceding noun and a possessor construction’s head relative to the following noun.',
      ),
      example: LocalizedText(
        ar: 'كتابُ طالبِ المدرسةِ: «طالبِ» مضاف إليه مجرور، وهو مضاف إلى «المدرسةِ».',
        en: 'In كتابُ طالبِ المدرسةِ, طالبِ is mudaf ilayh in jarr and is itself mudaf to المدرسةِ.',
      ),
    ),
  ],
  'lesson_50': [
    AlfiyyaReading(
      lessonId: 'lesson_42',
      topic: LocalizedText(
        ar: 'الترتيب ووضوح المعنى',
        en: 'Word order and clarity',
      ),
      verse: 'وأخر المفعول إن لبس حذر\nأو أضمر الفاعل غير منحصر',
      explanation: LocalizedText(
        ar: 'ليست حرية الترتيب مطلقة: إذا خيف اللبس وجب تأخير المفعول في موضع القاعدة.',
        en: 'Word order is not freely interchangeable: under this rule the object follows the subject when ambiguity would otherwise arise.',
      ),
      example: LocalizedText(
        ar: 'أكرمَ موسى عيسى: عند غياب القرينة نعدّ «موسى» فاعلًا و«عيسى» مفعولًا به.',
        en: 'In أكرمَ موسى عيسى, with no distinguishing clue, موسى is taken as the subject and عيسى as the direct object.',
      ),
      details: LocalizedText(
        ar: 'لا تظهر الحركات على آخر الاسمين المقصورين في المثال، ولذلك نحتاج إلى قرينة أو إلى الترتيب. ويذكر الشطر الثاني حالة الفاعل المضمر غير المحصور.',
        en: 'The case endings of these alif-final names are not visible, so context or ordering is needed. The second half addresses a non-restricted pronominal subject.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_43',
      topic: LocalizedText(
        ar: 'حذف المبتدأ أو الخبر',
        en: 'Omitting topic or predicate',
      ),
      verse:
          'وحذف ما يعلم جائز كما\nتقول زيد بعد من عندكما\nوفي جواب كيف زيد قل دنف\nفزيد استغني عنه إذ عرف',
      explanation: LocalizedText(
        ar: 'يجوز حذف ما يدل عليه السياق؛ فقد يحذف المبتدأ أو الخبر إذا كان مفهومًا.',
        en: 'Context can license omission of an understood topic or predicate.',
      ),
      example: LocalizedText(
        ar: 'كيفَ الطالبُ؟ مجتهدٌ. التقدير: «الطالبُ مجتهدٌ».',
        en: 'كيفَ الطالبُ؟ مجتهدٌ. The understood full answer is الطالبُ مجتهدٌ.',
      ),
      details: LocalizedText(
        ar: 'قال ابن مالك أيضًا: «وبعد لولا غالبا حذف الخبر / حتم وفي نص يمين ذا استقر». المراد بعد «لولا» خبر الكون العام، مثل «موجود»؛ أما الخبر الخاص فلا يعمم عليه الحذف.',
        en: 'The verse about omission after لولا concerns a general-existence predicate such as “exists”; it must not be generalized to every specific predicate.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_44',
      topic: LocalizedText(ar: 'الشرط وجوابه', en: 'Condition and result'),
      verse: 'فعلين يقتضين شرط قدما\nيتلو الجزاء وجوابا وسما',
      explanation: LocalizedText(
        ar: 'هذا بيت من سياق أدوات الشرط الجازمة: تطلب فعل الشرط وجوابه، مثل «إنْ».',
        en: 'In the context of jussive conditional particles such as إن, the verse describes a condition and its result.',
      ),
      example: LocalizedText(
        ar: 'إنْ تجتهدْ تنجحْ: «تجتهدْ» فعل الشرط و«تنجحْ» جوابه، وكلاهما مجزوم.',
        en: 'إنْ تجتهدْ تنجحْ: تجتهدْ is the conditional verb, and تنجحْ its response; both are in jazm.',
      ),
      details: LocalizedText(
        ar: 'ضمير «يقتضين» يعود إلى الأدوات المذكورة قبله في الألفية. لا يعني البيت أن كل أساليب الشرط تجزم، فـ«إذا» مثلًا ليست أداة جزم.',
        en: 'The pronoun refers to previously listed jussive particles. Not all conditional constructions are jussive; إذا is not a jussive particle.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_45',
      topic: LocalizedText(
        ar: 'التوكيد بالنفس والعين',
        en: 'Emphasis with nafs and ayn',
      ),
      verse: 'بالنفس أو بالعين الاسم أكدا\nمع ضمير طابق المؤكدا',
      explanation: LocalizedText(
        ar: 'يؤكد الاسم بـ«نفس» أو «عين» مع ضمير يعود إليه ويطابقه.',
        en: 'Nafs or ayn can emphasize a noun when accompanied by a matching pronoun referring to it.',
      ),
      example: LocalizedText(
        ar: 'حضرَ المعلّمُ نفسُه: «نفسُه» توكيد مرفوع.',
        en: 'حضرَ المعلّمُ نفسُه: نفسُه is an emphatic expression in raf.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_46',
      topic: LocalizedText(ar: 'الأفعال المعتلة', en: 'Weak-final verbs'),
      verse: 'وأي فعل آخر منه ألف\nأو واو أو ياء فمعتلا عرف',
      explanation: LocalizedText(
        ar: 'يتحدث البيت هنا عن الفعل المعتل الآخر، الذي ينتهي بألف أو واو أو ياء.',
        en: 'This verse concerns weak-final verbs ending in alif, waw, or ya.',
      ),
      example: LocalizedText(
        ar: 'يسعى ← لم يسعَ، ويدعو ← لم يدعُ، ويرمي ← لم يرمِ: حذف حرف العلة للجزم.',
        en: 'يسعى becomes لم يسعَ, يدعو becomes لم يدعُ, and يرمي becomes لم يرمِ: the final weak letter is deleted for jazm.',
      ),
      details: LocalizedText(
        ar: 'توجد أفعال معتلة غير معتلة الآخر، مثل «وعد» و«قال». أما «المصطفى» و«المرتقي» فاسمان مقصور ومنقوص، وليسا فعلين؛ فلا نخلط أحكامهما بأحكام الأفعال المعتلة.',
        en: 'Other weak verbs include وعد and قال. المصطفى and المرتقي are alif-final and ya-final nouns, not verbs; their inflection rules are distinct.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_47',
      topic: LocalizedText(ar: 'لولا وأمّا', en: 'Lawla and amma'),
      verse:
          'لولا ولوما يلزمان الابتدا\nإذا امتناعا بوجود عقدا\nأما كمهما يك من شيء وفا\nلتلو تلوها وجوبا ألفا',
      explanation: LocalizedText(
        ar: 'بيتان مختاران: تأتي «لولا» الامتناعية مع جملة اسمية، وتتضمن «أمّا» معنى الشرط وتقترن الفاء بجوابها.',
        en: 'Two selected verses: preventive lawla introduces a nominal construction; amma has a conditional sense and a response introduced by fa.',
      ),
      example: LocalizedText(
        ar: 'لولا الماءُ لهلكَ الزرعُ. أمّا المجتهدُ فينجحُ.',
        en: 'Compare لولا الماءُ لهلكَ الزرعُ with أمّا المجتهدُ فينجحُ.',
      ),
    ),
    AlfiyyaReading(
      lessonId: 'lesson_48',
      topic: LocalizedText(
        ar: 'الوصل والوقف',
        en: 'Connected speech and pausing',
      ),
      verse: 'تنوينا إثر فتح اجعل ألفا\nوقفا وتلو غير فتح احذفا',
      explanation: LocalizedText(
        ar: 'من أحكام الوقف إبدال تنوين الفتح ألفًا في مثل «كتابًا»، وحذف تنوين الضم والكسر عند الوقف.',
        en: 'When pausing on forms such as كتابا, accusative tanwin becomes alif; nominative and genitive tanwin are dropped.',
      ),
      example: LocalizedText(
        ar: 'نصل «كتابٌ» بالتنوين، ونقف عليها «كتابْ». ونقف على «كتابًا» بألف.',
        en: 'When continuing, pronounce the tanwin in كتابٌ; at a pause, read كتابْ. Pause on كتابًا with an alif sound.',
      ),
      details: LocalizedText(
        ar: 'لا نعمّم إبدال تنوين الفتح ألفًا على التاء المربوطة: نقف على «مدرسةً» بهاء ساكنة، لا بألف.',
        en: 'The alif replacement does not apply to ta marbuta: مدرسةً is paused on with a silent ha, not alif.',
      ),
    ),
  ],
  'lesson_58': [
    _wordClasses,
    _nounSigns,
    _verbSigns,
    _indefinite,
    _topicAndPredicate,
  ],
};
