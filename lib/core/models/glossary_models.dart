import 'content_models.dart';

String _normalizeGlossaryText(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '')
    .replaceAll(RegExp('[أإآٱ]'), 'ا');

class GlossaryCatalog {
  const GlossaryCatalog({required this.schemaVersion, required this.terms});

  factory GlossaryCatalog.fromJson(Object? value) {
    const path = r'$';
    final json = JsonValue.object(value, path);
    JsonValue.expectKeys(json, const {'schemaVersion', 'terms'}, path);
    return GlossaryCatalog(
      schemaVersion: JsonValue.requiredInt(json, 'schemaVersion', path),
      terms: JsonValue.objectList(json, 'terms', path).indexed
          .map(
            (entry) => GlossaryTerm.fromJson(
              entry.$2,
              r'$.terms['
              '${entry.$1}]',
            ),
          )
          .toList(growable: false),
    );
  }

  final int schemaVersion;
  final List<GlossaryTerm> terms;
}

class GlossaryTerm {
  const GlossaryTerm({
    required this.id,
    required this.term,
    required this.transliteration,
    required this.definition,
    required this.example,
    required this.lessonIds,
  });

  factory GlossaryTerm.fromJson(Map<String, Object?> json, String path) {
    JsonValue.expectKeys(json, const {
      'id',
      'term',
      'transliteration',
      'definition',
      'example',
      'lessonIds',
    }, path);
    return GlossaryTerm(
      id: JsonValue.requiredString(json, 'id', path),
      term: LocalizedText.fromJson(json['term'], '$path.term'),
      transliteration: JsonValue.requiredString(json, 'transliteration', path),
      definition: LocalizedText.fromJson(
        json['definition'],
        '$path.definition',
      ),
      example: LocalizedText.fromJson(json['example'], '$path.example'),
      lessonIds: JsonValue.stringList(json, 'lessonIds', path),
    );
  }

  final String id;
  final LocalizedText term;
  final String transliteration;
  final LocalizedText definition;
  final LocalizedText example;
  final List<String> lessonIds;

  bool matches(String query, String languageCode) {
    final normalized = _normalizeGlossaryText(query);
    if (normalized.isEmpty) return true;
    return [
      term.forLanguage(languageCode),
      term.en,
      term.ar,
      transliteration,
      definition.forLanguage(languageCode),
    ].any((value) => _normalizeGlossaryText(value).contains(normalized));
  }

  static int compare(GlossaryTerm a, GlossaryTerm b, String languageCode) {
    String key(GlossaryTerm term) {
      final value = _normalizeGlossaryText(term.term.forLanguage(languageCode));
      return languageCode == 'ar' && value.startsWith('ال')
          ? value.substring(2)
          : value;
    }

    final comparison = key(a).compareTo(key(b));
    return comparison != 0 ? comparison : a.id.compareTo(b.id);
  }
}
