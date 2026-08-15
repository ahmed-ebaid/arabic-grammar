import 'package:flutter/material.dart';

import '../../core/models/content_models.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class LessonDetailScreen extends StatelessWidget {
  const LessonDetailScreen({required this.lesson, super.key});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(lesson.title.forLanguage(languageCode))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            l10n.lessonNumber(lesson.order),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            lesson.title.forLanguage(languageCode),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(l10n.estimatedMinutes(lesson.estimatedMinutes)),
          const SizedBox(height: 20),
          _ObjectivesCard(
            objectives: lesson.objectives,
            languageCode: languageCode,
          ),
          const SizedBox(height: 12),
          for (final section in lesson.sections) ...[
            _LessonSectionCard(section: section, languageCode: languageCode),
            const SizedBox(height: 12),
          ],
          if (lesson.exercises.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              l10n.lessonPracticeTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            for (final exercise in lesson.exercises) ...[
              _ExerciseCard(exercise: exercise, languageCode: languageCode),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

class _ObjectivesCard extends StatelessWidget {
  const _ObjectivesCard({required this.objectives, required this.languageCode});

  final List<LocalizedText> objectives;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LearningColors>()!;
    return Card(
      color: colors.blueContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).objectivesTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.onBlueContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            for (final objective in objectives)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: colors.onBlueContainer)),
                    Expanded(
                      child: Text(
                        objective.forLanguage(languageCode),
                        style: TextStyle(color: colors.onBlueContainer),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LessonSectionCard extends StatelessWidget {
  const _LessonSectionCard({required this.section, required this.languageCode});

  final LessonSection section;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.title.forLanguage(languageCode),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(section.body.forLanguage(languageCode)),
            for (final example in section.examples) ...[
              const SizedBox(height: 20),
              _GrammarExampleCard(example: example, languageCode: languageCode),
            ],
          ],
        ),
      ),
    );
  }
}

class _GrammarExampleCard extends StatelessWidget {
  const _GrammarExampleCard({
    required this.example,
    required this.languageCode,
  });

  final GrammarExample example;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<LearningColors>()!;

    return Material(
      color: colors.sunshineContainer,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.vocalizedLabel),
            const SizedBox(height: 4),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                example.vocalized,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontFamily: 'AmiriQuran',
                  color: colors.onSunshineContainer,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.unvocalizedLabel),
            const SizedBox(height: 4),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                example.unvocalized,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: 'AmiriQuran',
                  color: colors.onSunshineContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.wordAnalysisTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.onSunshineContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            for (final token in example.tokens)
              _TokenAnalysisTile(token: token, languageCode: languageCode),
          ],
        ),
      ),
    );
  }
}

class _TokenAnalysisTile extends StatelessWidget {
  const _TokenAnalysisTile({required this.token, required this.languageCode});

  final GrammarToken token;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 12),
      title: Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          '${token.text}${token.ending}',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontFamily: 'AmiriQuran'),
        ),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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

class _ExerciseCard extends StatefulWidget {
  const _ExerciseCard({required this.exercise, required this.languageCode});

  final Exercise exercise;
  final String languageCode;

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  ExerciseOption? _selectedOption;

  @override
  Widget build(BuildContext context) {
    final selected = _selectedOption;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.exercise.prompt.forLanguage(widget.languageCode),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 14),
            for (final option in widget.exercise.options)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () => setState(() => _selectedOption = option),
                  style: OutlinedButton.styleFrom(
                    alignment: AlignmentDirectional.centerStart,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: Text(option.label.forLanguage(widget.languageCode)),
                ),
              ),
            if (selected != null)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: selected.isCorrect
                      ? Colors.green.withValues(alpha: 0.12)
                      : Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    selected.feedback.forLanguage(widget.languageCode),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
