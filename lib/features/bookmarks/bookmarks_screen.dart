import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/content/glossary_repository.dart';
import '../../core/models/content_models.dart';
import '../../core/models/glossary_models.dart';
import '../../core/progress/lesson_progress_controller.dart';
import '../../core/user/user_data_controller.dart';
import '../../l10n/app_localizations.dart';
import '../lessons/lesson_detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({
    required this.progressController,
    required this.userDataController,
    this.contentCatalog,
    super.key,
  });

  final ContentCatalog? contentCatalog;
  final LessonProgressController progressController;
  final UserDataController userDataController;

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  late final Future<(ContentCatalog, GlossaryCatalog)> _data = _load();

  Future<(ContentCatalog, GlossaryCatalog)> _load() async {
    final content = widget.contentCatalog ?? await _loadContent();
    final glossary = await const GlossaryRepository().load();
    return (content, glossary);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookmarksTitle)),
      body: FutureBuilder<(ContentCatalog, GlossaryCatalog)>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(l10n.contentLoadError));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return AnimatedBuilder(
            animation: widget.userDataController,
            builder: (context, _) =>
                _buildList(context, snapshot.data!.$1, snapshot.data!.$2),
          );
        },
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    ContentCatalog catalog,
    GlossaryCatalog glossary,
  ) {
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final lessonIds = widget.userDataController.bookmarkedIds(
      BookmarkType.lesson,
    );
    final exampleIds = widget.userDataController.bookmarkedIds(
      BookmarkType.example,
    );
    final termIds = widget.userDataController.bookmarkedIds(
      BookmarkType.glossary,
    );
    final lessons = catalog.lessons
        .where((lesson) => lessonIds.contains(lesson.id))
        .toList();
    final examples = [
      for (final lesson in catalog.lessons)
        for (final section in lesson.sections)
          for (final example in section.examples)
            if (exampleIds.contains(example.id)) (lesson, example),
    ];
    final terms = glossary.terms
        .where((term) => termIds.contains(term.id))
        .toList();
    if (lessons.isEmpty && examples.isEmpty && terms.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bookmarks_outlined, size: 56),
              const SizedBox(height: 16),
              Text(l10n.bookmarksEmpty, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (lessons.isNotEmpty) ...[
          _Heading(l10n.bookmarkedLessons),
          for (final lesson in lessons)
            Card(
              child: ListTile(
                leading: const Icon(Icons.school_outlined),
                title: Text(lesson.title.forLanguage(languageCode)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LessonDetailScreen(
                      lesson: lesson,
                      progressController: widget.progressController,
                      userDataController: widget.userDataController,
                    ),
                  ),
                ),
              ),
            ),
        ],
        if (examples.isNotEmpty) ...[
          _Heading(l10n.bookmarkedExamples),
          for (final entry in examples)
            Card(
              child: ListTile(
                leading: const Icon(Icons.format_quote),
                title: Text(
                  entry.$2.vocalized,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'AmiriQuran',
                    fontSize: 20,
                  ),
                ),
                subtitle: Text(entry.$1.title.forLanguage(languageCode)),
              ),
            ),
        ],
        if (terms.isNotEmpty) ...[
          _Heading(l10n.bookmarkedTerms),
          for (final term in terms)
            Card(
              child: ListTile(
                leading: const Icon(Icons.translate),
                title: Text(term.term.forLanguage(languageCode)),
                subtitle: Text(term.definition.forLanguage(languageCode)),
              ),
            ),
        ],
      ],
    );
  }

  static Future<ContentCatalog> _loadContent() async {
    final source = await rootBundle.loadString('content/drafts/lesson_01.json');
    return ContentCatalog.fromJson(jsonDecode(source));
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
    child: Text(text, style: Theme.of(context).textTheme.titleLarge),
  );
}
