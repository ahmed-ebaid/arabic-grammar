import 'package:arabic_grammar/core/services/review_prompt_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'requests review after three distinct learning days and cools down',
    () async {
      var now = DateTime(2026, 4, 1, 10);
      final service = ReviewPromptService();

      await service.recordMeaningfulLearningDay(date: now);
      await service.recordMeaningfulLearningDay(date: now); // Same day, ignored
      expect(service.learningDays.length, 1);
      expect(service.shouldRequestAtLaunch(now: now), isFalse);

      now = DateTime(2026, 4, 2, 10);
      await service.recordMeaningfulLearningDay(date: now);
      expect(service.learningDays.length, 2);
      expect(service.shouldRequestAtLaunch(now: now), isFalse);

      now = DateTime(2026, 4, 3, 10);
      await service.recordMeaningfulLearningDay(date: now);
      expect(service.learningDays.length, 3);
      expect(service.shouldRequestAtLaunch(now: now), isTrue);

      var requested = false;
      final prompted = await service.requestAtLaunch(
        now: now,
        isAvailable: () async => true,
        requestReview: () async {
          requested = true;
        },
      );
      expect(prompted, isTrue);
      expect(requested, isTrue);
      expect(service.shouldRequestAtLaunch(now: now), isFalse);

      now = now.add(const Duration(days: 121));
      expect(service.shouldRequestAtLaunch(now: now), isTrue);
    },
  );
}
