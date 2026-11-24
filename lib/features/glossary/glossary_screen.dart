import 'package:flutter/material.dart';

import '../../core/localization/arabic_diacritics.dart';
import '../../core/localization/number_format.dart';
import '../../core/content/content_repository.dart';
import '../../core/content/glossary_repository.dart';
import '../../core/models/content_models.dart';
import '../../core/models/glossary_models.dart';
import '../../core/progress/lesson_progress_controller.dart';
import '../../core/subscriptions/subscription_controller.dart';
import '../../core/user/user_data_controller.dart';
import '../../l10n/app_localizations.dart';
import '../lessons/lesson_detail_screen.dart';
import '../subscriptions/plus_paywall_screen.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({
    required this.progressController,
    required this.subscriptionController,
    required this.userDataController,
    this.contentCatalog,
    super.key,
  });

  final ContentCatalog? contentCatalog;
  final LessonProgressController progressController;
  final SubscriptionController subscriptionController;
  final UserDataController userDataController;

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  final _searchController = TextEditingController();
  late final Future<(GlossaryCatalog, ContentCatalog)> _catalog = _load();

  Future<(GlossaryCatalog, ContentCatalog)> _load() async {
    final glossary = await const GlossaryRepository().load();
    final content =
        widget.contentCatalog ?? await const ContentRepository().load();
    final lessonIds = content.lessons.map((lesson) => lesson.id).toSet();
    final levelLessonIds = content.levels
        .expand((level) => level.lessonIds)
        .toSet();
    if (glossary.terms
        .expand((term) => term.lessonIds)
        .any((id) => !lessonIds.contains(id) || !levelLessonIds.contains(id))) {
      throw const FormatException('Glossary references an unknown lesson.');
    }
    return (glossary, content);
  }

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
      body: FutureBuilder<(GlossaryCatalog, ContentCatalog)>(
        future: _catalog,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(l10n.contentLoadError));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final terms = snapshot.data!.$1.terms
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
                          catalog: snapshot.data!.$2,
                          languageCode: languageCode,
                          progressController: widget.progressController,
                          subscriptionController: widget.subscriptionController,
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
    required this.catalog,
    required this.languageCode,
    required this.progressController,
    required this.subscriptionController,
    required this.userDataController,
  });

  final GlossaryTerm term;
  final ContentCatalog catalog;
  final String languageCode;
  final LessonProgressController progressController;
  final SubscriptionController subscriptionController;
  final UserDataController userDataController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: Listenable.merge([
        userDataController,
        progressController,
        subscriptionController,
      ]),
      builder: (context, _) {
        final bookmarked = userDataController.isBookmarked(
          BookmarkType.glossary,
          term.id,
        );
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: const CircleAvatar(child: Icon(Icons.translate)),
            title: ArabicDiacriticsText(
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
              ArabicDiacriticsText(term.definition.forLanguage(languageCode)),
              const SizedBox(height: 12),
              Text(
                l10n.glossaryExampleLabel,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              ArabicDiacriticsText(
                term.example.forLanguage(languageCode),
                style: const TextStyle(fontFamily: 'AmiriQuran', fontSize: 20),
                textDirection: languageCode == 'ar'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.glossaryLessonLinks(
                  localizedNumber(context, term.lessonIds.length),
                ),
              ),
              for (final id in term.lessonIds)
                _lessonLink(
                  context,
                  catalog.lessons.firstWhere((lesson) => lesson.id == id),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _lessonLink(BuildContext context, Lesson lesson) {
    final l10n = AppLocalizations.of(context);
    final unlocked = lesson.prerequisites.every(progressController.isMastered);
    final level = catalog.levels.firstWhere(
      (level) => level.lessonIds.contains(lesson.id),
    );
    final premiumLocked =
        level.order > 1 && !subscriptionController.hasPlusAccess;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        !unlocked || premiumLocked
            ? Icons.lock_outline
            : Icons.menu_book_outlined,
      ),
      title: ArabicDiacriticsText(lesson.title.forLanguage(languageCode)),
      subtitle: !unlocked
          ? Text(l10n.lessonLockedPrevious)
          : premiumLocked
          ? Text(l10n.plusRequired)
          : null,
      trailing: unlocked ? const Icon(Icons.chevron_right) : null,
      onTap: !unlocked
          ? null
          : () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => premiumLocked
                    ? PlusPaywallScreen(
                        subscriptionController: subscriptionController,
                      )
                    : LessonDetailScreen(
                        lesson: lesson,
                        courseLessons: catalog.lessons,
                        progressController: progressController,
                        userDataController: userDataController,
                      ),
              ),
            ),
    );
  }
}
