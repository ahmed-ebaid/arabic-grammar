import 'package:flutter/material.dart';

import 'core/models/content_models.dart';
import 'core/progress/lesson_progress_controller.dart';
import 'features/home/home_screen.dart';
import 'features/lessons/lessons_screen.dart';
import 'features/practice/practice_screen.dart';
import 'features/progress/progress_screen.dart';
import 'features/settings/language_button.dart';
import 'l10n/app_localizations.dart';

class RootScaffold extends StatefulWidget {
  const RootScaffold({
    required this.lessonProgressController,
    this.contentCatalog,
    super.key,
  });

  final ContentCatalog? contentCatalog;
  final LessonProgressController lessonProgressController;

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
        actions: const [LanguageButton()],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onStartLearning: () => _selectTab(1)),
          LessonsScreen(
            contentCatalog: widget.contentCatalog,
            progressController: widget.lessonProgressController,
          ),
          const PracticeScreen(),
          const ProgressScreen(),
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
}
