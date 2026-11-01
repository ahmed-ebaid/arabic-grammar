import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/localization/arabic_diacritics.dart';
import '../../core/theme/app_theme.dart';

enum CartoonCharacterKind { boy, girl, duo }

enum MascotMood { happy, cheering, thinking, encouraging }

/// Friendly interactive cartoon Muslim characters (Omar in kufi cap & Maryam in
/// hijab — عمر ومريم) designed to make Young Learner mode warm, playful, and
/// engaging.
class YoungLearnerMascot extends StatefulWidget {
  const YoungLearnerMascot({
    this.kind = CartoonCharacterKind.duo,
    this.size = 76,
    this.celebrating = false,
    this.mood,
    this.onTap,
    super.key,
  });

  final CartoonCharacterKind kind;
  final double size;
  final bool celebrating;
  final MascotMood? mood;
  final VoidCallback? onTap;

  @override
  State<YoungLearnerMascot> createState() => _YoungLearnerMascotState();
}

class _YoungLearnerMascotState extends State<YoungLearnerMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  );

  MascotMood get _effectiveMood =>
      widget.mood ??
      (widget.celebrating ? MascotMood.cheering : MascotMood.happy);

  @override
  void initState() {
    super.initState();
    if (_effectiveMood == MascotMood.cheering) {
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant YoungLearnerMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.celebrating != widget.celebrating ||
        oldWidget.mood != widget.mood) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.selectionClick();
    _controller.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.kind == CartoonCharacterKind.duo
        ? widget.size * 1.65
        : widget.size;
    final painted = AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final jump = math.sin(t * math.pi) * -6.0;
        final scale = 1.0 + math.sin(t * math.pi) * 0.08;
        return Transform.translate(
          offset: Offset(0, jump),
          child: Transform.scale(
            scale: scale,
            child: SizedBox(
              width: width,
              height: widget.size,
              child: CustomPaint(
                painter: _YoungLearnerMascotPainter(
                  kind: widget.kind,
                  mood: _effectiveMood,
                  waveProgress: t,
                ),
              ),
            ),
          ),
        );
      },
    );

    if (widget.onTap == null) {
      return ExcludeSemantics(child: painted);
    }
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: ExcludeSemantics(child: painted),
    );
  }
}

class _YoungLearnerMascotPainter extends CustomPainter {
  const _YoungLearnerMascotPainter({
    required this.kind,
    required this.mood,
    required this.waveProgress,
  });

  final CartoonCharacterKind kind;
  final MascotMood mood;
  final double waveProgress;

  bool get celebrating => mood == MascotMood.cheering || waveProgress > 0.1;

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case CartoonCharacterKind.boy:
        _drawSparkles(canvas, size);
        _drawBoy(
          canvas,
          center: Offset(size.width * 0.5, size.height * 0.56),
          radius: size.height * 0.34,
        );
      case CartoonCharacterKind.girl:
        _drawSparkles(canvas, size);
        _drawGirl(
          canvas,
          center: Offset(size.width * 0.5, size.height * 0.56),
          radius: size.height * 0.34,
        );
      case CartoonCharacterKind.duo:
        _drawSparkles(canvas, size);
        final r = size.height * 0.31;
        _drawGirl(
          canvas,
          center: Offset(size.width * 0.33, size.height * 0.57),
          radius: r,
        );
        _drawBoy(
          canvas,
          center: Offset(size.width * 0.69, size.height * 0.57),
          radius: r,
        );
    }
  }

  void _drawSparkles(Canvas canvas, Size size) {
    final starPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.fill;
    _drawStar(
      canvas,
      Offset(size.width * 0.14, size.height * 0.18),
      size.height * (celebrating ? 0.095 : 0.07),
      starPaint,
    );
    _drawStar(
      canvas,
      Offset(size.width * 0.88, size.height * 0.16),
      size.height * (celebrating ? 0.085 : 0.06),
      starPaint,
    );
    if (celebrating) {
      _drawStar(
        canvas,
        Offset(size.width * 0.22, size.height * 0.84),
        size.height * 0.06,
        Paint()..color = const Color(0xFF38BDF8),
      );
      _drawStar(
        canvas,
        Offset(size.width * 0.82, size.height * 0.82),
        size.height * 0.06,
        Paint()..color = const Color(0xFFF43F5E),
      );
    }
    if (kind == CartoonCharacterKind.duo) {
      _drawCrescent(
        canvas,
        Offset(size.width * 0.51, size.height * 0.14),
        size.height * 0.075,
      );
    }
  }

  void _drawCrescent(Canvas canvas, Offset center, double radius) {
    final gold = Paint()..color = const Color(0xFFF59E0B);
    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    final cut = Path()
      ..addOval(
        Rect.fromCircle(
          center: center.translate(radius * 0.38, -radius * 0.15),
          radius: radius * 0.82,
        ),
      );
    final crescent = Path.combine(PathOperation.difference, path, cut);
    canvas.drawPath(crescent, gold);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const points = 4;
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : radius * 0.38;
      final angle = (i * math.pi / points) - math.pi / 2;
      final pt = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawBoy(
    Canvas canvas, {
    required Offset center,
    required double radius,
  }) {
    // Soft circular backdrop
    canvas.drawCircle(
      center,
      radius * 1.18,
      Paint()..color = const Color(0xFFE0F2FE),
    );

    // Shoulders / thobe collar
    final robeRect = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: center.translate(0, radius * 0.95),
        width: radius * 1.5,
        height: radius * 0.85,
      ),
      topLeft: Radius.circular(radius * 0.65),
      topRight: Radius.circular(radius * 0.65),
      bottomLeft: Radius.circular(radius * 0.25),
      bottomRight: Radius.circular(radius * 0.25),
    );
    canvas.drawRRect(robeRect, Paint()..color = const Color(0xFF0E7490));
    // White collar V
    final collar = Path()
      ..moveTo(center.dx - radius * 0.26, center.dy + radius * 0.55)
      ..lineTo(center.dx, center.dy + radius * 0.92)
      ..lineTo(center.dx + radius * 0.26, center.dy + radius * 0.55)
      ..close();
    canvas.drawPath(collar, Paint()..color = const Color(0xFFF8FAFC));

    // Ears
    final skinPaint = Paint()..color = const Color(0xFFF6C391);
    canvas.drawCircle(
      center.translate(-radius * 0.72, radius * 0.04),
      radius * 0.16,
      skinPaint,
    );
    canvas.drawCircle(
      center.translate(radius * 0.72, radius * 0.04),
      radius * 0.16,
      skinPaint,
    );

    // Face
    canvas.drawCircle(center, radius * 0.72, skinPaint);

    // Dark hair fringe peeking under kufi
    final hairPath = Path()
      ..moveTo(center.dx - radius * 0.70, center.dy - radius * 0.15)
      ..quadraticBezierTo(
        center.dx,
        center.dy - radius * 0.45,
        center.dx + radius * 0.70,
        center.dy - radius * 0.15,
      )
      ..lineTo(center.dx + radius * 0.68, center.dy - radius * 0.34)
      ..lineTo(center.dx - radius * 0.68, center.dy - radius * 0.34)
      ..close();
    canvas.drawPath(hairPath, Paint()..color = const Color(0xFF292524));

    // Kufi / Taqiyah cap (white dome with teal & gold band)
    final kufiPath = Path()
      ..moveTo(center.dx - radius * 0.72, center.dy - radius * 0.22)
      ..quadraticBezierTo(
        center.dx - radius * 0.68,
        center.dy - radius * 1.02,
        center.dx,
        center.dy - radius * 1.02,
      )
      ..quadraticBezierTo(
        center.dx + radius * 0.68,
        center.dy - radius * 1.02,
        center.dx + radius * 0.72,
        center.dy - radius * 0.22,
      )
      ..close();
    canvas.drawPath(kufiPath, Paint()..color = const Color(0xFFFFFFFF));
    canvas.drawPath(
      kufiPath,
      Paint()
        ..color = const Color(0xFF0E7490)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.07,
    );

    // Kufi decorative band
    final bandRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center.translate(0, -radius * 0.27),
        width: radius * 1.44,
        height: radius * 0.18,
      ),
      Radius.circular(radius * 0.08),
    );
    canvas.drawRRect(bandRect, Paint()..color = const Color(0xFFF59E0B));

    _drawFaceFeatures(canvas, center: center, radius: radius);
  }

  void _drawGirl(
    Canvas canvas, {
    required Offset center,
    required double radius,
  }) {
    // Soft circular backdrop
    canvas.drawCircle(
      center,
      radius * 1.18,
      Paint()..color = const Color(0xFFFEF3C7),
    );

    // Outer Hijab drape (warm coral-rose)
    final hijabColor = const Color(0xFFE05A47);
    final hijabShadow = const Color(0xFFC24130);
    final drapePath = Path()
      ..moveTo(center.dx - radius * 0.90, center.dy + radius * 0.95)
      ..quadraticBezierTo(
        center.dx - radius * 0.96,
        center.dy - radius * 0.88,
        center.dx,
        center.dy - radius * 0.96,
      )
      ..quadraticBezierTo(
        center.dx + radius * 0.96,
        center.dy - radius * 0.88,
        center.dx + radius * 0.90,
        center.dy + radius * 0.95,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy + radius * 1.18,
        center.dx - radius * 0.90,
        center.dy + radius * 0.95,
      )
      ..close();
    canvas.drawPath(drapePath, Paint()..color = hijabColor);

    // Inner Hijab underscarf band (soft gold)
    canvas.drawCircle(
      center.translate(0, -radius * 0.06),
      radius * 0.68,
      Paint()..color = const Color(0xFFFDE68A),
    );

    // Face oval
    final skinPaint = Paint()..color = const Color(0xFFF6C391);
    canvas.drawCircle(
      center.translate(0, radius * 0.02),
      radius * 0.63,
      skinPaint,
    );

    // Hijab chin wrap fold line
    final foldPaint = Paint()
      ..color = hijabShadow
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.06
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(
        center: center.translate(0, radius * 0.05),
        radius: radius * 0.66,
      ),
      0.35,
      math.pi - 0.7,
      false,
      foldPaint,
    );

    // Cute star pin on side of hijab
    _drawStar(
      canvas,
      center.translate(radius * 0.58, -radius * 0.34),
      radius * 0.16,
      Paint()..color = const Color(0xFFFBBF24),
    );

    _drawFaceFeatures(
      canvas,
      center: center.translate(0, radius * 0.03),
      radius: radius * 0.92,
    );
  }

  void _drawFaceFeatures(
    Canvas canvas, {
    required Offset center,
    required double radius,
  }) {
    // Rosy cheeks
    final cheekPaint = Paint()
      ..color = const Color(0xFFFCA5A5).withValues(alpha: 0.65);
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(-radius * 0.38, radius * 0.15),
        width: radius * 0.24,
        height: radius * 0.14,
      ),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(radius * 0.38, radius * 0.15),
        width: radius * 0.24,
        height: radius * 0.14,
      ),
      cheekPaint,
    );

    // Waving hand when cheering or tapped
    if (celebrating) {
      final waveAngle = math.sin(waveProgress * math.pi * 2) * 0.18;
      final handCenter = center.translate(
        radius * (0.86 + waveAngle * 0.3),
        radius * (0.34 - waveProgress * 0.15),
      );
      canvas.drawCircle(
        handCenter,
        radius * 0.19,
        Paint()..color = const Color(0xFFF6C391),
      );
      canvas.drawCircle(
        handCenter,
        radius * 0.19,
        Paint()
          ..color = const Color(0xFFD97706).withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.04,
      );
    }

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF1E293B);
    final leftEye = center.translate(-radius * 0.25, -radius * 0.02);
    final rightEye = center.translate(radius * 0.25, -radius * 0.02);
    if (mood == MascotMood.cheering) {
      // Happy curved cheering eyes (^ ^)
      final cheerEyePaint = Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.075
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCenter(
          center: leftEye.translate(0, radius * 0.03),
          width: radius * 0.22,
          height: radius * 0.16,
        ),
        math.pi + 0.25,
        math.pi - 0.5,
        false,
        cheerEyePaint,
      );
      canvas.drawArc(
        Rect.fromCenter(
          center: rightEye.translate(0, radius * 0.03),
          width: radius * 0.22,
          height: radius * 0.16,
        ),
        math.pi + 0.25,
        math.pi - 0.5,
        false,
        cheerEyePaint,
      );
    } else {
      canvas.drawCircle(leftEye, radius * 0.095, eyePaint);
      canvas.drawCircle(rightEye, radius * 0.095, eyePaint);

      // Eye catchlights
      final shinePaint = Paint()..color = Colors.white;
      canvas.drawCircle(
        leftEye.translate(-radius * 0.028, -radius * 0.03),
        radius * 0.034,
        shinePaint,
      );
      canvas.drawCircle(
        rightEye.translate(-radius * 0.028, -radius * 0.03),
        radius * 0.034,
        shinePaint,
      );
    }

    // Friendly eyebrows
    final browPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.055
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: leftEye.translate(0, -radius * 0.11),
        width: radius * 0.22,
        height: radius * 0.10,
      ),
      math.pi + 0.3,
      math.pi - 0.6,
      false,
      browPaint,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: rightEye.translate(0, -radius * 0.11),
        width: radius * 0.22,
        height: radius * 0.10,
      ),
      math.pi + 0.3,
      math.pi - 0.6,
      false,
      browPaint,
    );

    // Warm smile (or open cheering grin)
    if (celebrating) {
      final mouthRect = Rect.fromCenter(
        center: center.translate(0, radius * 0.16),
        width: radius * 0.44,
        height: radius * 0.28,
      );
      canvas.drawArc(
        mouthRect,
        0,
        math.pi,
        true,
        Paint()..color = const Color(0xFF7C2D12),
      );
    } else {
      final smilePaint = Paint()
        ..color = const Color(0xFF7C2D12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.065
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCenter(
          center: center.translate(0, radius * 0.12),
          width: radius * 0.42,
          height: radius * 0.28,
        ),
        0.2,
        math.pi - 0.4,
        false,
        smilePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _YoungLearnerMascotPainter oldDelegate) {
    return oldDelegate.kind != kind ||
        oldDelegate.mood != mood ||
        oldDelegate.waveProgress != waveProgress;
  }
}

class _HarakaOption {
  const _HarakaOption({
    required this.name,
    required this.mark,
    required this.wordWithMark,
    required this.sentence,
    required this.story,
    required this.badgeColor,
  });

  final String name;
  final String mark;
  final String wordWithMark;
  final String sentence;
  final String story;
  final Color badgeColor;
}

/// An interactive mini-game card for Young Learners on the Home screen where
/// kids can tap the 3 harakat (الضمة / الفتحة / الكسرة) to transform a word's
/// ending live in a sentence and see Omar & Salma react!
class InteractiveHarakaPlayground extends StatefulWidget {
  const InteractiveHarakaPlayground({super.key});

  @override
  State<InteractiveHarakaPlayground> createState() =>
      _InteractiveHarakaPlaygroundState();
}

class _InteractiveHarakaPlaygroundState
    extends State<InteractiveHarakaPlayground> {
  static const List<_HarakaOption> _harakat = [
    _HarakaOption(
      name: 'الضَّمَّة',
      mark: 'ـُ',
      wordWithMark: 'البَيْتُ',
      sentence: 'البَيْتُ جَمِيلٌ',
      story:
          'الضَّمَّةُ فَوْقَ الحَرْفِ الأَخِيرِ لأَنَّ الكَلِمَةَ فِي البِدَايَةِ!',
      badgeColor: Color(0xFF0E7490),
    ),
    _HarakaOption(
      name: 'الفَتْحَة',
      mark: 'ـَ',
      wordWithMark: 'البَيْتَ',
      sentence: 'زُرْتُ البَيْتَ',
      story:
          'الفَتْحَةُ فَوْقَ الحَرْفِ الأَخِيرِ لأَنَّ الفِعْلَ وَقَعَ عَلَيْهَا!',
      badgeColor: Color(0xFFD97706),
    ),
    _HarakaOption(
      name: 'الكَسْرَة',
      mark: 'ـِ',
      wordWithMark: 'البَيْتِ',
      sentence: 'فِي البَيْتِ نُورٌ',
      story: 'الكَسْرَةُ تَحْتَ الحَرْفِ الأَخِيرِ لأَنَّ قَبْلَهَا «فِي»!',
      badgeColor: Color(0xFF059669),
    ),
  ];

  static const List<String> _mascotCheers = [
    'مَرْحَبًا! أَنَا عُمَر وَهَذِهِ مَرْيَم — اضْغَطْ عَلَى الحَرَكَاتِ لِتَرَى كَيْفَ تَتَغَيَّرُ الكَلِمَةُ!',
    'يَقُولُ عُمَر: آخِرُ الكَلِمَةِ يَتَغَيَّرُ حَسَبَ مَكَانِهَا فِي الجُمْلَةِ!',
    'تَقُولُ مَرْيَم: أَنْتَ نَجْمُ الإِعْرَابِ الصَّغِير! جَرِّبْ حَرَكَةً أُخْرَى!',
  ];

  int _selectedHarakaIndex = 0;
  int _cheerIndex = 0;
  bool _hasInteracted = false;

  void _selectHaraka(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedHarakaIndex = index;
      _hasInteracted = true;
    });
  }

  void _cycleCheer() {
    setState(() {
      _cheerIndex = (_cheerIndex + 1) % _mascotCheers.length;
      _hasInteracted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final learningColors = Theme.of(context).extension<LearningColors>()!;
    final active = _harakat[_selectedHarakaIndex];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: learningColors.sunshineContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: scheme.tertiary.withValues(alpha: 0.42),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              YoungLearnerMascot(
                kind: CartoonCharacterKind.duo,
                size: 56,
                mood: _hasInteracted ? MascotMood.cheering : MascotMood.happy,
                onTap: _cycleCheer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 18,
                          color: learningColors.onSunshineContainer,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'مَلْعَبُ الحَرَكَاتِ مَعَ عُمَر وَمَرْيَم',
                            style: textTheme.titleSmall?.copyWith(
                              color: learningColors.onSunshineContainer,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    ArabicDiacriticsText(
                      _hasInteracted
                          ? active.story
                          : _mascotCheers[_cheerIndex],
                      style: textTheme.bodySmall?.copyWith(
                        color: learningColors.onSunshineContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: active.badgeColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ArabicDiacriticsText(
                    active.wordWithMark,
                    style: textTheme.titleLarge?.copyWith(
                      color: active.badgeColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ArabicDiacriticsText(
                    active.sentence,
                    textAlign: TextAlign.end,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final entry in _harakat.indexed) ...[
                if (entry.$1 > 0) const SizedBox(width: 8),
                Expanded(
                  child: _HarakaPlaygroundButton(
                    option: entry.$2,
                    selected: _selectedHarakaIndex == entry.$1,
                    onTap: () => _selectHaraka(entry.$1),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _HarakaPlaygroundButton extends StatelessWidget {
  const _HarakaPlaygroundButton({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _HarakaOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? option.badgeColor : scheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? option.badgeColor
                  : option.badgeColor.withValues(alpha: 0.4),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ArabicDiacriticsText(
                option.mark,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : option.badgeColor,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  option.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Interactive companion header shown on questions in Young Learner mode.
/// Kids can tap Salma & Omar to reveal/cycle a friendly grammar clue, and the
/// mascot reacts with cheering or encouragement when an answer is checked.
class InteractiveQuestionCompanion extends StatefulWidget {
  const InteractiveQuestionCompanion({
    required this.hint,
    required this.answerChecked,
    required this.isCorrect,
    super.key,
  });

  final String hint;
  final bool answerChecked;
  final bool isCorrect;

  @override
  State<InteractiveQuestionCompanion> createState() =>
      _InteractiveQuestionCompanionState();
}

class _InteractiveQuestionCompanionState
    extends State<InteractiveQuestionCompanion> {
  bool _showTipBubble = false;

  MascotMood get _mood {
    if (!widget.answerChecked) {
      return _showTipBubble ? MascotMood.cheering : MascotMood.happy;
    }
    return widget.isCorrect ? MascotMood.cheering : MascotMood.encouraging;
  }

  String get _bubbleText {
    if (widget.answerChecked) {
      return widget.isCorrect
          ? 'عُمَر وَمَرْيَم: يا لَلرَّوْعَةِ! إِجَابَةٌ ذَكِيَّةٌ يا بَطَلَ الإِعْرَابِ! 🌟'
          : 'مَرْيَم وَعُمَر: لا بَأْسَ يا صَدِيقِي! انْظُرْ إِلَى آخِرِ الكَلِمَةِ وَجَرِّبْ مَرَّةً أُخْرَى 💪';
    }
    if (_showTipBubble) {
      return 'تَلْمِيحُ عُمَر وَمَرْيَم: ${widget.hint}';
    }
    return 'اضْغَطْ عَلَى عُمَر وَمَرْيَم لِتَحْصُلَ عَلَى تَلْمِيحِ البَطَلِ! 💡';
  }

  @override
  Widget build(BuildContext context) {
    final learningColors = Theme.of(context).extension<LearningColors>()!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _showTipBubble = !_showTipBubble);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: learningColors.sunshineContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: scheme.tertiary.withValues(alpha: 0.38),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            YoungLearnerMascot(
              kind: CartoonCharacterKind.duo,
              size: 56,
              mood: _mood,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ArabicDiacriticsText(
                _bubbleText,
                style: textTheme.bodyMedium?.copyWith(
                  color: learningColors.onSunshineContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              _showTipBubble
                  ? Icons.lightbulb_rounded
                  : Icons.lightbulb_outline_rounded,
              color: learningColors.onSunshineContainer,
            ),
          ],
        ),
      ),
    );
  }
}
