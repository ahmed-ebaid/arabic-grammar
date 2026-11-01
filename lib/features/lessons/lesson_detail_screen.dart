import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/localization/number_format.dart';
import '../../core/localization/arabic_diacritics.dart';
import '../../core/models/content_models.dart';
import '../../core/progress/lesson_progress_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/user/user_data_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/correct_answer_celebration.dart';
import '../../shared/widgets/milestone_celebration_banner.dart';
import '../../shared/widgets/young_learner_mascot.dart';

class LessonDetailScreen extends StatefulWidget {
  const LessonDetailScreen({
    required this.lesson,
    required this.progressController,
    required this.userDataController,
    super.key,
  });

  final Lesson lesson;
  final LessonProgressController progressController;
  final UserDataController userDataController;

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final Set<String> _solvedExerciseIds = {};
  late List<Exercise> _activeExercises;
  late List<_LessonStep> _steps;
  late int _currentStep;
  String? _selectedOptionId;
  bool _answerChecked = false;

  @override
  void initState() {
    super.initState();
    _activeExercises = _exercisesForAttempt();
    _steps = _buildSteps(widget.lesson, _activeExercises);
    _currentStep = widget.progressController
        .stepFor(widget.lesson.id)
        .clamp(0, _steps.length - 1);
    _restoreSolvedExercises();
    _syncAnswerState(_currentStep);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.progressController.markLessonActive(widget.lesson.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final step = _steps[_currentStep];
    final progress = (_currentStep + 1) / _steps.length;

    return Scaffold(
      appBar: AppBar(
        title: ArabicDiacriticsText(
          widget.lesson.title.forLanguage(_languageCode),
        ),
        actions: [
          AnimatedBuilder(
            animation: widget.userDataController,
            builder: (context, _) {
              final bookmarked = widget.userDataController.isBookmarked(
                BookmarkType.lesson,
                widget.lesson.id,
              );
              return IconButton(
                tooltip: bookmarked ? l10n.removeBookmark : l10n.addBookmark,
                onPressed: () => widget.userDataController.toggleBookmark(
                  BookmarkType.lesson,
                  widget.lesson.id,
                ),
                icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 12,
                            value: progress,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.stepProgress(
                          localizedNumber(context, _currentStep + 1),
                          localizedNumber(context, _steps.length),
                        ),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          key: const ValueKey('lessonPreviousStep'),
                          onPressed: _canGoBack ? _goToPrevious : null,
                          child: ArabicDiacriticsText(l10n.previousStep),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Tooltip(
                          message: _canGoForward ? '' : l10n.nextStepLocked,
                          child: TextButton(
                            key: const ValueKey('lessonNextStep'),
                            onPressed: _canGoForward ? _advance : null,
                            child: Text(l10n.nextStep),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: widget.userDataController,
                builder: (context, _) => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0.08, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: child,
                    ),
                  ),
                  child: SingleChildScrollView(
                    key: ValueKey(
                      '$_currentStep-${widget.userDataController.learningMode}',
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: _buildStep(step),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _languageCode => Localizations.localeOf(context).languageCode;

  Widget _buildStep(_LessonStep step) {
    final learningMode = widget.userDataController.learningMode;
    return switch (step.kind) {
      _StepKind.objectives => _ObjectivesStep(
        lesson: widget.lesson,
        languageCode: _languageCode,
        learningMode: learningMode,
        onContinue: _advance,
      ),
      _StepKind.teaching => _TeachingStep(
        section: step.section!,
        languageCode: _languageCode,
        learningMode: learningMode,
        onContinue: _advance,
      ),
      _StepKind.exercise => _ExerciseStep(
        exercise: step.exercise!,
        languageCode: _languageCode,
        learningMode: learningMode,
        selectedOptionId: _selectedOptionId,
        answerChecked: _answerChecked,
        onSelect: _selectOption,
        onCheck: _checkAnswer,
        onRetry: _retry,
        onContinue: _advance,
      ),
      _StepKind.analysis => _AnalysisStep(
        example: step.example!,
        languageCode: _languageCode,
        learningMode: learningMode,
        userDataController: widget.userDataController,
        onContinue: _advance,
      ),
      _StepKind.completion => _CompletionStep(
        mastery: widget.progressController.masteryFor(widget.lesson.id),
        progressController: widget.progressController,
        onRestart: _restart,
        onClose: () => Navigator.of(context).pop(),
      ),
    };
  }

  void _selectOption(String id) {
    if (_answerChecked) {
      return;
    }
    setState(() => _selectedOptionId = id);
    HapticFeedback.selectionClick();
  }

  Future<void> _checkAnswer() async {
    final exercise = _steps[_currentStep].exercise!;
    final option = exercise.options.firstWhere(
      (candidate) => candidate.id == _selectedOptionId,
    );
    await widget.progressController.recordFirstAttempt(
      widget.lesson.id,
      exercise.id,
      correct: option.isCorrect,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _answerChecked = true;
      if (option.isCorrect) {
        _solvedExerciseIds.add(exercise.id);
      }
    });
    if (option.isCorrect) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  void _retry() {
    setState(() {
      _selectedOptionId = null;
      _answerChecked = false;
    });
  }

  Future<void> _advance() async {
    if (!_canGoForward) {
      return;
    }
    final nextStep = _currentStep + 1;
    if (nextStep == _steps.length - 1) {
      final correctAnswers = _activeExercises.where((exercise) {
        return widget.progressController.firstAttemptResult(
              widget.lesson.id,
              exercise.id,
            ) ==
            true;
      }).length;
      final mastery = (correctAnswers * 100 / _activeExercises.length).round();
      await widget.progressController.complete(
        widget.lesson.id,
        nextStep,
        mastery: mastery,
      );
      HapticFeedback.mediumImpact();
    } else {
      await widget.progressController.saveStep(widget.lesson.id, nextStep);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _currentStep = nextStep;
      _syncAnswerState(nextStep);
    });
  }

  bool get _canGoBack => _currentStep > 0;

  bool get _canGoForward {
    if (_currentStep >= _steps.length - 1) {
      return false;
    }
    final step = _steps[_currentStep];
    if (step.kind != _StepKind.exercise) {
      return true;
    }
    return _solvedExerciseIds.contains(step.exercise!.id);
  }

  Future<void> _goToPrevious() async {
    if (!_canGoBack) {
      return;
    }
    final previousStep = _currentStep - 1;
    await widget.progressController.saveStep(widget.lesson.id, previousStep);
    if (!mounted) {
      return;
    }
    setState(() {
      _currentStep = previousStep;
      _syncAnswerState(previousStep);
    });
  }

  void _restoreSolvedExercises() {
    for (final exercise in _activeExercises) {
      final result = widget.progressController.firstAttemptResult(
        widget.lesson.id,
        exercise.id,
      );
      if (result == true) {
        _solvedExerciseIds.add(exercise.id);
      }
    }
  }

  void _syncAnswerState(int index) {
    final step = _steps[index];
    final exercise = step.exercise;
    if (step.kind == _StepKind.exercise &&
        exercise != null &&
        _solvedExerciseIds.contains(exercise.id)) {
      _selectedOptionId = exercise.options
          .where((option) => option.isCorrect)
          .firstOrNull
          ?.id;
      _answerChecked = _selectedOptionId != null;
      return;
    }
    _selectedOptionId = null;
    _answerChecked = false;
  }

  Future<void> _restart() async {
    await widget.progressController.restart(widget.lesson.id);
    if (!mounted) {
      return;
    }
    setState(() {
      _activeExercises = _exercisesForAttempt();
      _steps = _buildSteps(widget.lesson, _activeExercises);
      _currentStep = 0;
      _solvedExerciseIds.clear();
      _selectedOptionId = null;
      _answerChecked = false;
    });
  }

  List<Exercise> _exercisesForAttempt() {
    final repeatExercises = widget.lesson.repeatExercises;
    final attempt = widget.progressController.attemptsFor(widget.lesson.id);
    if (repeatExercises.isNotEmpty && attempt.isOdd) {
      return _randomizeOptions(repeatExercises);
    }
    return _randomizeOptions(widget.lesson.exercises);
  }

  List<Exercise> _randomizeOptions(List<Exercise> exercises) {
    final random = Random();
    return [
      for (final exercise in exercises)
        Exercise(
          id: exercise.id,
          type: exercise.type,
          prompt: exercise.prompt,
          options: _randomizeExerciseOptions(exercise.options, random),
        ),
    ];
  }

  List<ExerciseOption> _randomizeExerciseOptions(
    List<ExerciseOption> options,
    Random random,
  ) {
    final shuffled = [...options]..shuffle(random);
    if (shuffled.length > 1 && shuffled.first.isCorrect) {
      final incorrectIndex = shuffled.indexWhere((option) => !option.isCorrect);
      if (incorrectIndex > 0) {
        final first = shuffled.first;
        shuffled[0] = shuffled[incorrectIndex];
        shuffled[incorrectIndex] = first;
      }
    }
    return shuffled;
  }

  static List<_LessonStep> _buildSteps(
    Lesson lesson,
    List<Exercise> exercises,
  ) {
    return [
      const _LessonStep.objectives(),
      for (final section in lesson.sections) ...[
        _LessonStep.teaching(section),
        for (final example in section.examples) _LessonStep.analysis(example),
      ],
      for (final exercise in exercises) _LessonStep.exercise(exercise),
      const _LessonStep.completion(),
    ];
  }
}

enum _StepKind { objectives, teaching, exercise, analysis, completion }

class _LessonStep {
  const _LessonStep.objectives()
    : kind = _StepKind.objectives,
      section = null,
      exercise = null,
      example = null;

  const _LessonStep.teaching(this.section)
    : kind = _StepKind.teaching,
      exercise = null,
      example = null;

  const _LessonStep.exercise(this.exercise)
    : kind = _StepKind.exercise,
      section = null,
      example = null;

  const _LessonStep.analysis(this.example)
    : kind = _StepKind.analysis,
      section = null,
      exercise = null;

  const _LessonStep.completion()
    : kind = _StepKind.completion,
      section = null,
      exercise = null,
      example = null;

  final _StepKind kind;
  final LessonSection? section;
  final Exercise? exercise;
  final GrammarExample? example;
}

class _ObjectivesStep extends StatefulWidget {
  const _ObjectivesStep({
    required this.lesson,
    required this.languageCode,
    required this.learningMode,
    required this.onContinue,
  });

  final Lesson lesson;
  final String languageCode;
  final LearningMode learningMode;
  final VoidCallback onContinue;

  @override
  State<_ObjectivesStep> createState() => _ObjectivesStepState();
}

class _ObjectivesStepState extends State<_ObjectivesStep> {
  final Set<int> _checkedIndices = <int>{};

  void _toggleObjective(int index, String text) {
    HapticFeedback.selectionClick();
    setState(() {
      if (!_checkedIndices.remove(index)) {
        _checkedIndices.add(index);
      }
    });
    ArabicSpeechHelper.instance.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<LearningColors>()!;
    final isYoungLearner = widget.learningMode == LearningMode.simple;
    final allObjectivesSpeech = widget.lesson.objectives
        .map((o) => o.forLanguage(widget.languageCode))
        .join('، ');

    return _StepLayout(
      icon: Icons.flag_outlined,
      headerWidget: isYoungLearner
          ? DuolingoCharacterHeader(
              character: CartoonCharacterKind.boy,
              speakerName: 'عُمَر يَقُولُ:',
              message: _checkedIndices.isEmpty
                  ? 'مَرْحَبًا! اضْغَطْ عَلَى أَهْدَافِ الدَّرْسِ لِنَسْتَعِدَّ مَعًا! 🚀'
                  : 'رَائِع يَا بَطَل! أَنْتَ مُسْتَعِدٌّ لِهَذَا الدَّرْسِ المُمْتِع! ⭐',
              mood: _checkedIndices.isEmpty
                  ? MascotMood.happy
                  : MascotMood.cheering,
              speechText: allObjectivesSpeech,
            )
          : null,
      title: l10n.objectivesTitle,
      body: Card(
        color: colors.blueContainer,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              for (final entry in widget.lesson.objectives.indexed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _toggleObjective(
                      entry.$1,
                      entry.$2.forLanguage(widget.languageCode),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _checkedIndices.contains(entry.$1)
                            ? Colors.white.withValues(alpha: 0.45)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _checkedIndices.contains(entry.$1)
                                ? Icons.check_circle_rounded
                                : Icons.check_circle_outline,
                            color: colors.onBlueContainer,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ArabicDiacriticsText(
                              entry.$2.forLanguage(widget.languageCode),
                              style: TextStyle(
                                color: colors.onBlueContainer,
                                fontSize: 19,
                                fontWeight: _checkedIndices.contains(entry.$1)
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.volume_up_rounded,
                            size: 18,
                            color: colors.onBlueContainer.withValues(
                              alpha: 0.75,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      action: FilledButton(
        onPressed: widget.onContinue,
        child: Text(l10n.continueLabel),
      ),
    );
  }
}

class _TeachingStep extends StatelessWidget {
  const _TeachingStep({
    required this.section,
    required this.languageCode,
    required this.learningMode,
    required this.onContinue,
  });

  final LessonSection section;
  final String languageCode;
  final LearningMode learningMode;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final example = section.examples.firstOrNull;
    final bodyText = section.body.forLanguage(languageCode);
    final isYoungLearner = learningMode == LearningMode.simple;

    return _StepLayout(
      icon: Icons.lightbulb_outline,
      headerWidget: isYoungLearner
          ? DuolingoCharacterHeader(
              character: CartoonCharacterKind.girl,
              speakerName: 'مَرْيَم تَشْرَحُ:',
              message:
                  'اضْغَطْ هُنَا لِتَسْمَعَ الشَّرْحَ، ثُمَّ اضْغَطْ عَلَى كَلِمَاتِ المِثَالِ! 💡',
              speechText: bodyText,
            )
          : null,
      title: section.title.forLanguage(languageCode),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              ArabicSpeechHelper.instance.speak(bodyText);
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ArabicDiacriticsText(
                bodyText,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          if (example != null) ...[
            const SizedBox(height: 24),
            _SentenceCard(example: example, languageCode: languageCode),
          ],
        ],
      ),
      action: FilledButton(
        onPressed: onContinue,
        child: Text(l10n.continueLabel),
      ),
    );
  }
}

class _ExerciseStep extends StatelessWidget {
  const _ExerciseStep({
    required this.exercise,
    required this.languageCode,
    required this.learningMode,
    required this.selectedOptionId,
    required this.answerChecked,
    required this.onSelect,
    required this.onCheck,
    required this.onRetry,
    required this.onContinue,
  });

  final Exercise exercise;
  final String languageCode;
  final LearningMode learningMode;
  final String? selectedOptionId;
  final bool answerChecked;
  final ValueChanged<String> onSelect;
  final VoidCallback onCheck;
  final VoidCallback onRetry;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final selected = selectedOptionId == null
        ? null
        : exercise.options.firstWhere(
            (option) => option.id == selectedOptionId,
          );
    return _QuestionLayout(
      prompt: exercise.prompt.forLanguage(languageCode),
      learningMode: learningMode,
      options: [
        for (final option in exercise.options)
          _AnswerOption(
            id: option.id,
            label: option.label.forLanguage(languageCode),
          ),
      ],
      selectedOptionId: selectedOptionId,
      answerChecked: answerChecked,
      isCorrect: selected?.isCorrect ?? false,
      feedback: selected?.feedback.forLanguage(languageCode),
      onSelect: onSelect,
      onCheck: onCheck,
      onRetry: onRetry,
      onContinue: onContinue,
    );
  }
}

class _QuestionLayout extends StatelessWidget {
  const _QuestionLayout({
    required this.prompt,
    required this.learningMode,
    required this.options,
    required this.selectedOptionId,
    required this.answerChecked,
    required this.isCorrect,
    required this.feedback,
    required this.onSelect,
    required this.onCheck,
    required this.onRetry,
    required this.onContinue,
  });

  final String prompt;
  final LearningMode learningMode;
  final List<_AnswerOption> options;
  final String? selectedOptionId;
  final bool answerChecked;
  final bool isCorrect;
  final String? feedback;
  final ValueChanged<String> onSelect;
  final VoidCallback onCheck;
  final VoidCallback onRetry;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final questionTitle = switch (learningMode) {
      LearningMode.simple => l10n.quickCheckTitle,
      LearningMode.detailed => l10n.learningModeDetailedQuestionTitle,
      LearningMode.adult => l10n.learningModeAdultQuestionTitle,
    };
    final questionHint = switch (learningMode) {
      LearningMode.simple => l10n.youngLearnerQuestionHint,
      LearningMode.detailed => l10n.learningModeDetailedQuestionHint,
      LearningMode.adult => l10n.learningModeAdultQuestionHint,
    };
    return _StepLayout(
      icon: Icons.quiz_outlined,
      headerWidget: learningMode == LearningMode.simple
          ? InteractiveQuestionCompanion(
              hint: questionHint,
              answerChecked: answerChecked,
              isCorrect: isCorrect,
              questionPrompt: prompt,
            )
          : null,
      title: questionTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              ArabicSpeechHelper.instance.speak(prompt);
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ArabicDiacriticsText(
                      prompt,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.volume_up_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          ArabicDiacriticsText(
            questionHint,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OptionButton(
                option: option,
                selected: selectedOptionId == option.id,
                disabled: answerChecked,
                onPressed: () {
                  ArabicSpeechHelper.instance.speak(option.label);
                  onSelect(option.id);
                },
              ),
            ),
          if (answerChecked && feedback != null)
            _FeedbackCard(isCorrect: isCorrect, feedback: feedback!),
        ],
      ),
      action: answerChecked
          ? FilledButton(
              onPressed: isCorrect ? onContinue : onRetry,
              child: Text(isCorrect ? l10n.continueLabel : l10n.tryAgain),
            )
          : FilledButton(
              onPressed: selectedOptionId == null ? null : onCheck,
              child: Text(l10n.checkAnswer),
            ),
    );
  }
}

class _AnswerOption {
  const _AnswerOption({required this.id, required this.label});

  final String id;
  final String label;
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.option,
    required this.selected,
    required this.disabled,
    required this.onPressed,
  });

  final _AnswerOption option;
  final bool selected;
  final bool disabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final borderColor = selected ? scheme.primary : scheme.outlineVariant;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: selected ? 0.45 : 0.25),
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: OutlinedButton(
        onPressed: disabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          alignment: AlignmentDirectional.centerStart,
          backgroundColor: selected ? scheme.primaryContainer : scheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          side: BorderSide(width: selected ? 2.5 : 1.5, color: borderColor),
          padding: const EdgeInsets.all(18),
        ),
        child: ArabicDiacriticsText(
          option.label,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.isCorrect, required this.feedback});

  final bool isCorrect;
  final String feedback;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = isCorrect
        ? Colors.green.withValues(alpha: 0.14)
        : Theme.of(context).colorScheme.errorContainer;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCorrect)
            CorrectAnswerCelebration(
              title: l10n.correctAnswerTitle,
              body: feedback.trim().isNotEmpty
                  ? feedback
                  : l10n.correctAnswerCelebration,
            )
          else ...[
            Row(
              children: [
                const Icon(Icons.refresh),
                const SizedBox(width: 8),
                Text(
                  l10n.incorrectAnswerTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ArabicDiacriticsText(feedback),
          ],
        ],
      ),
    );
  }
}

class _AnalysisStep extends StatefulWidget {
  const _AnalysisStep({
    required this.example,
    required this.languageCode,
    required this.learningMode,
    required this.userDataController,
    required this.onContinue,
  });

  final GrammarExample example;
  final String languageCode;
  final LearningMode learningMode;
  final UserDataController userDataController;
  final VoidCallback onContinue;

  @override
  State<_AnalysisStep> createState() => _AnalysisStepState();
}

class _AnalysisStepState extends State<_AnalysisStep> {
  int? _selectedToken;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = _selectedToken == null
        ? null
        : widget.example.tokens[_selectedToken!];
    final isYoungLearner = widget.learningMode == LearningMode.simple;

    return _StepLayout(
      icon: Icons.touch_app_outlined,
      headerWidget: isYoungLearner
          ? DuolingoCharacterHeader(
              character: CartoonCharacterKind.boy,
              speakerName: 'عُمَر يَسْأَلُكَ:',
              mood: selected == null ? MascotMood.happy : MascotMood.cheering,
              message: selected == null
                  ? 'اضْغَطْ عَلَى أَيِّ كَلِمَةٍ لِنَكْتَشِفَ سِرَّ حَرَكَتِهَا! 🔍'
                  : 'أَحْسَنْتَ! «${selected.displayText}» — ${selected.role.forLanguage(widget.languageCode)} 🌟',
              speechText: selected == null
                  ? widget.example.vocalized
                  : '${selected.displayText}: ${selected.role.forLanguage(widget.languageCode)}',
            )
          : null,
      title: l10n.exploreWordsTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.exploreWordsBody),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            textDirection: TextDirection.rtl,
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final entry in widget.example.tokens.indexed)
                ChoiceChip(
                  selected: _selectedToken == entry.$1,
                  label: Text(
                    entry.$2.displayText,
                    style: const TextStyle(
                      fontFamily: 'AmiriQuran',
                      fontSize: 30,
                    ),
                  ),
                  onSelected: (_) {
                    setState(() => _selectedToken = entry.$1);
                    HapticFeedback.selectionClick();
                    ArabicSpeechHelper.instance.speak(entry.$2.displayText);
                  },
                ),
            ],
          ),
          if (selected != null) ...[
            const SizedBox(height: 20),
            _TokenCard(
              token: selected,
              languageCode: widget.languageCode,
              learningMode: widget.learningMode,
            ),
          ],
        ],
      ),
      action: AnimatedBuilder(
        animation: widget.userDataController,
        builder: (context, _) {
          final bookmarked = widget.userDataController.isBookmarked(
            BookmarkType.example,
            widget.example.id,
          );
          return Row(
            children: [
              IconButton.filledTonal(
                tooltip: bookmarked ? l10n.removeBookmark : l10n.addBookmark,
                onPressed: () => widget.userDataController.toggleBookmark(
                  BookmarkType.example,
                  widget.example.id,
                ),
                icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: selected == null ? null : widget.onContinue,
                  child: Text(l10n.continueLabel),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TokenCard extends StatelessWidget {
  const _TokenCard({
    required this.token,
    required this.languageCode,
    required this.learningMode,
  });

  final GrammarToken token;
  final String languageCode;
  final LearningMode learningMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<LearningColors>()!;
    final isIndeclinable = token.grammarState == GrammarState.indeclinable;
    final state = isIndeclinable
        ? token.grammaticalSign.forLanguage(languageCode)
        : _grammarState(token.grammarState, l10n);
    return Card(
      color: colors.sunshineContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _AnalysisRow(
              label: l10n.roleLabel,
              value: token.role.forLanguage(languageCode),
            ),
            if (learningMode != LearningMode.simple) ...[
              _AnalysisRow(label: l10n.stateLabel, value: state),
              if (!isIndeclinable)
                _AnalysisRow(
                  label: l10n.signLabel,
                  value: token.grammaticalSign.forLanguage(languageCode),
                  accessory: _EndingMark(ending: token.ending),
                ),
              _AnalysisRow(
                label: l10n.reasonLabel,
                value: token.reason.forLanguage(languageCode),
              ),
            ] else ...[
              if (!isIndeclinable)
                _AnalysisRow(
                  label: l10n.signLabel,
                  value: token.grammaticalSign.forLanguage(languageCode),
                  accessory: _EndingMark(ending: token.ending),
                ),
              _AnalysisRow(
                label: l10n.reasonLabel,
                value: token.reason.forLanguage(languageCode),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _grammarState(GrammarState state, AppLocalizations l10n) {
    return switch (state) {
      GrammarState.raf => l10n.grammarStateRaf,
      GrammarState.nasb => l10n.grammarStateNasb,
      GrammarState.jarr => l10n.grammarStateJarr,
      GrammarState.jazm => l10n.grammarStateJazm,
      GrammarState.indeclinable => l10n.grammarStateIndeclinable,
    };
  }
}

class _EndingMark extends StatelessWidget {
  const _EndingMark({required this.ending});

  final String ending;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LearningColors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.blueContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ArabicDiacriticsText(
        'ـ$ending',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colors.onBlueContainer,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.35,
        ),
      ),
    );
  }
}

class _AnalysisRow extends StatelessWidget {
  const _AnalysisRow({
    required this.label,
    required this.value,
    this.accessory,
  });

  final String label;
  final String value;
  final Widget? accessory;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ArabicDiacriticsText(value),
                if (accessory != null) ...[
                  const SizedBox(height: 6),
                  accessory!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionStep extends StatefulWidget {
  const _CompletionStep({
    required this.mastery,
    required this.progressController,
    required this.onRestart,
    required this.onClose,
  });

  final int mastery;
  final LessonProgressController progressController;
  final VoidCallback onRestart;
  final VoidCallback onClose;

  @override
  State<_CompletionStep> createState() => _CompletionStepState();
}

class _CompletionStepState extends State<_CompletionStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<LearningColors>()!;
    final passed = widget.mastery >= 70;
    return _StepLayout(
      icon: passed ? Icons.celebration : Icons.refresh_rounded,
      title: passed
          ? l10n.lessonCompleteTitle
          : (_languageCode(context) == 'ar'
                ? 'تدرَّب مرة أخرى'
                : 'Practice again'),
      body: Column(
        children: [
          if (passed && widget.mastery == 100)
            MilestoneCelebrationBanner(
              icon: Icons.emoji_events,
              title: l10n.perfectScoreMilestoneTitle,
              body: l10n.perfectScoreMilestoneBody,
            )
          else if (passed && widget.progressController.isStreakMilestone)
            MilestoneCelebrationBanner(
              title: l10n.streakMilestoneTitle(
                localizedNumber(context, widget.progressController.streakCount),
              ),
              body: l10n.streakMilestoneBody,
            ),
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              curve: Curves.elasticOut,
            ),
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: colors.sunshineContainer,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: YoungLearnerMascot(
                kind: CartoonCharacterKind.duo,
                size: 112,
                mood: passed ? MascotMood.cheering : MascotMood.encouraging,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _languageCode(context) == 'ar'
                ? 'الإتقان: ${localizedPercent(context, widget.mastery)}'
                : 'Mastery: ${localizedPercent(context, widget.mastery)}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            passed
                ? l10n.lessonCompleteBody
                : (_languageCode(context) == 'ar'
                      ? 'تحتاج إلى ${localizedPercent(context, 70)} لفتح الدرس التالي. الأخطاء جزء من التعلُّم، والمحاولة الجديدة بلا عقوبة.'
                      : 'You need 70% to unlock the next lesson. Mistakes are part of learning, and a new attempt has no penalty.'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
      action: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (passed)
            FilledButton(
              onPressed: widget.onClose,
              child: Text(l10n.returnToLessons),
            ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: widget.onRestart,
            child: Text(l10n.restartLesson),
          ),
        ],
      ),
    );
  }

  String _languageCode(BuildContext context) =>
      Localizations.localeOf(context).languageCode;
}

class _SentenceCard extends StatefulWidget {
  const _SentenceCard({required this.example, required this.languageCode});

  final GrammarExample example;
  final String languageCode;

  @override
  State<_SentenceCard> createState() => _SentenceCardState();
}

class _SentenceCardState extends State<_SentenceCard> {
  int? _activeTokenIndex;

  void _selectToken(int index) {
    HapticFeedback.selectionClick();
    final token = widget.example.tokens[index];
    setState(() {
      _activeTokenIndex = _activeTokenIndex == index ? null : index;
    });
    ArabicSpeechHelper.instance.speak(token.displayText);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LearningColors>()!;
    final scheme = Theme.of(context).colorScheme;
    final activeToken =
        _activeTokenIndex != null &&
            _activeTokenIndex! < widget.example.tokens.length
        ? widget.example.tokens[_activeTokenIndex!]
        : null;

    return Card(
      color: colors.sunshineContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ArabicSpeechHelper.instance.speak(widget.example.vocalized);
                },
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: ArabicDiacriticsText(
                          widget.example.vocalized,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontFamily: 'AmiriQuran',
                                color: colors.onSunshineContainer,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.volume_up_rounded,
                        color: colors.onSunshineContainer,
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.example.tokens.length > 1) ...[
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final entry in widget.example.tokens.indexed)
                      ActionChip(
                        avatar: Icon(
                          _activeTokenIndex == entry.$1
                              ? Icons.auto_awesome_rounded
                              : Icons.touch_app_rounded,
                          size: 16,
                          color: _activeTokenIndex == entry.$1
                              ? scheme.primary
                              : colors.onSunshineContainer,
                        ),
                        backgroundColor: _activeTokenIndex == entry.$1
                            ? scheme.primaryContainer
                            : scheme.surface.withValues(alpha: 0.9),
                        label: Text(
                          '🔍 ${entry.$2.displayText}',
                          style: const TextStyle(
                            fontFamily: 'AmiriQuran',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: () => _selectToken(entry.$1),
                      ),
                  ],
                ),
              ],
              if (activeToken != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: scheme.primary.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (activeToken.grammarState != GrammarState.indeclinable)
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: _EndingMark(ending: activeToken.ending),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ArabicDiacriticsText(
                              activeToken.role.forLanguage(widget.languageCode),
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: scheme.primary,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            ArabicDiacriticsText(
                              activeToken.reason.forLanguage(
                                widget.languageCode,
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StepLayout extends StatelessWidget {
  const _StepLayout({
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
    this.headerWidget,
  });

  final IconData icon;
  final Widget? headerWidget;
  final String title;
  final Widget body;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 520),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          headerWidget ??
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
          const SizedBox(height: 12),
          ArabicDiacriticsText(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          body,
          const SizedBox(height: 28),
          action,
        ],
      ),
    );
  }
}
