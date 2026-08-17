import 'content_models.dart';

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
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    return term.forLanguage(languageCode).toLowerCase().contains(normalized) ||
        term.en.toLowerCase().contains(normalized) ||
        term.ar.contains(query.trim()) ||
        transliteration.toLowerCase().contains(normalized) ||
        definition.forLanguage(languageCode).toLowerCase().contains(normalized);
  }
}
