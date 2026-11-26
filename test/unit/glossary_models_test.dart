import 'package:arabic_grammar/core/content/glossary_repository.dart';
import 'package:arabic_grammar/core/models/content_models.dart';
import 'package:arabic_grammar/core/models/glossary_models.dart';
import 'package:flutter_test/flutter_test.dart';

GlossaryTerm term(String id, String ar, String en) => GlossaryTerm(
  id: id,
  term: LocalizedText(ar: ar, en: en),
  transliteration: id,
  definition: const LocalizedText(ar: 'تعريف', en: 'definition'),
  example: const LocalizedText(ar: 'مثال', en: 'example'),
  lessonIds: const [],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'sorts by the displayed language, ignoring Arabic articles and marks',
    () {
      final terms = [
        term('raf', 'الرَّفع', 'Raf'),
        term('plural', 'الجمع', 'Plural'),
        term('verb', 'الأفعال', 'Verbs'),
      ];

      terms.sort((a, b) => GlossaryTerm.compare(a, b, 'ar'));
      expect(terms.map((t) => t.id), ['verb', 'plural', 'raf']);

      terms.sort((a, b) => GlossaryTerm.compare(a, b, 'en'));
      expect(terms.map((t) => t.id), ['plural', 'raf', 'verb']);
    },
  );

  test('matches Arabic regardless of diacritics and alif variants', () {
    final entry = term('irab', 'الإِعْرَاب', "I'rab");
    expect(entry.matches('الاعراب', 'ar'), isTrue);
    expect(entry.matches('إعراب', 'en'), isTrue);
    expect(entry.matches("I'RAB", 'ar'), isTrue);
  });

  test('loads draft glossary only in preview mode', () async {
    final release = await const GlossaryRepository(
      previewUnreviewed: false,
    ).load();
    final preview = await const GlossaryRepository(
      previewUnreviewed: true,
    ).load();
    expect(release.terms.any((term) => term.id == 'jam-taksir'), isFalse);
    expect(preview.terms.any((term) => term.id == 'jam-taksir'), isTrue);
  });
}
