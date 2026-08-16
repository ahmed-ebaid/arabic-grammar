import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/content_models.dart';
import '../../core/progress/lesson_progress_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class LessonDetailScreen extends StatefulWidget {
  const LessonDetailScreen({
    required this.lesson,
    required this.progressController,
    super.key,
  });

  final Lesson lesson;
  final LessonProgressController progressController;

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  late final List<_LessonStep> _steps = _buildSteps(widget.lesson);
  late int _currentStep = widget.progressController
      .stepFor(widget.lesson.id)
      .clamp(0, _steps.length - 1);
  String? _selectedOptionId;
  bool _answerChecked = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final step = _steps[_currentStep];
    final progress = (_currentStep + 1) / _steps.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title.forLanguage(_languageCode)),
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
                        l10n.stepProgress(_currentStep + 1, _steps.length),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
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
                  key: ValueKey(_currentStep),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: _buildStep(step),
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
    return switch (step.kind) {
      _StepKind.objectives => _ObjectivesStep(
        lesson: widget.lesson,
        languageCode: _languageCode,
        onContinue: _advance,
      ),
      _StepKind.teaching => _TeachingStep(
        section: step.section!,
        languageCode: _languageCode,
        onContinue: _advance,
      ),
      _StepKind.exercise => _ExerciseStep(
        exercise: step.exercise!,
        languageCode: _languageCode,
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
        onContinue: _advance,
      ),
      _StepKind.completion => _CompletionStep(
        mastery: widget.progressController.masteryFor(widget.lesson.id),
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
    setState(() => _answerChecked = true);
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
    if (_currentStep >= _steps.length - 1) {
      return;
    }
    final nextStep = _currentStep + 1;
    if (nextStep == _steps.length - 1) {
      final correctAnswers = widget.lesson.exercises.where((exercise) {
        return widget.progressController.firstAttemptResult(
              widget.lesson.id,
              exercise.id,
            ) ==
            true;
      }).length;
      final mastery = (correctAnswers * 100 / widget.lesson.exercises.length)
          .round();
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
      _selectedOptionId = null;
      _answerChecked = false;
    });
  }

  Future<void> _restart() async {
    await widget.progressController.restart(widget.lesson.id);
    if (!mounted) {
      return;
    }
    setState(() {
      _currentStep = 0;
      _selectedOptionId = null;
      _answerChecked = false;
    });
  }

  static List<_LessonStep> _buildSteps(Lesson lesson) {
    return [
      const _LessonStep.objectives(),
      for (final section in lesson.sections) ...[
        _LessonStep.teaching(section),
        for (final example in section.examples) _LessonStep.analysis(example),
      ],
      for (final exercise in lesson.exercises) _LessonStep.exercise(exercise),
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

class _ObjectivesStep extends StatelessWidget {
  const _ObjectivesStep({
    required this.lesson,
    required this.languageCode,
    required this.onContinue,
  });

  final Lesson lesson;
  final String languageCode;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<LearningColors>()!;
    return _StepLayout(
      icon: Icons.flag_outlined,
      title: l10n.objectivesTitle,
      body: Card(
        color: colors.blueContainer,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              for (final objective in lesson.objectives)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: colors.onBlueContainer,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          objective.forLanguage(languageCode),
                          style: TextStyle(
                            color: colors.onBlueContainer,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      action: FilledButton(
        onPressed: onContinue,
        child: Text(l10n.continueLabel),
      ),
    );
  }
}

class _TeachingStep extends StatelessWidget {
  const _TeachingStep({
    required this.section,
    required this.languageCode,
    required this.onContinue,
  });

  final LessonSection section;
  final String languageCode;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final example = section.examples.firstOrNull;
    return _StepLayout(
      icon: Icons.lightbulb_outline,
      title: section.title.forLanguage(languageCode),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            section.body.forLanguage(languageCode),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (example != null) ...[
            const SizedBox(height: 24),
            _SentenceCard(example: example),
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
    required this.selectedOptionId,
    required this.answerChecked,
    required this.onSelect,
    required this.onCheck,
    required this.onRetry,
    required this.onContinue,
  });

  final Exercise exercise;
  final String languageCode;
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
    return _StepLayout(
      icon: Icons.quiz_outlined,
      title: l10n.quickCheckTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(prompt, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _OptionButton(
                option: option,
                selected: selectedOptionId == option.id,
                disabled: answerChecked,
                onPressed: () => onSelect(option.id),
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
    return OutlinedButton(
      onPressed: disabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        alignment: AlignmentDirectional.centerStart,
        backgroundColor: selected
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        side: BorderSide(
          width: selected ? 2 : 1,
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
        ),
        padding: const EdgeInsets.all(18),
      ),
      child: Text(
        option.label,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
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
          Row(
            children: [
              Icon(isCorrect ? Icons.check_circle : Icons.refresh),
              const SizedBox(width: 8),
              Text(
                isCorrect ? l10n.correctAnswerTitle : l10n.incorrectAnswerTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(feedback),
        ],
      ),
    );
  }
}

class _AnalysisStep extends StatefulWidget {
  const _AnalysisStep({
    required this.example,
    required this.languageCode,
    required this.onContinue,
  });

  final GrammarExample example;
  final String languageCode;
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
    return _StepLayout(
      icon: Icons.touch_app_outlined,
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
                    '${entry.$2.text}${entry.$2.ending}',
                    style: const TextStyle(
                      fontFamily: 'AmiriQuran',
                      fontSize: 24,
                    ),
                  ),
                  onSelected: (_) {
                    setState(() => _selectedToken = entry.$1);
                    HapticFeedback.selectionClick();
                  },
                ),
            ],
          ),
          if (selected != null) ...[
            const SizedBox(height: 20),
            _TokenCard(token: selected, languageCode: widget.languageCode),
          ],
        ],
      ),
      action: FilledButton(
        onPressed: selected == null ? null : widget.onContinue,
        child: Text(l10n.continueLabel),
      ),
    );
  }
}

class _TokenCard extends StatelessWidget {
  const _TokenCard({required this.token, required this.languageCode});

  final GrammarToken token;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<LearningColors>()!;
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
            _AnalysisRow(
              label: l10n.stateLabel,
              value: _grammarState(token.grammarState, languageCode),
            ),
            _AnalysisRow(
              label: l10n.signLabel,
              value: token.grammaticalSign.forLanguage(languageCode),
            ),
            _AnalysisRow(label: l10n.endingLabel, value: token.ending),
            _AnalysisRow(
              label: l10n.reasonLabel,
              value: token.reason.forLanguage(languageCode),
            ),
          ],
        ),
      ),
    );
  }

  String _grammarState(GrammarState state, String languageCode) {
    if (languageCode == 'ar') {
      return switch (state) {
        GrammarState.raf => 'رفع',
        GrammarState.nasb => 'نصب',
        GrammarState.jarr => 'جر',
        GrammarState.jazm => 'جزم',
        GrammarState.indeclinable => 'مبني',
      };
    }
    return switch (state) {
      GrammarState.raf => 'Raf',
      GrammarState.nasb => 'Nasb',
      GrammarState.jarr => 'Jarr',
      GrammarState.jazm => 'Jazm',
      GrammarState.indeclinable => 'Indeclinable',
    };
  }
}

class _AnalysisRow extends StatelessWidget {
  const _AnalysisRow({required this.label, required this.value});

  final String label;
  final String value;

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
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _CompletionStep extends StatefulWidget {
  const _CompletionStep({
    required this.mastery,
    required this.onRestart,
    required this.onClose,
  });

  final int mastery;
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
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              curve: Curves.elasticOut,
            ),
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: colors.sunshineContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                passed ? Icons.star_rounded : Icons.school_rounded,
                size: 96,
                color: colors.onSunshineContainer,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _languageCode(context) == 'ar'
                ? 'الإتقان: ${widget.mastery}%'
                : 'Mastery: ${widget.mastery}%',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            passed
                ? l10n.lessonCompleteBody
                : (_languageCode(context) == 'ar'
                      ? 'تحتاج إلى 70% لفتح الدرس التالي. الأخطاء جزء من التعلُّم، والمحاولة الجديدة بلا عقوبة.'
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

class _SentenceCard extends StatelessWidget {
  const _SentenceCard({required this.example});

  final GrammarExample example;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LearningColors>()!;
    return Card(
      color: colors.sunshineContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            example.vocalized,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontFamily: 'AmiriQuran',
              color: colors.onSunshineContainer,
            ),
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
  });

  final IconData icon;
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
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(
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
