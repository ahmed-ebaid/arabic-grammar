import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/arabic_diacritics.dart';
import '../../core/user/user_data_controller.dart';
import 'young_learner_mascot.dart';

class CorrectAnswerCelebration extends StatelessWidget {
  const CorrectAnswerCelebration({
    required this.title,
    required this.body,
    super.key,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isYoungLearner =
        context.watch<UserDataController?>()?.learnerProfile ==
        LearnerProfile.youngLearner;
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 420),
      curve: Curves.elasticOut,
      tween: Tween(begin: 0.72, end: 1),
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        alignment: AlignmentDirectional.centerStart,
        child: child,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isYoungLearner)
            const YoungLearnerMascot(
              kind: CartoonCharacterKind.boy,
              size: 46,
              celebrating: true,
            )
          else
            Icon(Icons.celebration, color: colors.primary, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ArabicDiacriticsText(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
