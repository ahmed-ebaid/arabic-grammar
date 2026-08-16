# App Store Connect Beta Metadata

## App record

- Name: `إعراب`
- Bundle ID: `com.ebaidllc.arabicgrammar`
- SKU: `arabic-grammar-ios`
- Primary language: Arabic
- Version: `0.1.0`
- Build: `6`
- Primary category: Education
- Secondary category: Reference
- Age rating target: 4+
- Copyright: `2026 Ebaid LLC`

## URLs

- Marketing: `https://ahmed-ebaid.github.io/arabic-grammar/`
- Support: `https://ahmed-ebaid.github.io/arabic-grammar/support.html`
- Privacy: `https://ahmed-ebaid.github.io/arabic-grammar/privacy-policy.html`

These URLs will become available after the repository is made public and GitHub
Pages is enabled from the `docs/` directory.

## Arabic localization

### Subtitle

تعلّم إعراب أواخر الكلمات

### Promotional text

تعلّم لماذا تتغير أواخر الكلمات العربية، من خلال شرح مبسّط وأمثلة وتمارين تعمل دون اتصال بالإنترنت.

### Description

إعراب تطبيق تعليمي ثنائي اللغة يساعد المبتدئين على فهم أواخر الكلمات العربية وقراءتها قراءة صحيحة حتى عندما لا تكون الحركات مكتوبة.

يتدرج التطبيق من الشرح المبسّط إلى الأمثلة المحللة والتدريبات القصيرة. تتعلم من خلاله معنى الرفع والنصب والجر والجزم، ولماذا تأخذ الكلمة الضمة أو الفتحة أو الكسرة أو السكون، مع توضيح علامة الإعراب والسبب بلغة سهلة.

المزايا:
- واجهة عربية وإنجليزية
- دروس متدرجة للمبتدئين
- أمثلة مشكولة وغير مشكولة
- تدريبات واختبارات مع تفسير الإجابة
- عمل دون اتصال بالإنترنت
- حفظ التقدم على الجهاز دون إنشاء حساب

المحتوى التعليمي يخضع للمراجعة قبل نشره. التطبيق وسيلة تعليمية ولا يغني عن المعلم المؤهل.

### Keywords

إعراب,نحو,قواعد,عربي,تعليم,لغة,حركات,ضمة,فتحة,كسرة

## English localization

### Subtitle

Learn Arabic word endings

### Promotional text

Understand why Arabic word endings change through clear bilingual lessons, worked examples, and offline practice.

### Description

إعراب is a bilingual learning app that helps beginners understand Arabic word endings and read unvocalized Arabic more confidently.

Move from plain-language explanations to annotated examples and short practice activities. Learn the ideas behind nominative, accusative, genitive, and jussive forms; why a word takes damma, fatha, kasra, sukun, or a substitute grammatical sign; and how context governs the ending.

Features:
- Arabic and English interface
- Sequenced beginner lessons
- Vocalized and unvocalized examples
- Practice and quizzes with explanations
- Offline curriculum
- On-device progress with no account

Educational content is reviewed before release. The App is a learning aid and does not replace a qualified Arabic teacher.

### Keywords

Arabic,grammar,i3rab,nahw,language,learn,case,endings,vowels,education

## App Privacy

Select **Data Not Collected** for the curriculum beta. The current App has no
accounts, analytics, advertising, tracking, or network service and stores
settings and learning progress only on the device.

Review this answer before enabling any future AI analysis or other network
feature.

## TestFlight information

- Beta app description: Learn Arabic grammar and word endings through a
  bilingual, offline-first curriculum. Level 1 now has a Duolingo-style path
  with three interactive lessons, instant explanations, saved progress,
  mastery scoring, and 70% lesson unlocking.
- Feedback email: `ahmed@ebaidllc.com`
- Review contact:
  - First name: Ahmed
  - Last name: Ebaid
  - Phone: `+1 860 906 4530`
  - Email: `ahmed@ebaidllc.com`
- Sign-in required: No
- Review notes: No account is required. All current functionality is available
  offline. Open Lessons to review the Level 1 path. Complete "Why endings
  change" with at least 70% mastery to unlock "Noun, verb, or particle?", then
  continue to "The nominal sentence."

## Production release gate

Do not submit the app for production App Review until:

1. The beta curriculum is approved by a qualified Arabic grammar teacher.
2. The approved lessons are promoted into `assets/content/catalog.json`.
3. `dart run tool/validate_content.dart --release` passes.
4. The privacy, support, and terms URLs are publicly reachable.
