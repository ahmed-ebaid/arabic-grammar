import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/content_models.dart';
import '../../core/progress/lesson_progress_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/user/user_data_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/learning_illustration.dart';
import 'practice_rewards.dart';

enum PracticeMode { mixed, weakAreas }

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({
    required this.progressController,
    required this.userDataController,
    this.contentCatalog,
    super.key,
  });

  final ContentCatalog? contentCatalog;
  final LessonProgressController progressController;
  final UserDataController userDataController;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  static const _sessionLength = 10;
  late final Future<ContentCatalog> _catalog = widget.contentCatalog == null
      ? _loadCatalog()
      : Future.value(widget.contentCatalog);

  List<_PracticeQuestion>? _questions;
  PracticeMode? _mode;
  var _questionIndex = 0;
  var _correctFirstAttempts = 0;
  var _answerChecked = false;
  var _firstAttemptRecorded = false;
  var _sessionComplete = false;
  String? _selectedOptionId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ContentCatalog>(
      future: _catalog,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(AppLocalizations.of(context).contentLoadError),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_questions == null) {
          return _PracticeLanding(
            progressController: widget.progressController,
            onStart: (mode) => _startSession(snapshot.data!, mode),
          );
        }
        if (_sessionComplete) {
          return _PracticeComplete(
            correct: _correctFirstAttempts,
            total: _questions!.length,
            progressController: widget.progressController,
            onPracticeAgain: () => setState(() {
              _questions = null;
              _mode = null;
              _sessionComplete = false;
            }),
          );
        }
        return _buildQuestion(context);
      },
    );
  }

  Widget _buildQuestion(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final question = _questions![_questionIndex];
    final selected = question.options
        .where((option) => option.id == _selectedOptionId)
        .firstOrNull;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: (_questionIndex + 1) / _questions!.length,
                minHeight: 10,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 12),
            Text('${_questionIndex + 1}/${_questions!.length}'),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          _mode == PracticeMode.weakAreas
              ? l10n.practiceWeakAreasTitle
              : l10n.practiceMixedTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          question.lesson.title.forLanguage(languageCode),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 24),
        Text(
          question.exercise.prompt.forLanguage(languageCode),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        for (final option in question.options)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton(
              onPressed: _answerChecked
                  ? null
                  : () => setState(() => _selectedOptionId = option.id),
              style: OutlinedButton.styleFrom(
                alignment: AlignmentDirectional.centerStart,
                backgroundColor: _selectedOptionId == option.id
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                padding: const EdgeInsets.all(18),
              ),
              child: Text(
                option.label.forLanguage(languageCode),
                style: const TextStyle(fontSize: 17),
              ),
            ),
          ),
        if (_answerChecked && selected != null) ...[
          const SizedBox(height: 8),
          Card(
            color: selected.isCorrect
                ? Colors.green.withValues(alpha: 0.14)
                : Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    selected.isCorrect
                        ? l10n.correctAnswerTitle
                        : l10n.incorrectAnswerTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(selected.feedback.forLanguage(languageCode)),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _answerChecked
              ? selected!.isCorrect
                    ? _continue
                    : _retry
              : _selectedOptionId == null
              ? null
              : _checkAnswer,
          child: Text(
            _answerChecked
                ? selected!.isCorrect
                      ? l10n.continueLabel
                      : l10n.tryAgain
                : l10n.checkAnswer,
          ),
        ),
      ],
    );
  }

  void _startSession(ContentCatalog catalog, PracticeMode mode) {
    final candidates = <_PracticeCandidate>[];
    for (final lesson in catalog.lessons) {
      final attempted =
          widget.progressController.attemptsFor(lesson.id) > 0 ||
          widget.progressController.stepFor(lesson.id) > 0;
      final unlocked = lesson.prerequisites.every(
        widget.progressController.isMastered,
      );
      if (!attempted && !unlocked) {
        continue;
      }

      final weakLesson =
          attempted && widget.progressController.masteryFor(lesson.id) < 70;
      for (final exercise in [...lesson.exercises, ...lesson.repeatExercises]) {
        candidates.add(
          _PracticeCandidate(
            lesson: lesson,
            exercise: exercise,
            weakLesson: weakLesson,
            reviewDue: widget.userDataController.isReviewDue(
              lesson.id,
              exercise.id,
            ),
            previouslyMissed:
                widget.progressController.firstAttemptResult(
                  lesson.id,
                  exercise.id,
                ) ==
                false,
          ),
        );
      }
    }

    final random = Random();
    if (mode == PracticeMode.weakAreas) {
      candidates.sort((a, b) => a.priority.compareTo(b.priority));
      for (var priority = 0; priority <= 4; priority++) {
        final matching =
            candidates
                .where((candidate) => candidate.priority == priority)
                .toList()
              ..shuffle(random);
        var insertAt = candidates.indexWhere(
          (candidate) => candidate.priority == priority,
        );
        if (insertAt >= 0) {
          candidates.replaceRange(
            insertAt,
            insertAt + matching.length,
            matching,
          );
        }
      }
    } else {
      candidates.shuffle(random);
    }

    final questions = <_PracticeQuestion>[];
    for (var index = 0; index < _sessionLength; index++) {
      final candidate = candidates[index % candidates.length];
      final options = [...candidate.exercise.options]..shuffle(random);
      questions.add(
        _PracticeQuestion(
          lesson: candidate.lesson,
          exercise: candidate.exercise,
          options: options,
        ),
      );
    }

    setState(() {
      _questions = questions;
      _mode = mode;
      _questionIndex = 0;
      _correctFirstAttempts = 0;
      _answerChecked = false;
      _firstAttemptRecorded = false;
      _selectedOptionId = null;
      _sessionComplete = false;
    });
  }

  Future<void> _checkAnswer() async {
    final question = _questions![_questionIndex];
    final selected = question.options.firstWhere(
      (option) => option.id == _selectedOptionId,
    );
    if (!_firstAttemptRecorded) {
      _firstAttemptRecorded = true;
      if (selected.isCorrect) {
        _correctFirstAttempts++;
      }
      await widget.userDataController.recordReviewResult(
        question.lesson.id,
        question.exercise.id,
        correct: selected.isCorrect,
      );
    }
    if (mounted) {
      setState(() => _answerChecked = true);
    }
  }

  void _retry() {
    setState(() {
      _selectedOptionId = null;
      _answerChecked = false;
    });
  }

  Future<void> _continue() async {
    if (_questionIndex < _questions!.length - 1) {
      setState(() {
        _questionIndex++;
        _selectedOptionId = null;
        _answerChecked = false;
        _firstAttemptRecorded = false;
      });
      return;
    }

    await widget.progressController.recordPracticeSession(
      answered: _questions!.length,
      correct: _correctFirstAttempts,
    );
    if (mounted) {
      setState(() => _sessionComplete = true);
    }
  }

  static Future<ContentCatalog> _loadCatalog() async {
    final source = await rootBundle.loadString('content/drafts/lesson_01.json');
    return ContentCatalog.fromJson(jsonDecode(source));
  }
}

class _PracticeLanding extends StatelessWidget {
  const _PracticeLanding({
    required this.progressController,
    required this.onStart,
  });

  final LessonProgressController progressController;
  final ValueChanged<PracticeMode> onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final learningColors = Theme.of(context).extension<LearningColors>()!;
    final dailyProgress = min(
      progressController.practiceDailyAnswered / 10,
      1.0,
    );

    return AnimatedBuilder(
      animation: progressController,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            color: learningColors.coralContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 52,
                    color: learningColors.onCoralContainer,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.practiceTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.practiceFamilySubtitle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.practiceDailyGoalTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: dailyProgress,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.practiceDailyGoalProgress(
                      min(progressController.practiceDailyAnswered, 10),
                      10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _ModeCard(
            icon: Icons.shuffle,
            title: l10n.practiceMixedTitle,
            body: l10n.practiceMixedBody,
            onTap: () => onStart(PracticeMode.mixed),
          ),
          const SizedBox(height: 12),
          _ModeCard(
            icon: Icons.fitness_center,
            title: l10n.practiceWeakAreasTitle,
            body: l10n.practiceWeakAreasBody,
            onTap: () => onStart(PracticeMode.weakAreas),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.practiceRewardsTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          PracticeRewardsWrap(progressController: progressController),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        leading: Icon(icon, size: 36),
        title: Text(title),
        subtitle: Text(body),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

class _PracticeComplete extends StatelessWidget {
  const _PracticeComplete({
    required this.correct,
    required this.total,
    required this.progressController,
    required this.onPracticeAgain,
  });

  final int correct;
  final int total;
  final LessonProgressController progressController;
  final VoidCallback onPracticeAgain;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final score = ((correct / total) * 100).round();
    final stars = score >= 90
        ? 3
        : score >= 70
        ? 2
        : 1;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LearningIllustration(
                  semanticLabel: l10n.celebrationIllustrationLabel,
                  celebrating: true,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.practiceCompleteTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.practiceScore(correct, total),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Icon(
                      index < stars ? Icons.star : Icons.star_border,
                      color: Colors.amber.shade700,
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(l10n.practiceStarsEarned(stars)),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onPracticeAgain,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.practiceAgain),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PracticeCandidate {
  const _PracticeCandidate({
    required this.lesson,
    required this.exercise,
    required this.weakLesson,
    required this.reviewDue,
    required this.previouslyMissed,
  });

  final Lesson lesson;
  final Exercise exercise;
  final bool weakLesson;
  final bool reviewDue;
  final bool previouslyMissed;

  int get priority {
    if (reviewDue) return 0;
    if (weakLesson && previouslyMissed) return 1;
    if (weakLesson) return 2;
    if (previouslyMissed) return 3;
    return 4;
  }
}

class _PracticeQuestion {
  const _PracticeQuestion({
    required this.lesson,
    required this.exercise,
    required this.options,
  });

  final Lesson lesson;
  final Exercise exercise;
  final List<ExerciseOption> options;
}
