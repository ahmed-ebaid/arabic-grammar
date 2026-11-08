class AlfiyyaReading {
  const AlfiyyaReading(this.verse, this.ar, this.en);

  final String verse;
  final String ar;
  final String en;
}

const alfiyyaReadings = <String, List<AlfiyyaReading>>{
  'lesson_07': [
    AlfiyyaReading(
      'كَلاَمُنَا لَفْظٌ مُفِيدٌ كَاسْتَقِمْ\nوَاسْمٌ وَفِعْلٌ ثُمَّ حَرْفٌ الْكَلِمْ',
      'الكلام المفيد مثل «استقم»، وأقسام الكلمة اسم وفعل وحرف.',
      'A meaningful expression can be as short as “استقم”. Words are nouns, verbs, or particles.',
    ),
    AlfiyyaReading(
      'بِالْجَرِّ وَالتَّنْوِينِ وَالنِّدَا وَأَلْ\nوَمُسْنَدٍ لِلاسْمِ تَمْيِيزٌ حَصَلْ',
      'من علامات الاسم الجر والتنوين والنداء وقبول «الـ» التعريف والإسناد إليه.',
      'Nouns can be recognized by signs including jarr, tanwin, the vocative, the definite article, and predication.',
    ),
    AlfiyyaReading(
      'مُبْتَدَأٌ زَيْدٌ وَعَاذِرٌ خَبَرْ\nإِنْ قُلْتَ زَيْدٌ عَاذِرٌ مَنِ اعْتَذَرْ',
      'في «زيدٌ عاذرٌ من اعتذر»، «زيدٌ» مبتدأ و«عاذرٌ» خبر، وكلاهما مرفوع.',
      'In the example, زيد is the topic and عاذر is its predicate; both are in raf.',
    ),
  ],
  'lesson_15': [
    AlfiyyaReading(
      'نَكِرَةٌ قَابِلُ أَلْ مُؤَثِّرَا\nأَوْ وَاقِعٌ مَوْقِعَ مَا قَدْ ذُكِرَا',
      'من علامات النكرة قبول «الـ» التي تفيد التعريف، مثل «كتاب» و«الكتاب»، أو وقوعها موقع ما يقبلها.',
      'An indefinite noun may accept the definite article, like كتاب and الكتاب, or stand in place of one that does.',
    ),
    AlfiyyaReading(
      'بذا لمفرد مذكر أشر\nبذي وذه تا على الأنثى اقتصر',
      'يذكر البيت ألفاظًا للإشارة إلى المفرد المذكر والمؤنث؛ ومن صيغها المألوفة «هذا» و«هذه».',
      'The verse gives demonstratives for a masculine or feminine singular; familiar forms include هذا and هذه.',
    ),
    AlfiyyaReading(
      'وذان تان للمثنى المرتفع\nوفي سواه ذين تين اذكر تطع',
      'للمثنى «ذانِ» و«تانِ» في الرفع، و«ذينِ» و«تينِ» في النصب والجر.',
      'For the dual, ذان and تان are used in raf, and ذين and تين in nasb and jarr.',
    ),
  ],
  'lesson_24': [
    AlfiyyaReading(
      'بِتَا فَعَلْتُ وَأَتَتْ وَيَا افْعَلِي\nوَنُونِ أَقْبِلَنَّ فِعْلٌ يَنْجَلِي',
      'من علامات الفعل تاء الفاعل وتاء التأنيث الساكنة وياء المخاطبة ونون التوكيد.',
      'Verb markers include the subject tāʾ, the silent feminine tāʾ, the addressee yāʾ, and the emphatic nūn.',
    ),
    AlfiyyaReading(
      'سواهما الحرف كهل وفي ولم\nفعل مضارع يلي لم كيشم',
      'من الحروف «لم»، وهي تدخل على الفعل المضارع وتجزمُه، مثل «لم يشمْ».',
      'The particle لم precedes a present-tense verb and puts it in jazm, as in لم يشمْ.',
    ),
    AlfiyyaReading(
      'وماضي الأفعال بتا مز وسم\nبالنون فعل الأمر إن أمر فهم',
      'يميّز البيت الماضي بقبول تاء التأنيث الساكنة، والأمر بدلالته على الطلب وقبوله نون التوكيد.',
      'The verse identifies the past by the silent feminine tāʾ and the imperative by a command meaning and the emphatic nūn.',
    ),
  ],
  'lesson_33': [
    AlfiyyaReading(
      'الظرف وقت أو مكان ضمنا\nفي باطراد كهنا امكث أزمنا',
      'الظرف اسم وقت أو مكان يتضمن معنى «في» على الوجه المذكور؛ ففي «مكثتُ يومًا» يدل «يومًا» على زمان المكث.',
      'An adverb of time or place conveys the sense of “in”; in مكثتُ يومًا, يومًا indicates when the stay occurred.',
    ),
    AlfiyyaReading(
      'مُبْتَدَأٌ زَيْدٌ وَعَاذِرٌ خَبَرْ\nإِنْ قُلْتَ زَيْدٌ عَاذِرٌ مَنِ اعْتَذَرْ',
      'في «زيدٌ عاذرٌ من اعتذر»، «من» اسم موصول بمعنى الذي، وجملة «اعتذر» صلته.',
      'In this example, من is a relative pronoun and اعتذر is its relative clause.',
    ),
  ],
  'lesson_41': [
    AlfiyyaReading(
      'كفاعل صغ اسم فاعل إذا\nمن ذي ثلاثة يكون كغذا',
      'يبيّن البيت صياغة اسم الفاعل من الثلاثي على وزن «فاعل»، مثل «كاتب» من «كتب».',
      'The active participle of a triliteral verb can follow the pattern فاعل, like كاتب from كتب.',
    ),
    AlfiyyaReading(
      'وفي اسم مفعول الثلاثي اطرد\nزنة مفعول كآت من قصد',
      'اسم المفعول من الثلاثي على وزن «مفعول»، مثل «مكتوب» من «كتب».',
      'The passive participle of a triliteral verb follows the pattern مفعول, like مكتوب from كتب.',
    ),
    AlfiyyaReading(
      'وغير ذي ثلاثة مقيس\nمصدره كقدّس التقديس',
      'لمصادر الأفعال غير الثلاثية أوزان مقيسة، مثل «قدّس» ومصدره «التقديس».',
      'Verbal nouns of longer verbs follow established patterns, such as تقديس from قدّس.',
    ),
  ],
  'lesson_50': [
    AlfiyyaReading(
      'لولا ولوما يلزمان الابتدا\nإذا امتناعًا بوجود عقدا',
      'يأتي المبتدأ بعد «لولا» و«لوما» حين تفيدان امتناع شيء لوجود غيره، مثل «لولا الماء لهلك الزرع».',
      'When لولا and لوما express that one thing is prevented by another, they are followed by a topic.',
    ),
    AlfiyyaReading(
      'أمّا كمهما يك من شيء وفا\nلتلو تلوها وجوبًا ألفا',
      'تتضمن «أمّا» معنى الشرط وتقترن الفاء بجوابها، مثل «أمّا المجتهدُ فينجحُ».',
      'أمّا has a conditional sense and its response is introduced by ف, as in أمّا المجتهدُ فينجحُ.',
    ),
  ],
  'lesson_58': [
    AlfiyyaReading(
      'كَلاَمُنَا لَفْظٌ مُفِيدٌ كَاسْتَقِمْ\nوَاسْمٌ وَفِعْلٌ ثُمَّ حَرْفٌ الْكَلِمْ',
      'مراجعة: الكلام المفيد مثل «استقم»، وأقسام الكلمة اسم وفعل وحرف.',
      'Review: meaningful speech can be as short as استقم; words are nouns, verbs, or particles.',
    ),
    AlfiyyaReading(
      'بِالْجَرِّ وَالتَّنْوِينِ وَالنِّدَا وَأَلْ\nوَمُسْنَدٍ لِلاسْمِ تَمْيِيزٌ حَصَلْ',
      'مراجعة: من علامات الاسم الجر والتنوين والنداء وقبول «الـ» التعريف والإسناد إليه.',
      'Review: nouns can be recognized by jarr, tanwin, the vocative, the definite article, and predication.',
    ),
    AlfiyyaReading(
      'بِتَا فَعَلْتُ وَأَتَتْ وَيَا افْعَلِي\nوَنُونِ أَقْبِلَنَّ فِعْلٌ يَنْجَلِي',
      'مراجعة: من علامات الفعل تاء الفاعل وتاء التأنيث الساكنة وياء المخاطبة ونون التوكيد.',
      'Review: verb markers include the subject tāʾ, silent feminine tāʾ, addressee yāʾ, and emphatic nūn.',
    ),
    AlfiyyaReading(
      'مُبْتَدَأٌ زَيْدٌ وَعَاذِرٌ خَبَرْ\nإِنْ قُلْتَ زَيْدٌ عَاذِرٌ مَنِ اعْتَذَرْ',
      'مراجعة: «زيدٌ» مبتدأ و«عاذرٌ» خبر في مثال ابن مالك.',
      'Review: زيد is the topic and عاذر is the predicate in Ibn Malik’s example.',
    ),
  ],
};
