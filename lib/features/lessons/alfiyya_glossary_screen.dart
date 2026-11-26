import 'package:flutter/material.dart';

import '../../core/localization/arabic_diacritics.dart';
import '../../core/models/glossary_models.dart';
import '../../l10n/app_localizations.dart';
import 'alfiyya_glossary.dart';
import 'alfiyya_readings.dart';

class AlfiyyaGlossaryScreen extends StatefulWidget {
  const AlfiyyaGlossaryScreen({super.key});

  @override
  State<AlfiyyaGlossaryScreen> createState() => _AlfiyyaGlossaryScreenState();
}

class _AlfiyyaGlossaryScreenState extends State<AlfiyyaGlossaryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final terms =
        alfiyyaGlossary
            .where(
              (entry) => entry.searchable.matches(
                _searchController.text,
                languageCode,
              ),
            )
            .toList()
          ..sort(
            (a, b) =>
                GlossaryTerm.compare(a.searchable, b.searchable, languageCode),
          );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.alfiyyaGlossaryTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(l10n.alfiyyaGlossaryDescription),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              controller: _searchController,
              hintText: l10n.glossarySearchHint,
              leading: const Icon(Icons.search),
              onChanged: (_) => setState(() {}),
              trailing: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    tooltip: l10n.clearSearch,
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.clear),
                  ),
              ],
            ),
          ),
          Expanded(
            child: terms.isEmpty
                ? Center(child: Text(l10n.glossaryNoResults))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: terms.length,
                    itemBuilder: (context, index) {
                      final entry = terms[index];
                      final reading = alfiyyaReadings.values
                          .expand((readings) => readings)
                          .firstWhere(
                            (reading) =>
                                reading.lessonId == entry.lessonId &&
                                reading.verse.contains(entry.excerpt),
                          );
                      return Card(
                        child: ExpansionTile(
                          title: ArabicDiacriticsText(entry.word),
                          subtitle: Text(entry.transliteration),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            16,
                          ),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ArabicDiacriticsText(
                              entry.meaning.forLanguage(languageCode),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              reading.topic.forLanguage(languageCode),
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: ArabicDiacriticsText('«${entry.excerpt}»'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
