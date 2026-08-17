import 'package:flutter/material.dart';

import '../../core/content/glossary_repository.dart';
import '../../core/models/glossary_models.dart';
import '../../core/user/user_data_controller.dart';
import '../../l10n/app_localizations.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({required this.userDataController, super.key});

  final UserDataController userDataController;

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  final _searchController = TextEditingController();
  final _catalog = const GlossaryRepository().load();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.glossaryTitle)),
      body: FutureBuilder<GlossaryCatalog>(
        future: _catalog,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(l10n.contentLoadError));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final terms = snapshot.data!.terms
              .where(
                (term) => term.matches(_searchController.text, languageCode),
              )
              .toList();
          return Column(
            children: [
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
                        itemBuilder: (context, index) => _TermCard(
                          term: terms[index],
                          languageCode: languageCode,
                          userDataController: widget.userDataController,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TermCard extends StatelessWidget {
  const _TermCard({
    required this.term,
    required this.languageCode,
    required this.userDataController,
  });

  final GlossaryTerm term;
  final String languageCode;
  final UserDataController userDataController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: userDataController,
      builder: (context, _) {
        final bookmarked = userDataController.isBookmarked(
          BookmarkType.glossary,
          term.id,
        );
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: const CircleAvatar(child: Icon(Icons.translate)),
            title: Text(
              term.term.forLanguage(languageCode),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text(term.transliteration),
            trailing: IconButton(
              tooltip: bookmarked ? l10n.removeBookmark : l10n.addBookmark,
              onPressed: () => userDataController.toggleBookmark(
                BookmarkType.glossary,
                term.id,
              ),
              icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(term.definition.forLanguage(languageCode)),
              const SizedBox(height: 12),
              Text(
                term.example.forLanguage(languageCode),
                style: const TextStyle(fontFamily: 'AmiriQuran', fontSize: 20),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 8),
              Text(l10n.glossaryLessonLinks(term.lessonIds.length)),
            ],
          ),
        );
      },
    );
  }
}
