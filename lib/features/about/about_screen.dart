import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/content_models.dart';
import '../../l10n/app_localizations.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({this.contentCatalog, super.key});

  final ContentCatalog? contentCatalog;

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late final Future<ContentCatalog> _catalog = widget.contentCatalog == null
      ? _loadCatalog()
      : Future.value(widget.contentCatalog);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: FutureBuilder<ContentCatalog>(
        future: _catalog,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(l10n.contentLoadError));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final catalog = snapshot.data!;
          final sources = <String, ContentSource>{};
          final reviewers = <String>{};
          for (final lesson in catalog.lessons) {
            for (final source in lesson.sources) {
              sources[source.id] = source;
            }
            final reviewer = lesson.review.reviewer;
            if (lesson.review.status == ReviewStatus.approved &&
                reviewer != null) {
              reviewers.add(reviewer);
            }
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _AboutSection(
                title: l10n.aboutPurposeTitle,
                child: Text(l10n.aboutPurposeBody),
              ),
              _AboutSection(
                title: l10n.aboutCompanyTitle,
                child: Text(l10n.aboutCompanyBody),
              ),
              _AboutSection(
                title: l10n.aboutResourcesTitle,
                child: Column(
                  children: [
                    for (final source in sources.values)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.menu_book_outlined),
                        title: Text(source.title.forLanguage(languageCode)),
                        subtitle: Text(
                          '${source.author.forLanguage(languageCode)}\n'
                          '${source.citation.forLanguage(languageCode)}',
                        ),
                      ),
                  ],
                ),
              ),
              _AboutSection(
                title: l10n.aboutReviewersTitle,
                child: reviewers.isEmpty
                    ? Text(l10n.aboutReviewersPending)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final reviewer in reviewers)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.verified_outlined),
                              title: Text(reviewer),
                            ),
                        ],
                      ),
              ),
              _AboutSection(
                title: l10n.aboutContentStatusTitle,
                child: Text(
                  '${l10n.aboutContentVersion}: ${catalog.contentVersion}\n\n'
                  '${l10n.aboutDisclaimer}',
                ),
              ),
              _AboutSection(
                title: l10n.aboutContactTitle,
                child: const SelectableText(
                  'Ebaid LLC\n'
                  'ahmed@ebaidllc.com\n'
                  'ahmed-ebaid.github.io/arabic-grammar',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Future<ContentCatalog> _loadCatalog() async {
    final source = await rootBundle.loadString('content/drafts/lesson_01.json');
    return ContentCatalog.fromJson(jsonDecode(source));
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
