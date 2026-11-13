import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/localization/number_format.dart';
import '../../l10n/app_localizations.dart';

class CourseCompletionCelebration extends StatefulWidget {
  const CourseCompletionCelebration({
    required this.lessonCount,
    required this.mastery,
    super.key,
  });

  final int lessonCount;
  final int mastery;

  @override
  State<CourseCompletionCelebration> createState() =>
      _CourseCompletionCelebrationState();
}

class _CourseCompletionCelebrationState
    extends State<CourseCompletionCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 1;
    } else if (_controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog.fullscreen(
      backgroundColor: const Color(0xFF080D20),
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF141A3D), Color(0xFF080D20)],
                ),
              ),
            ),
          ),
          if (!MediaQuery.disableAnimationsOf(context))
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, _) => CustomPaint(
                    key: const ValueKey('courseFireworks'),
                    painter: _FireworksPainter(progress: _controller.value),
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xE610162C),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: const Color(0x33FFFFFF)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.emoji_events_rounded,
                            size: 80,
                            color: Color(0xFFFFD584),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.courseCompleteTitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.courseCompleteBody,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: const Color(0xFFE0E5F5)),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            l10n.courseCompleteSummary(
                              localizedNumber(context, widget.lessonCount),
                              localizedPercent(context, widget.mastery),
                            ),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: const Color(0xFFFFD584)),
                          ),
                          const SizedBox(height: 28),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD584),
                              foregroundColor: const Color(0xFF10162C),
                            ),
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(l10n.courseReviewAction),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(l10n.close),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FireworksPainter extends CustomPainter {
  const _FireworksPainter({required this.progress});

  final double progress;
  static const _colors = [
    Color(0xFFFFD584),
    Color(0xFF96D9FF),
    Color(0xFFF8A8DB),
    Color(0xFFAEEDD3),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (var burst = 0; burst < 8; burst++) {
      final age = progress * 6 - burst * 0.48;
      if (age <= 0 || age >= 2.3) continue;
      final random = math.Random(71 + burst);
      final center = Offset(
        size.width * (0.12 + random.nextDouble() * 0.76),
        size.height * (0.08 + random.nextDouble() * 0.3),
      );
      final color = _colors[burst % _colors.length];
      if (age < 0.5) {
        final rise = age / 0.5;
        final head = Offset.lerp(
          Offset(center.dx, size.height),
          center,
          Curves.easeOut.transform(rise),
        )!;
        final tail = head + const Offset(0, 36);
        canvas.drawLine(
          tail,
          head,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [color.withValues(alpha: 0), color],
            ).createShader(Rect.fromPoints(head, tail))
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round,
        );
        continue;
      }
      final phase = (age - 0.5) / 1.8;
      final radius = math.min(size.width, size.height) * 0.28;
      final expansion = 1 - math.exp(-3 * phase);
      final opacity = math.pow(1 - phase, 1.5).toDouble() * 0.85;
      for (var spark = 0; spark < 64; spark++) {
        final angle = spark * math.pi * 2 / 64;
        final speed = 0.55 + random.nextDouble() * 0.45;
        final direction = Offset(math.cos(angle), math.sin(angle));
        final position =
            center +
            direction * radius * speed * expansion +
            Offset(0, phase * phase * 80);
        final paint = Paint()
          ..color = color.withValues(alpha: opacity)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          position - direction * (3 + (1 - phase) * 8),
          position,
          paint,
        );
        canvas.drawCircle(
          position,
          3,
          Paint()
            ..color = color.withValues(alpha: opacity * 0.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_FireworksPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
