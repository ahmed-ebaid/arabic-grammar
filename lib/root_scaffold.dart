import 'package:flutter/material.dart';

import 'core/models/content_models.dart';
import 'core/progress/lesson_progress_controller.dart';
import 'core/user/user_data_controller.dart';
import 'features/about/about_screen.dart';
import 'features/bookmarks/bookmarks_screen.dart';
import 'features/glossary/glossary_screen.dart';
import 'features/home/home_screen.dart';
import 'features/lessons/lessons_screen.dart';
import 'features/practice/practice_screen.dart';
import 'features/progress/progress_screen.dart';
import 'features/settings/language_button.dart';
import 'l10n/app_localizations.dart';

class RootScaffold extends StatefulWidget {
  const RootScaffold({
    required this.lessonProgressController,
    required this.userDataController,
    this.contentCatalog,
    super.key,
  });

  final ContentCatalog? contentCatalog;
  final LessonProgressController lessonProgressController;
  final UserDataController userDataController;

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: l10n.homeTab,
      ),
      NavigationDestination(
        icon: const Icon(Icons.menu_book_outlined),
        selectedIcon: const Icon(Icons.menu_book),
        label: l10n.lessonsTab,
      ),
      NavigationDestination(
        icon: const Icon(Icons.quiz_outlined),
        selectedIcon: const Icon(Icons.quiz),
        label: l10n.practiceTab,
      ),
      NavigationDestination(
        icon: const Icon(Icons.insights_outlined),
        selectedIcon: const Icon(Icons.insights),
        label: l10n.progressTab,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          PopupMenuButton<_AppMenuAction>(
            tooltip: l10n.more,
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _AppMenuAction.glossary,
                child: ListTile(
                  leading: const Icon(Icons.manage_search),
                  title: Text(l10n.glossaryTitle),
                ),
              ),
              PopupMenuItem(
                value: _AppMenuAction.bookmarks,
                child: ListTile(
                  leading: const Icon(Icons.bookmarks_outlined),
                  title: Text(l10n.bookmarksTitle),
                ),
              ),
              PopupMenuItem(
                value: _AppMenuAction.textSize,
                child: ListTile(
                  leading: const Icon(Icons.text_fields),
                  title: Text(l10n.textSizeTitle),
                ),
              ),
              PopupMenuItem(
                value: _AppMenuAction.about,
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.aboutTitle),
                ),
              ),
            ],
          ),
          const LanguageButton(),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onStartLearning: () => _selectTab(1)),
          LessonsScreen(
            contentCatalog: widget.contentCatalog,
            progressController: widget.lessonProgressController,
            userDataController: widget.userDataController,
          ),
          PracticeScreen(
            contentCatalog: widget.contentCatalog,
            progressController: widget.lessonProgressController,
            userDataController: widget.userDataController,
          ),
          ProgressScreen(
            contentCatalog: widget.contentCatalog,
            progressController: widget.lessonProgressController,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        destinations: destinations,
        onDestinationSelected: _selectTab,
      ),
    );
  }

  void _selectTab(int index) {
    setState(() => _currentIndex = index);
  }

  void _handleMenuAction(_AppMenuAction action) {
    switch (action) {
      case _AppMenuAction.glossary:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                GlossaryScreen(userDataController: widget.userDataController),
          ),
        );
        return;
      case _AppMenuAction.bookmarks:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BookmarksScreen(
              contentCatalog: widget.contentCatalog,
              progressController: widget.lessonProgressController,
              userDataController: widget.userDataController,
            ),
          ),
        );
        return;
      case _AppMenuAction.textSize:
        _showTextSizeDialog();
        return;
      case _AppMenuAction.about:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AboutScreen(contentCatalog: widget.contentCatalog),
          ),
        );
        return;
    }
  }

  Future<void> _showTextSizeDialog() async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.textSizeTitle),
        content: AnimatedBuilder(
          animation: widget.userDataController,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.textSizeBody),
              const SizedBox(height: 16),
              SegmentedButton<double>(
                segments: [
                  ButtonSegment(value: 0.9, label: Text(l10n.textSizeSmall)),
                  ButtonSegment(value: 1.0, label: Text(l10n.textSizeDefault)),
                  ButtonSegment(value: 1.2, label: Text(l10n.textSizeLarge)),
                  ButtonSegment(value: 1.4, label: Text(l10n.textSizeLargest)),
                ],
                selected: {widget.userDataController.textScale},
                onSelectionChanged: (selection) {
                  widget.userDataController.setTextScale(selection.single);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}

enum _AppMenuAction { glossary, bookmarks, textSize, about }
