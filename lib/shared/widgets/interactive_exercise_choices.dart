import 'package:flutter/material.dart';

import '../../core/localization/arabic_diacritics.dart';
import '../../core/models/content_models.dart';

class InteractiveExerciseChoices extends StatelessWidget {
  const InteractiveExerciseChoices({
    required this.exercise,
    required this.options,
    required this.languageCode,
    required this.selectedOptionId,
    required this.disabled,
    required this.onSelect,
    super.key,
  });

  final Exercise exercise;
  final List<ExerciseOption> options;
  final String languageCode;
  final String? selectedOptionId;
  final bool disabled;
  final ValueChanged<String> onSelect;

  static const _marks = {
    'damma': '\u064f',
    'fatha': '\u064e',
    'kasra': '\u0650',
    'sukun': '\u0652',
  };

  @override
  Widget build(BuildContext context) {
    final isVowel = exercise.type == ExerciseType.placeVowel;
    final mark = _marks[selectedOptionId] ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isVowel) ...[
          Center(
            child: Text(
              '${exercise.targetWord!}$mark',
              key: const ValueKey('vowelTarget'),
              textDirection: TextDirection.rtl,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Directionality(
          textDirection: isVowel
              ? Directionality.of(context)
              : TextDirection.rtl,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in options)
                ChoiceChip(
                  key: ValueKey('interactiveChoice-${option.id}'),
                  label: ArabicDiacriticsText(
                    isVowel
                        ? '◌${_marks[option.id]} ${option.label.forLanguage(languageCode)}'
                        : option.label.forLanguage(languageCode),
                    style: const TextStyle(fontSize: 20),
                  ),
                  selected: selectedOptionId == option.id,
                  onSelected: disabled ? null : (_) => onSelect(option.id),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
