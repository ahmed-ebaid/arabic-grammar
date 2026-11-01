import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

import 'core/models/content_models.dart';
import 'core/progress/lesson_progress_controller.dart';
import 'core/services/review_prompt_service.dart';
import 'core/services/seasonal_icon_service.dart';
import 'core/subscriptions/subscription_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/user/user_data_controller.dart';
import 'features/about/about_screen.dart';
import 'features/bookmarks/bookmarks_screen.dart';
import 'features/glossary/glossary_screen.dart';
import 'features/home/home_screen.dart';
import 'features/lessons/lesson_detail_screen.dart';
import 'features/lessons/lessons_screen.dart';
import 'features/practice/practice_screen.dart';
import 'features/progress/progress_screen.dart';
import 'features/subscriptions/plus_paywall_screen.dart';
import 'l10n/app_localizations.dart';

class RootScaffold extends StatefulWidget {
  const RootScaffold({
    required this.lessonProgressController,
    required this.subscriptionController,
    required this.userDataController,
    this.contentCatalog,
    super.key,
  });

  final ContentCatalog? contentCatalog;
  final LessonProgressController lessonProgressController;
  final SubscriptionController subscriptionController;
  final UserDataController userDataController;

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  Timer? _reviewPromptTimer;
  bool _isForeground = true;
  bool _reviewPromptHandledThisLaunch = false;
  bool _seasonalIconSupported = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializeSeasonalIconAndReviewPrompt());
      if (mounted && !widget.userDataController.hasLearnerProfile) {
        _showLearnerProfileDialog(required: true);
      }
    });
  }

  Future<void> _initializeSeasonalIconAndReviewPrompt() async {
    try {
      final service = SeasonalIconService();
      final supported = await service.isSupported();
      if (mounted && supported != _seasonalIconSupported) {
        setState(() => _seasonalIconSupported = supported);
      }
      if (supported && await service.applyForDate()) {
        // Avoid stacking the review sheet on top of the icon-change alert.
        _reviewPromptHandledThisLaunch = true;
        _reviewPromptTimer?.cancel();
        _reviewPromptTimer = null;
      }
    } catch (error) {
      debugPrint('Seasonal icon update failed: $error');
    }
    _scheduleReviewPrompt();
  }

  void _scheduleReviewPrompt() {
    if (_reviewPromptHandledThisLaunch || _reviewPromptTimer != null) return;
    _reviewPromptTimer = Timer(const Duration(seconds: 5), () {
      _reviewPromptTimer = null;
      unawaited(_requestReviewIfAppropriate());
    });
  }

  Future<void> _requestReviewIfAppropriate() async {
    if (!mounted ||
        !_isForeground ||
        _currentIndex != 0 ||
        ModalRoute.of(context)?.isCurrent != true ||
        _reviewPromptHandledThisLaunch) {
      return;
    }
    _reviewPromptHandledThisLaunch = true;
    try {
      await ReviewPromptService().requestAtLaunch(
        isAvailable: InAppReview.instance.isAvailable,
        requestReview: InAppReview.instance.requestReview,
      );
    } catch (error) {
      debugPrint('In-app review request failed: $error');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isForeground = state == AppLifecycleState.resumed;
    if (_isForeground) {
      unawaited(_initializeSeasonalIconAndReviewPrompt());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reviewPromptTimer?.cancel();
    super.dispose();
  }

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
                value: _AppMenuAction.learnerProfile,
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(l10n.learnerProfileChange),
                ),
              ),
              if (_seasonalIconSupported)
                PopupMenuItem(
                  value: _AppMenuAction.seasonalIcon,
                  child: ListTile(
                    leading: const Icon(Icons.nights_stay_outlined),
                    title: Text(l10n.seasonalIconTitle),
                  ),
                ),
              if (!widget.subscriptionController.isInternalTestAccess &&
                  !widget.subscriptionController.hasPlusAccess)
                PopupMenuItem(
                  value: _AppMenuAction.plusOffer,
                  child: ListTile(
                    leading: const Icon(Icons.workspace_premium_outlined),
                    title: Text(l10n.plusTitle),
                  ),
                ),
              if (!widget.subscriptionController.isInternalTestAccess)
                PopupMenuItem(
                  value: _AppMenuAction.restorePurchases,
                  child: ListTile(
                    leading: const Icon(Icons.restore),
                    title: Text(l10n.restorePurchases),
                  ),
                ),
              PopupMenuItem(
                value: _AppMenuAction.rateApp,
                child: ListTile(
                  leading: const Icon(Icons.star_outline_rounded),
                  title: Text(l10n.rateAppTitle),
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
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            contentCatalog: widget.contentCatalog,
            progressController: widget.lessonProgressController,
            onStartLearning: () => _selectTab(1),
            onContinueLesson: _openLessonFromHome,
          ),
          LessonsScreen(
            contentCatalog: widget.contentCatalog,
            progressController: widget.lessonProgressController,
            subscriptionController: widget.subscriptionController,
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
    if (index != 0) _reviewPromptTimer?.cancel();
    setState(() => _currentIndex = index);
  }

  Future<void> _openLessonFromHome(Lesson lesson) async {
    final catalog = widget.contentCatalog;
    final level = catalog?.levels
        .where((candidate) => candidate.lessonIds.contains(lesson.id))
        .firstOrNull;
    final isPlusLevel = (level?.order ?? 1) > 1;
    if (isPlusLevel && !widget.subscriptionController.hasPlusAccess) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => PlusPaywallScreen(
            subscriptionController: widget.subscriptionController,
          ),
        ),
      );
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => LessonDetailScreen(
          lesson: lesson,
          progressController: widget.lessonProgressController,
          userDataController: widget.userDataController,
        ),
      ),
    );
    if (mounted) {
      setState(() {});
    }
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
      case _AppMenuAction.learnerProfile:
        _showLearnerProfileDialog();
        return;
      case _AppMenuAction.seasonalIcon:
        _showSeasonalIconDialog();
        return;
      case _AppMenuAction.rateApp:
        _rateApp();
        return;
      case _AppMenuAction.about:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AboutScreen(contentCatalog: widget.contentCatalog),
          ),
        );
        return;
      case _AppMenuAction.plusOffer:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PlusPaywallScreen(
              subscriptionController: widget.subscriptionController,
            ),
          ),
        );
        return;
      case _AppMenuAction.restorePurchases:
        _restorePurchases();
        return;
    }
  }

  Future<void> _showSeasonalIconDialog() async {
    final l10n = AppLocalizations.of(context);
    final service = SeasonalIconService();
    var enabled = service.isEnabled;
    var saving = false;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.seasonalIconTitle),
          content: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.nights_stay_outlined),
            title: Text(l10n.seasonalIconTitle),
            subtitle: Text(l10n.seasonalIconSubtitle),
            value: enabled,
            onChanged: saving
                ? null
                : (value) async {
                    setDialogState(() {
                      enabled = value;
                      saving = true;
                    });
                    try {
                      await service.setEnabled(value);
                    } finally {
                      if (context.mounted) {
                        setDialogState(() => saving = false);
                      }
                    }
                  },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _rateApp() async {
    final l10n = AppLocalizations.of(context);
    try {
      if (await InAppReview.instance.isAvailable()) {
        await ReviewPromptService().recordPromptAttempt();
        await InAppReview.instance.requestReview();
        return;
      }
      await InAppReview.instance.openStoreListing();
    } catch (error) {
      debugPrint('Could not open review prompt: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.rateAppUnavailable)));
    }
  }

  Future<void> _restorePurchases() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.restorePurchasesChecking)));

    final result = await widget.subscriptionController.restorePurchases();
    if (!mounted) return;

    final message = switch (result) {
      SubscriptionActionResult.success => l10n.restorePurchasesSuccess,
      SubscriptionActionResult.noActiveSubscription =>
        l10n.restorePurchasesNoneFound,
      SubscriptionActionResult.notConfigured =>
        widget.subscriptionController.configurationFailed
            ? l10n.restorePurchasesError
            : l10n.restorePurchasesUnavailable,
      SubscriptionActionResult.alreadyRunning => l10n.restorePurchasesChecking,
      SubscriptionActionResult.cancelled ||
      SubscriptionActionResult.failed => l10n.restorePurchasesError,
    };
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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

  Future<void> _showLearnerProfileDialog({bool required = false}) async {
    final l10n = AppLocalizations.of(context);
    final current = widget.userDataController.learnerProfile;
    final profile = await showDialog<LearnerProfile>(
      context: context,
      barrierDismissible: !required,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        final learningColors = Theme.of(
          dialogContext,
        ).extension<LearningColors>()!;
        final textTheme = Theme.of(dialogContext).textTheme;
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: learningColors.blueContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.appName,
                      style: TextStyle(
                        fontFamily: 'AmiriQuran',
                        fontSize: 34,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: learningColors.onBlueContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.learnerProfileTitle,
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.learnerProfileBody,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                _LearnerProfileOptionCard(
                  icon: Icons.auto_awesome_outlined,
                  title: l10n.learnerProfileYoung,
                  subtitle: l10n.learnerProfileYoungSubtitle,
                  selected: !required && current == LearnerProfile.youngLearner,
                  onTap: () =>
                      Navigator.pop(dialogContext, LearnerProfile.youngLearner),
                ),
                const SizedBox(height: 12),
                _LearnerProfileOptionCard(
                  icon: Icons.menu_book_outlined,
                  title: l10n.learnerProfileGeneral,
                  subtitle: l10n.learnerProfileGeneralSubtitle,
                  selected:
                      !required && current == LearnerProfile.generalLearner,
                  onTap: () => Navigator.pop(
                    dialogContext,
                    LearnerProfile.generalLearner,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (profile != null) {
      await widget.userDataController.setLearnerProfile(profile);
    }
  }
}

class _LearnerProfileOptionCard extends StatelessWidget {
  const _LearnerProfileOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final learningColors = Theme.of(context).extension<LearningColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: selected
          ? learningColors.blueContainer
          : scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: selected
                      ? scheme.primary.withValues(alpha: 0.14)
                      : learningColors.blueContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: learningColors.onBlueContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? learningColors.onBlueContainer
                            : scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        height: 1.5,
                        color: selected
                            ? learningColors.onBlueContainer.withValues(
                                alpha: 0.85,
                              )
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _AppMenuAction {
  glossary,
  bookmarks,
  textSize,
  learnerProfile,
  seasonalIcon,
  plusOffer,
  restorePurchases,
  rateApp,
  about,
}
