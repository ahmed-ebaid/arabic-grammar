import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/content_models.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'lesson_detail_screen.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({this.contentCatalog, super.key});

  final ContentCatalog? contentCatalog;

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  late final Future<ContentCatalog> _catalog = widget.contentCatalog == null
      ? _loadCatalog()
      : Future.value(widget.contentCatalog);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final learningColors = Theme.of(context).extension<LearningColors>()!;
    final languageCode = Localizations.localeOf(context).languageCode;

    return FutureBuilder<ContentCatalog>(
      future: _catalog,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.contentLoadError, textAlign: TextAlign.center),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final lessons = snapshot.data!.lessons;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              color: learningColors.coralContainer,
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                leading: Icon(
                  Icons.school_outlined,
                  size: 36,
                  color: learningColors.onCoralContainer,
                ),
                title: Text(l10n.moduleTitle),
                subtitle: Text(l10n.moduleSubtitle),
              ),
            ),
            const SizedBox(height: 16),
            for (final lesson in lessons)
              Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  leading: CircleAvatar(
                    backgroundColor: learningColors.sunshineContainer,
                    foregroundColor: learningColors.onSunshineContainer,
                    child: Text('${lesson.order}'),
                  ),
                  title: Text(
                    lesson.title.forLanguage(languageCode),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${l10n.lessonNumber(lesson.order)} · '
                      '${l10n.estimatedMinutes(lesson.estimatedMinutes)}',
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => LessonDetailScreen(lesson: lesson),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  static Future<ContentCatalog> _loadCatalog() async {
    final source = await rootBundle.loadString('content/drafts/lesson_01.json');
    return ContentCatalog.fromJson(jsonDecode(source));
  }
}
