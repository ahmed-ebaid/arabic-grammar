import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../core/localization/arabic_diacritics.dart';
import '../../core/theme/app_theme.dart';

enum CartoonCharacterKind { boy, girl, duo }

enum MascotMood { happy, cheering, thinking, encouraging }

bool get _isFlutterTestEnvironment {
  try {
    return Platform.environment.containsKey('FLUTTER_TEST');
  } catch (_) {
    return true;
  }
}

/// Shared lightweight Arabic TTS helper so tapping speaker buttons or words
/// speaks Arabic aloud on iOS/Android while safely no-opping in widget tests.
class ArabicSpeechHelper {
  ArabicSpeechHelper._();
  static final ArabicSpeechHelper instance = ArabicSpeechHelper._();

  FlutterTts? _tts;
  bool _configured = false;

  static final RegExp _emojiPattern = RegExp(
    r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE00}-\u{FE0F}]',
    unicode: true,
  );

  static String _sanitizeForSpeech(String raw) {
    var cleaned = raw.replaceAll('ـُ', ' ضَمَّة ');
    cleaned = cleaned.replaceAll('ـَ', ' فَتْحَة ');
    cleaned = cleaned.replaceAll('ـِ', ' كَسْرَة ');
    cleaned = cleaned.replaceAll('ـْ', ' سُكُون ');
    cleaned = cleaned.replaceAll(RegExp(r'_+'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'[«»"“”()]'), ' ');
    cleaned = cleaned.replaceAll(_emojiPattern, ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    return cleaned.trim();
  }

  static String? _pickArabicLocale(List<dynamic> rawLanguages) {
    final arabicLocales = <String>[];
    for (final item in rawLanguages) {
      final tag = item.toString();
      if (tag.toLowerCase().startsWith('ar')) {
        arabicLocales.add(tag);
      }
    }
    const preferredOrder = ['ar-001', 'ar-sa', 'ar-eg', 'ar'];
    for (final preferred in preferredOrder) {
      for (final candidate in arabicLocales) {
        if (candidate.toLowerCase() == preferred) {
          return candidate;
        }
      }
    }
    return arabicLocales.firstOrNull;
  }

  Future<void> _configureIfNeeded(FlutterTts tts) async {
    if (_configured) return;
    _configured = true;
    try {
      if (Platform.isIOS) {
        await tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          const [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
          IosTextToSpeechAudioMode.defaultMode,
        );
        await tts.setSharedInstance(true);
      }
    } catch (_) {
      // Ignore audio category errors on unsupported platforms.
    }

    try {
      String? selectedLocale;
      final Object? rawLanguages = await tts.getLanguages;
      if (rawLanguages is List<dynamic>) {
        selectedLocale = _pickArabicLocale(rawLanguages);
      }
      if (selectedLocale != null) {
        await tts.setLanguage(selectedLocale);
      } else {
        for (final fallback in const ['ar-001', 'ar-SA', 'ar-EG', 'ar']) {
          final Object? res = await tts.setLanguage(fallback);
          if (res == 1 || res == true) {
            break;
          }
        }
      }
    } catch (_) {
      // Ignore language selection errors.
    }

    try {
      await tts.setVolume(1.0);
      await tts.setSpeechRate(0.45);
      await tts.setPitch(1.03);
    } catch (_) {
      // Ignore speech rate configuration errors.
    }
  }

  Future<void> speak(String text) async {
    if (_isFlutterTestEnvironment) {
      return;
    }
    final cleaned = _sanitizeForSpeech(text);
    if (cleaned.isEmpty) {
      return;
    }
    try {
      final tts = _tts ??= FlutterTts();
      await _configureIfNeeded(tts);
      await tts.speak(cleaned);
    } catch (_) {
      // Ignore TTS errors on unsupported devices/simulators.
    }
  }
}

/// Duolingo-style animated Muslim characters: Omar (عُمَر in kufi & teal vest)
/// and Maryam (مَرْيَم in coral-rose hijab with star pin).
///
/// On real devices, runs a continuous 60fps idle animation (breathing, natural
/// eye blinking, gentle hand waving, and mouth movement when speaking/tapped).
/// In `flutter test`, runs a finite 480ms bounce so `pumpAndSettle` never
/// hangs.
class YoungLearnerMascot extends StatefulWidget {
  const YoungLearnerMascot({
    this.kind = CartoonCharacterKind.duo,
    this.size = 92,
    this.celebrating = false,
    this.speaking = false,
    this.mood,
    this.onTap,
    super.key,
  });

  final CartoonCharacterKind kind;
  final double size;
  final bool celebrating;
  final bool speaking;
  final MascotMood? mood;
  final VoidCallback? onTap;

  @override
  State<YoungLearnerMascot> createState() => _YoungLearnerMascotState();
}

class _YoungLearnerMascotState extends State<YoungLearnerMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _isFlutterTestEnvironment ? 480 : 3200),
  );

  MascotMood get _effectiveMood =>
      widget.mood ??
      (widget.celebrating ? MascotMood.cheering : MascotMood.happy);

  @override
  void initState() {
    super.initState();
    if (_isFlutterTestEnvironment) {
      if (_effectiveMood == MascotMood.cheering || widget.speaking) {
        _controller.forward(from: 0);
      }
    } else {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant YoungLearnerMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isFlutterTestEnvironment) {
      if (oldWidget.celebrating != widget.celebrating ||
          oldWidget.mood != widget.mood ||
          oldWidget.speaking != widget.speaking) {
        _controller.forward(from: 0);
      }
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.selectionClick();
    if (_isFlutterTestEnvironment) {
      _controller.forward(from: 0);
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.kind == CartoonCharacterKind.duo
        ? widget.size * 1.55
        : widget.size * 0.96;
    final painted = AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final isCheering = _effectiveMood == MascotMood.cheering;
        final bob = _isFlutterTestEnvironment
            ? math.sin(t * math.pi) * (isCheering ? -6.0 : -2.5)
            : math.sin(t * math.pi * 2) * (isCheering ? -5.0 : -2.2);
        return Transform.translate(
          offset: Offset(0, bob),
          child: SizedBox(
            width: width,
            height: widget.size,
            child: CustomPaint(
              painter: _YoungLearnerMascotPainter(
                kind: widget.kind,
                mood: _effectiveMood,
                phase: t,
                speaking: widget.speaking,
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
    required this.phase,
    required this.speaking,
  });

  final CartoonCharacterKind kind;
  final MascotMood mood;
  final double phase;
  final bool speaking;

  bool get celebrating => mood == MascotMood.cheering;

  // Natural eye blink around phase 0.72..0.78 in continuous mode.
  double get _blinkAmount {
    if (_isFlutterTestEnvironment) return 0.0;
    const center = 0.75;
    const halfWidth = 0.035;
    final dist = (phase - center).abs();
    if (dist >= halfWidth) return 0.0;
    return 1.0 - (dist / halfWidth);
  }

  double get _waveAngle => math.sin(phase * math.pi * 2) * 0.22;

  double get _mouthOpen {
    if (celebrating) return 0.85;
    if (speaking) {
      return 0.35 + 0.55 * (0.5 + 0.5 * math.sin(phase * math.pi * 8));
    }
    return 0.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case CartoonCharacterKind.boy:
        _drawSparkles(canvas, size);
        _drawOmar(
          canvas,
          center: Offset(size.width * 0.50, size.height * 0.54),
          scale: size.height * 0.40,
        );
      case CartoonCharacterKind.girl:
        _drawSparkles(canvas, size);
        _drawMaryam(
          canvas,
          center: Offset(size.width * 0.50, size.height * 0.54),
          scale: size.height * 0.40,
        );
      case CartoonCharacterKind.duo:
        _drawSparkles(canvas, size);
        final s = size.height * 0.36;
        _drawMaryam(
          canvas,
          center: Offset(size.width * 0.31, size.height * 0.56),
          scale: s,
        );
        _drawOmar(
          canvas,
          center: Offset(size.width * 0.70, size.height * 0.56),
          scale: s,
        );
    }
  }

  void _drawSparkles(Canvas canvas, Size size) {
    final goldPaint = Paint()..color = const Color(0xFFFFB703);
    final coralPaint = Paint()..color = const Color(0xFFFB7185);
    final skyPaint = Paint()..color = const Color(0xFF38BDF8);

    _drawFourPointStar(
      canvas,
      Offset(size.width * 0.11, size.height * 0.16),
      size.height * (celebrating ? 0.095 : 0.068),
      goldPaint,
    );
    _drawFourPointStar(
      canvas,
      Offset(size.width * 0.90, size.height * 0.15),
      size.height * (celebrating ? 0.088 : 0.062),
      goldPaint,
    );
    if (celebrating) {
      _drawFourPointStar(
        canvas,
        Offset(size.width * 0.18, size.height * 0.82),
        size.height * 0.058,
        skyPaint,
      );
      _drawFourPointStar(
        canvas,
        Offset(size.width * 0.85, size.height * 0.80),
        size.height * 0.058,
        coralPaint,
      );
    }
  }

  void _drawFourPointStar(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    final path = Path();
    const points = 4;
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : radius * 0.36;
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

  /// Draws Omar (عُمَر) in Duolingo flat-vector character style:
  /// rounded squircle head, curly dark hair tuft at temples, crisp white kufi
  /// with geometric gold-and-teal trim, teal vest over white shirt collar,
  /// and waving hand.
  void _drawOmar(
    Canvas canvas, {
    required Offset center,
    required double scale,
  }) {
    const skin = Color(0xFFF7C59F);
    const skinShadow = Color(0xFFE2A57B);
    const hair = Color(0xFF2B1E1A);
    const teal = Color(0xFF0D9488);
    const gold = Color(0xFFFFB703);

    // Soft glowing circular badge behind Omar
    canvas.drawCircle(
      center.translate(0, -scale * 0.04),
      scale * 1.12,
      Paint()..color = const Color(0xFFE0F2FE),
    );
    canvas.drawCircle(
      center.translate(0, -scale * 0.04),
      scale * 1.12,
      Paint()
        ..color = const Color(0xFF7DD3FC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = scale * 0.05,
    );

    // Torso / Teal Vest
    final torsoRect = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: center.translate(0, scale * 0.86),
        width: scale * 1.42,
        height: scale * 0.78,
      ),
      topLeft: Radius.circular(scale * 0.56),
      topRight: Radius.circular(scale * 0.56),
      bottomLeft: Radius.circular(scale * 0.30),
      bottomRight: Radius.circular(scale * 0.30),
    );
    canvas.drawRRect(torsoRect, Paint()..color = teal);

    // White shirt V-neck & collar flaps
    final shirtPath = Path()
      ..moveTo(center.dx - scale * 0.30, center.dy + scale * 0.46)
      ..lineTo(center.dx, center.dy + scale * 0.90)
      ..lineTo(center.dx + scale * 0.30, center.dy + scale * 0.46)
      ..close();
    canvas.drawPath(shirtPath, Paint()..color = const Color(0xFFF8FAFC));

    // Neck with soft shadow
    final neckRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center.translate(0, scale * 0.46),
        width: scale * 0.38,
        height: scale * 0.32,
      ),
      Radius.circular(scale * 0.14),
    );
    canvas.drawRRect(neckRect, Paint()..color = skinShadow);

    // Rounded ears with inner ear detail
    final leftEar = center.translate(-scale * 0.72, scale * 0.02);
    final rightEar = center.translate(scale * 0.72, scale * 0.02);
    canvas.drawCircle(leftEar, scale * 0.17, Paint()..color = skin);
    canvas.drawCircle(rightEar, scale * 0.17, Paint()..color = skin);
    canvas.drawCircle(leftEar, scale * 0.09, Paint()..color = skinShadow);
    canvas.drawCircle(rightEar, scale * 0.09, Paint()..color = skinShadow);

    // Duolingo-style squircle head
    final headRect = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: center.translate(0, -scale * 0.02),
        width: scale * 1.38,
        height: scale * 1.24,
      ),
      topLeft: Radius.circular(scale * 0.62),
      topRight: Radius.circular(scale * 0.62),
      bottomLeft: Radius.circular(scale * 0.54),
      bottomRight: Radius.circular(scale * 0.54),
    );
    canvas.drawRRect(headRect, Paint()..color = skin);

    // Curly hair puffs at temples peeking under the kufi
    for (final offset in [
      const Offset(-0.62, -0.22),
      const Offset(0.62, -0.22),
      const Offset(-0.48, -0.34),
      const Offset(0.48, -0.34),
    ]) {
      canvas.drawCircle(
        center.translate(scale * offset.dx, scale * offset.dy),
        scale * 0.16,
        Paint()..color = hair,
      );
    }

    // Crisp White Kufi / Taqiyah Cap (clipped so embroidery band fits cleanly)
    final kufiRect = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: center.translate(0, -scale * 0.54),
        width: scale * 1.32,
        height: scale * 0.64,
      ),
      topLeft: Radius.circular(scale * 0.64),
      topRight: Radius.circular(scale * 0.64),
      bottomLeft: Radius.circular(scale * 0.10),
      bottomRight: Radius.circular(scale * 0.10),
    );
    canvas.drawRRect(kufiRect, Paint()..color = const Color(0xFFFDFEFE));
    canvas.save();
    canvas.clipRRect(kufiRect);
    // Soft top shading on Kufi
    canvas.drawCircle(
      center.translate(-scale * 0.25, -scale * 0.68),
      scale * 0.45,
      Paint()..color = Colors.white,
    );
    // Embroidered Kufi Band (Gold with Teal geometric diamonds)
    final bandRect = Rect.fromCenter(
      center: center.translate(0, -scale * 0.30),
      width: scale * 1.40,
      height: scale * 0.18,
    );
    canvas.drawRect(bandRect, Paint()..color = gold);
    for (final dx in [-0.44, -0.22, 0.0, 0.22, 0.44]) {
      canvas.drawCircle(
        center.translate(scale * dx, -scale * 0.30),
        scale * 0.042,
        Paint()..color = teal,
      );
    }
    canvas.restore();
    // Subtle clean outline on Kufi
    canvas.drawRRect(
      kufiRect,
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = scale * 0.035,
    );

    _drawDuolingoFace(
      canvas,
      center: center.translate(0, scale * 0.04),
      scale: scale,
    );

    // Connected waving arm + hand from right shoulder
    final waveLift =
        (celebrating ? -scale * 0.16 : 0.0) +
        math.sin(phase * math.pi * 2) * scale * 0.07;
    final shoulder = center.translate(scale * 0.56, scale * 0.64);
    final handCenter = center.translate(
      scale * (0.88 + _waveAngle * 0.28),
      scale * 0.26 + waveLift,
    );
    final armPath = Path()
      ..moveTo(shoulder.dx, shoulder.dy)
      ..quadraticBezierTo(
        center.dx + scale * 0.84,
        center.dy + scale * 0.56,
        handCenter.dx,
        handCenter.dy + scale * 0.08,
      );
    canvas.drawPath(
      armPath,
      Paint()
        ..color = teal
        ..style = PaintingStyle.stroke
        ..strokeWidth = scale * 0.24
        ..strokeCap = StrokeCap.round,
    );
    // Palm & thumb
    canvas.drawCircle(handCenter, scale * 0.15, Paint()..color = skin);
    canvas.drawCircle(
      handCenter.translate(-scale * 0.09, -scale * 0.03),
      scale * 0.065,
      Paint()..color = skin,
    );
  }

  /// Draws Maryam (مَرْيَم) in Duolingo flat-vector character style (inspired
  /// by Zari): warm berry-coral layered hijab with soft gold underscarf,
  /// golden star pin, big expressive Duolingo eyes, and waving hand.
  void _drawMaryam(
    Canvas canvas, {
    required Offset center,
    required double scale,
  }) {
    const skin = Color(0xFFF7C59F);
    const hijabMain = Color(0xFFE65368);
    const hijabDark = Color(0xFFC83E54);
    const underscarf = Color(0xFFFFE8A3);
    const gold = Color(0xFFFFB703);

    // Soft glowing circular badge behind Maryam
    canvas.drawCircle(
      center.translate(0, -scale * 0.04),
      scale * 1.12,
      Paint()..color = const Color(0xFFFEF3C7),
    );
    canvas.drawCircle(
      center.translate(0, -scale * 0.04),
      scale * 1.12,
      Paint()
        ..color = const Color(0xFFFCD34D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = scale * 0.05,
    );

    // Outer Hijab Shoulder Drape (rounded dome flowing to shoulders)
    final hijabOuter = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: center.translate(0, scale * 0.12),
        width: scale * 1.70,
        height: scale * 1.90,
      ),
      topLeft: Radius.circular(scale * 0.85),
      topRight: Radius.circular(scale * 0.85),
      bottomLeft: Radius.circular(scale * 0.58),
      bottomRight: Radius.circular(scale * 0.58),
    );
    canvas.drawRRect(hijabOuter, Paint()..color = hijabMain);

    // Hijab wrap fold across chest
    final wrapPath = Path()
      ..moveTo(center.dx - scale * 0.78, center.dy + scale * 0.50)
      ..quadraticBezierTo(
        center.dx,
        center.dy + scale * 0.84,
        center.dx + scale * 0.78,
        center.dy + scale * 0.46,
      )
      ..lineTo(center.dx + scale * 0.70, center.dy + scale * 0.94)
      ..quadraticBezierTo(
        center.dx,
        center.dy + scale * 1.08,
        center.dx - scale * 0.70,
        center.dy + scale * 0.94,
      )
      ..close();
    canvas.drawPath(wrapPath, Paint()..color = hijabDark);

    // Gold inner underscarf framing top of forehead
    final underRect = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: center.translate(0, -scale * 0.07),
        width: scale * 1.24,
        height: scale * 1.16,
      ),
      topLeft: Radius.circular(scale * 0.62),
      topRight: Radius.circular(scale * 0.62),
      bottomLeft: Radius.circular(scale * 0.54),
      bottomRight: Radius.circular(scale * 0.54),
    );
    canvas.drawRRect(underRect, Paint()..color = underscarf);

    // Face opening (warm rounded squircle)
    final faceRect = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: center.translate(0, scale * 0.03),
        width: scale * 1.22,
        height: scale * 1.08,
      ),
      topLeft: Radius.circular(scale * 0.56),
      topRight: Radius.circular(scale * 0.56),
      bottomLeft: Radius.circular(scale * 0.52),
      bottomRight: Radius.circular(scale * 0.52),
    );
    canvas.drawRRect(faceRect, Paint()..color = skin);

    // Golden Star Brooch on Maryam's hijab
    _drawFourPointStar(
      canvas,
      center.translate(scale * 0.56, -scale * 0.34),
      scale * 0.16,
      Paint()..color = gold,
    );
    canvas.drawCircle(
      center.translate(scale * 0.56, -scale * 0.34),
      scale * 0.04,
      Paint()..color = Colors.white,
    );

    _drawDuolingoFace(
      canvas,
      center: center.translate(0, scale * 0.06),
      scale: scale * 0.94,
    );

    // Connected waving arm + hand on left side
    final waveLift =
        (celebrating ? -scale * 0.16 : 0.0) -
        math.sin(phase * math.pi * 2) * scale * 0.07;
    final shoulder = center.translate(-scale * 0.56, scale * 0.64);
    final handCenter = center.translate(
      -scale * (0.86 + _waveAngle * 0.28),
      scale * 0.28 + waveLift,
    );
    final armPath = Path()
      ..moveTo(shoulder.dx, shoulder.dy)
      ..quadraticBezierTo(
        center.dx - scale * 0.84,
        center.dy + scale * 0.56,
        handCenter.dx,
        handCenter.dy + scale * 0.08,
      );
    canvas.drawPath(
      armPath,
      Paint()
        ..color = hijabMain
        ..style = PaintingStyle.stroke
        ..strokeWidth = scale * 0.23
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(handCenter, scale * 0.15, Paint()..color = skin);
    canvas.drawCircle(
      handCenter.translate(scale * 0.09, -scale * 0.03),
      scale * 0.062,
      Paint()..color = skin,
    );
  }

  /// Draws Duolingo-style expressive cartoon facial features:
  /// large white sclera eyes, dark glossy irises with double catchlights,
  /// blinking eyelids, cute button nose, rosy cheeks, and animated mouth.
  void _drawDuolingoFace(
    Canvas canvas, {
    required Offset center,
    required double scale,
  }) {
    const irisColor = Color(0xFF2B1E1A);
    const browColor = Color(0xFF3D251E);
    const noseShadow = Color(0xFFD99164);

    // Rosy Peach Cheeks
    final cheekPaint = Paint()
      ..color = const Color(0xFFFF8FA3).withValues(alpha: 0.62);
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(-scale * 0.38, scale * 0.14),
        width: scale * 0.26,
        height: scale * 0.15,
      ),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(scale * 0.38, scale * 0.14),
        width: scale * 0.26,
        height: scale * 0.15,
      ),
      cheekPaint,
    );

    final leftEyeCenter = center.translate(-scale * 0.25, -scale * 0.05);
    final rightEyeCenter = center.translate(scale * 0.25, -scale * 0.05);

    // Big Duolingo White Sclera Ovals in all moods (with animated blinking!)
    final eyeScale = celebrating ? 1.08 : 1.0;
    for (final eye in [leftEyeCenter, rightEyeCenter]) {
      final scleraRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: eye,
          width: scale * 0.29 * eyeScale,
          height: scale * 0.33 * eyeScale * (1.0 - _blinkAmount * 0.88),
        ),
        Radius.circular(scale * 0.15),
      );
      canvas.drawRRect(scleraRect, Paint()..color = Colors.white);

      if (_blinkAmount < 0.65) {
        // Large expressive pupil/iris
        final pupilCenter = eye.translate(scale * 0.015, scale * 0.01);
        canvas.drawCircle(
          pupilCenter,
          scale * 0.11 * eyeScale,
          Paint()..color = irisColor,
        );
        // Main glossy catchlight
        canvas.drawCircle(
          pupilCenter.translate(-scale * 0.036, -scale * 0.040),
          scale * 0.042 * eyeScale,
          Paint()..color = Colors.white,
        );
        // Secondary tiny sparkle
        canvas.drawCircle(
          pupilCenter.translate(scale * 0.034, scale * 0.034),
          scale * 0.020 * eyeScale,
          Paint()..color = Colors.white,
        );
      }
    }

    // Thick expressive Duolingo Eyebrows
    final browPaint = Paint()
      ..color = browColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = scale * 0.068
      ..strokeCap = StrokeCap.round;
    final browLift = celebrating ? -scale * 0.04 : 0.0;
    for (final entry in [leftEyeCenter, rightEyeCenter].indexed) {
      final eye = entry.$2;
      canvas.drawArc(
        Rect.fromCenter(
          center: eye.translate(0, -scale * 0.20 + browLift),
          width: scale * 0.28,
          height: scale * 0.11,
        ),
        math.pi + 0.28,
        math.pi - 0.56,
        false,
        browPaint,
      );
    }

    // Cute rounded button nose
    final noseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center.translate(0, scale * 0.07),
        width: scale * 0.11,
        height: scale * 0.08,
      ),
      Radius.circular(scale * 0.05),
    );
    canvas.drawRRect(noseRect, Paint()..color = noseShadow);

    // Mouth: animated D-shape with teeth & tongue when cheering/talking, or
    // warm curved smile when idle.
    final mouthCenter = center.translate(0, scale * 0.22);
    if (_mouthOpen > 0.15) {
      final openHeight = scale * (0.16 + 0.16 * _mouthOpen);
      final mouthPath = Path()
        ..moveTo(mouthCenter.dx - scale * 0.20, mouthCenter.dy - scale * 0.03)
        ..lineTo(mouthCenter.dx + scale * 0.20, mouthCenter.dy - scale * 0.03)
        ..quadraticBezierTo(
          mouthCenter.dx + scale * 0.20,
          mouthCenter.dy + openHeight,
          mouthCenter.dx,
          mouthCenter.dy + openHeight,
        )
        ..quadraticBezierTo(
          mouthCenter.dx - scale * 0.20,
          mouthCenter.dy + openHeight,
          mouthCenter.dx - scale * 0.20,
          mouthCenter.dy - scale * 0.03,
        )
        ..close();
      canvas.drawPath(mouthPath, Paint()..color = const Color(0xFF7F1D1D));

      // White upper teeth strip
      canvas.save();
      canvas.clipPath(mouthPath);
      canvas.drawRect(
        Rect.fromLTWH(
          mouthCenter.dx - scale * 0.22,
          mouthCenter.dy - scale * 0.04,
          scale * 0.44,
          scale * 0.08,
        ),
        Paint()..color = Colors.white,
      );
      // Pink tongue oval at bottom of mouth
      canvas.drawOval(
        Rect.fromCenter(
          center: mouthCenter.translate(0, openHeight * 0.85),
          width: scale * 0.26,
          height: scale * 0.16,
        ),
        Paint()..color = const Color(0xFFFB7185),
      );
      canvas.restore();
    } else {
      final smilePaint = Paint()
        ..color = const Color(0xFF6B2118)
        ..style = PaintingStyle.stroke
        ..strokeWidth = scale * 0.068
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCenter(
          center: mouthCenter.translate(0, -scale * 0.04),
          width: scale * 0.36,
          height: scale * 0.22,
        ),
        0.18,
        math.pi - 0.36,
        false,
        smilePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _YoungLearnerMascotPainter oldDelegate) {
    return oldDelegate.kind != kind ||
        oldDelegate.mood != mood ||
        oldDelegate.phase != phase ||
        oldDelegate.speaking != speaking;
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

class _PlaygroundWord {
  const _PlaygroundWord({
    required this.baseWord,
    required this.emoji,
    required this.harakat,
  });

  final String baseWord;
  final String emoji;
  final List<_HarakaOption> harakat;
}

class _QuickChallenge {
  const _QuickChallenge({
    required this.promptSentence,
    required this.targetWord,
    required this.correctHarakaIndex,
    required this.explanation,
  });

  final String promptSentence;
  final String targetWord;
  final int correctHarakaIndex;
  final String explanation;
}

/// An interactive mini-game card for Young Learners on the Home screen where
/// kids can switch words, tap the 3 harakat (الضمة / الفتحة / الكسرة) to
/// transform a word's ending live in a sentence, and play a quick star
/// challenge with Omar & Maryam!
class InteractiveHarakaPlayground extends StatefulWidget {
  const InteractiveHarakaPlayground({super.key});

  @override
  State<InteractiveHarakaPlayground> createState() =>
      _InteractiveHarakaPlaygroundState();
}

class _InteractiveHarakaPlaygroundState
    extends State<InteractiveHarakaPlayground> {
  static const List<_PlaygroundWord> _words = [
    _PlaygroundWord(
      baseWord: 'البَيْت',
      emoji: '🏠',
      harakat: [
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
      ],
    ),
    _PlaygroundWord(
      baseWord: 'الطَّالِب',
      emoji: '👦',
      harakat: [
        _HarakaOption(
          name: 'الضَّمَّة',
          mark: 'ـُ',
          wordWithMark: 'الطَّالِبُ',
          sentence: 'نَجَحَ الطَّالِبُ',
          story:
              'الضَّمَّةُ لأَنَّ «الطَّالِبُ» هُوَ الفَاعِلُ الَّذِي نَجَحَ!',
          badgeColor: Color(0xFF0E7490),
        ),
        _HarakaOption(
          name: 'الفَتْحَة',
          mark: 'ـَ',
          wordWithMark: 'الطَّالِبَ',
          sentence: 'شَكَرَ المُعَلِّمُ الطَّالِبَ',
          story: 'الفَتْحَةُ لأَنَّ الشُّكْرَ وَقَعَ عَلَى الطَّالِبِ!',
          badgeColor: Color(0xFFD97706),
        ),
        _HarakaOption(
          name: 'الكَسْرَة',
          mark: 'ـِ',
          wordWithMark: 'الطَّالِبِ',
          sentence: 'سَلَّمْتُ عَلَى الطَّالِبِ',
          story: 'الكَسْرَةُ لأَنَّ قَبْلَهَا حَرْفَ الجَرِّ «عَلَى»!',
          badgeColor: Color(0xFF059669),
        ),
      ],
    ),
    _PlaygroundWord(
      baseWord: 'الكِتَاب',
      emoji: '📖',
      harakat: [
        _HarakaOption(
          name: 'الضَّمَّة',
          mark: 'ـُ',
          wordWithMark: 'الكِتَابُ',
          sentence: 'الكِتَابُ مُفِيدٌ',
          story:
              'الضَّمَّةُ لأَنَّ الجُمْلَةَ بَدَأَتْ بِكَلِمَةِ «الكِتَابُ»!',
          badgeColor: Color(0xFF0E7490),
        ),
        _HarakaOption(
          name: 'الفَتْحَة',
          mark: 'ـَ',
          wordWithMark: 'الكِتَابَ',
          sentence: 'قَرَأَ عُمَرُ الكِتَابَ',
          story: 'الفَتْحَةُ لأَنَّ القِرَاءَةَ وَقَعَتْ عَلَى الكِتَابِ!',
          badgeColor: Color(0xFFD97706),
        ),
        _HarakaOption(
          name: 'الكَسْرَة',
          mark: 'ـِ',
          wordWithMark: 'الكِتَابِ',
          sentence: 'قَرَأْتُ فِي الكِتَابِ',
          story: 'الكَسْرَةُ لأَنَّ قَبْلَهَا حَرْفَ الجَرِّ «فِي»!',
          badgeColor: Color(0xFF059669),
        ),
      ],
    ),
  ];

  static const List<_QuickChallenge> _challenges = [
    _QuickChallenge(
      promptSentence: 'فِي البَيْتـ___ نُورٌ',
      targetWord: 'البَيْتِ',
      correctHarakaIndex: 2,
      explanation:
          'أَحْسَنْتَ! بَعْدَ «فِي» نَضَعُ الكَسْرَةَ (ـِ): فِي البَيْتِ!',
    ),
    _QuickChallenge(
      promptSentence: 'الطَّالِبـ___ مُجْتَهِدٌ',
      targetWord: 'الطَّالِبُ',
      correctHarakaIndex: 0,
      explanation:
          'رَائِع! الكَلِمَةُ فِي أَوَّلِ الجُمْلَةِ تَأْخُذُ الضَّمَّةَ (ـُ)!',
    ),
    _QuickChallenge(
      promptSentence: 'قَرَأَتْ مَرْيَمُ الكِتَابـ___',
      targetWord: 'الكِتَابَ',
      correctHarakaIndex: 1,
      explanation:
          'بَطَل! المَفْعُولُ بِهِ يَأْخُذُ الفَتْحَةَ (ـَ): الكِتَابَ!',
    ),
  ];

  static const List<String> _mascotCheers = [
    'مَرْحَبًا! أَنَا عُمَر وَهَذِهِ مَرْيَم — اضْغَطْ عَلَى الحَرَكَاتِ لِتَرَى كَيْفَ تَتَغَيَّرُ الكَلِمَةُ!',
    'يَقُولُ عُمَر: آخِرُ الكَلِمَةِ يَتَغَيَّرُ حَسَبَ مَكَانِهَا فِي الجُمْلَةِ!',
    'تَقُولُ مَرْيَم: أَنْتَ نَجْمُ الإِعْرَابِ الصَّغِير! جَرِّبْ تَحَدِّي النُّجُومِ!',
  ];

  int _selectedWordIndex = 0;
  int _selectedHarakaIndex = 0;
  int _cheerIndex = 0;
  bool _hasInteracted = false;
  bool _challengeMode = false;
  int _challengeIndex = 0;
  int _starsEarned = 0;
  bool? _challengeCorrect;

  void _speakActiveHaraka(_HarakaOption active) {
    final w = active.wordWithMark;
    final s = active.sentence;
    final story = active.story;
    ArabicSpeechHelper.instance.speak('$w، $s، $story');
  }

  void _selectWord(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedWordIndex = index;
      _hasInteracted = true;
    });
    _speakActiveHaraka(_words[index].harakat[_selectedHarakaIndex]);
  }

  void _selectHaraka(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedHarakaIndex = index;
      _hasInteracted = true;
      if (_challengeMode) {
        final challenge = _challenges[_challengeIndex];
        if (index == challenge.correctHarakaIndex) {
          _challengeCorrect = true;
          _starsEarned = (_starsEarned + 1).clamp(0, 99);
          ArabicSpeechHelper.instance.speak(challenge.explanation);
        } else {
          _challengeCorrect = false;
          ArabicSpeechHelper.instance.speak(
            'حَاوِلْ مَرَّةً أُخْرَى يَا بَطَل! انْظُرْ إِلَى مَا قَبْلَ الكَلِمَةِ',
          );
        }
      } else {
        _speakActiveHaraka(_words[_selectedWordIndex].harakat[index]);
      }
    });
  }

  String _challengeFullSentence(_HarakaChallenge challenge) {
    return challenge.promptSentence.replaceAll(
      RegExp(r'[^\s]+___'),
      challenge.targetWord,
    );
  }

  void _speakCurrentCard() {
    if (_challengeMode) {
      final challenge = _challenges[_challengeIndex];
      ArabicSpeechHelper.instance.speak(_challengeFullSentence(challenge));
      return;
    }
    _speakActiveHaraka(
      _words[_selectedWordIndex].harakat[_selectedHarakaIndex],
    );
  }

  void _nextChallenge() {
    HapticFeedback.selectionClick();
    setState(() {
      _challengeIndex = (_challengeIndex + 1) % _challenges.length;
      _challengeCorrect = null;
    });
    final challenge = _challenges[_challengeIndex];
    ArabicSpeechHelper.instance.speak(_challengeFullSentence(challenge));
  }

  void _toggleChallengeMode() {
    HapticFeedback.selectionClick();
    setState(() {
      _challengeMode = !_challengeMode;
      _challengeCorrect = null;
      _hasInteracted = true;
    });
    _speakCurrentCard();
  }

  void _cycleCheer() {
    setState(() {
      _cheerIndex = (_cheerIndex + 1) % _mascotCheers.length;
      _hasInteracted = true;
    });
    _speakCurrentCard();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final learningColors = Theme.of(context).extension<LearningColors>()!;
    final currentWord = _words[_selectedWordIndex];
    final active = currentWord.harakat[_selectedHarakaIndex];
    final challenge = _challenges[_challengeIndex];

    final mood = _challengeMode
        ? (_challengeCorrect == null
              ? MascotMood.thinking
              : (_challengeCorrect!
                    ? MascotMood.cheering
                    : MascotMood.encouraging))
        : (_hasInteracted ? MascotMood.cheering : MascotMood.happy);

    final statusMessage = _challengeMode
        ? (_challengeCorrect == null
              ? 'تَحَدِّي عُمَر وَمَرْيَم: أَيُّ حَرَكَةٍ تُكْمِلُ الجُمْلَةَ؟ 🤔'
              : (_challengeCorrect!
                    ? challenge.explanation
                    : 'حَاوِلْ مَرَّةً أُخْرَى يَا بَطَل! انْظُرْ إِلَى مَا قَبْلَ الكَلِمَةِ 💪'))
        : (_hasInteracted ? active.story : _mascotCheers[_cheerIndex]);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: learningColors.sunshineContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: scheme.tertiary.withValues(alpha: 0.48),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.tertiary.withValues(alpha: 0.22),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              YoungLearnerMascot(
                kind: CartoonCharacterKind.duo,
                size: 78,
                mood: mood,
                speaking: _hasInteracted,
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
                            'اكْتَشِفِ الحَرَكَاتِ مَعَ عُمَر وَمَرْيَم',
                            style: textTheme.titleSmall?.copyWith(
                              color: learningColors.onSunshineContainer,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (_starsEarned > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '⭐ $_starsEarned',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: scheme.outlineVariant.withValues(alpha: 0.7),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ArabicDiacriticsText(
                              statusMessage,
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: _speakCurrentCard,
                            borderRadius: BorderRadius.circular(999),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.volume_up_rounded,
                                size: 20,
                                color: scheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (!_challengeMode)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final entry in _words.indexed)
                      ChoiceChip(
                        selected: _selectedWordIndex == entry.$1,
                        label: Text('${entry.$2.emoji} ${entry.$2.baseWord}'),
                        onSelected: (_) => _selectWord(entry.$1),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ActionChip(
                avatar: Icon(
                  _challengeMode
                      ? Icons.explore_rounded
                      : Icons.sports_esports_rounded,
                  size: 18,
                ),
                label: Text(_challengeMode ? 'استكشاف' : 'تحدّي النجوم 🎯'),
                onPressed: _toggleChallengeMode,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _speakCurrentCard,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.65),
                  width: 1.5,
                ),
              ),
              child: _challengeMode
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ArabicDiacriticsText(
                            _challengeCorrect == true
                                ? challenge.promptSentence.replaceAll(
                                    RegExp(r'[^\s]+___'),
                                    challenge.targetWord,
                                  )
                                : challenge.promptSentence,
                            textAlign: TextAlign.center,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: _challengeCorrect == true
                                  ? const Color(0xFF059669)
                                  : scheme.onSurface,
                            ),
                          ),
                        ),
                        if (_challengeCorrect == true)
                          TextButton.icon(
                            onPressed: _nextChallenge,
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              size: 18,
                            ),
                            label: const Text('التالي'),
                          ),
                      ],
                    )
                  : Row(
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
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final entry in currentWord.harakat.indexed) ...[
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
    final borderColor = selected
        ? option.badgeColor
        : option.badgeColor.withValues(alpha: 0.45);
    return Material(
      color: selected ? option.badgeColor : scheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: selected ? 0.55 : 0.28),
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
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

/// A Duolingo-style character + speech-bubble header where Omar (`عُمَر`) or
/// Maryam (`مَرْيَم`) stands beside a 3D bordered speech bubble with a pointer
/// tail and an audio speaker button.
class DuolingoCharacterHeader extends StatefulWidget {
  const DuolingoCharacterHeader({
    required this.character,
    required this.speakerName,
    required this.message,
    this.mood = MascotMood.happy,
    this.speechText,
    this.trailing,
    this.onTap,
    super.key,
  });

  final CartoonCharacterKind character;
  final String speakerName;
  final String message;
  final MascotMood mood;
  final String? speechText;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  State<DuolingoCharacterHeader> createState() =>
      _DuolingoCharacterHeaderState();
}

class _DuolingoCharacterHeaderState extends State<DuolingoCharacterHeader> {
  bool _speaking = false;

  Future<void> _speak() async {
    HapticFeedback.selectionClick();
    setState(() => _speaking = true);
    await ArabicSpeechHelper.instance.speak(
      widget.speechText ?? widget.message,
    );
    if (!mounted) return;
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() => _speaking = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accentColor = widget.character == CartoonCharacterKind.girl
        ? const Color(0xFFBE185D)
        : const Color(0xFF0E7490);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        YoungLearnerMascot(
          kind: widget.character,
          size: 86,
          mood: widget.mood,
          speaking: _speaking,
          onTap: () {
            widget.onTap?.call();
            _speak();
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: InkWell(
            onTap: () {
              widget.onTap?.call();
              _speak();
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.45),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.18),
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.volume_up_rounded,
                      size: 22,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.speakerName,
                          style: textTheme.labelMedium?.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        ArabicDiacriticsText(
                          widget.message,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.trailing != null) ...[
                    const SizedBox(width: 6),
                    widget.trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Interactive companion header shown on questions in Young Learner mode.
/// Kids can tap Omar & Maryam to reveal/cycle a friendly grammar clue, hear it
/// spoken aloud, and watch the character react with cheering or encouragement
/// when an answer is checked.
class InteractiveQuestionCompanion extends StatefulWidget {
  const InteractiveQuestionCompanion({
    required this.hint,
    required this.answerChecked,
    required this.isCorrect,
    this.questionPrompt,
    super.key,
  });

  final String hint;
  final bool answerChecked;
  final bool isCorrect;
  final String? questionPrompt;

  @override
  State<InteractiveQuestionCompanion> createState() =>
      _InteractiveQuestionCompanionState();
}

class _InteractiveQuestionCompanionState
    extends State<InteractiveQuestionCompanion> {
  bool _showTipBubble = false;
  bool _speaking = false;

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

  Future<void> _handleTap() async {
    HapticFeedback.selectionClick();
    final nextShowTip = !_showTipBubble;
    setState(() {
      _showTipBubble = nextShowTip;
      _speaking = true;
    });
    final textToSpeak = widget.answerChecked
        ? _bubbleText
        : (nextShowTip ? widget.hint : (widget.questionPrompt ?? widget.hint));
    await ArabicSpeechHelper.instance.speak(textToSpeak);
    if (!mounted) return;
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _speaking = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final learningColors = Theme.of(context).extension<LearningColors>()!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: learningColors.sunshineContainer,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: scheme.tertiary.withValues(alpha: 0.48),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.tertiary.withValues(alpha: 0.22),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            YoungLearnerMascot(
              kind: CartoonCharacterKind.duo,
              size: 74,
              mood: _mood,
              speaking: _speaking,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.65),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.volume_up_rounded,
                      size: 20,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ArabicDiacriticsText(
                        _bubbleText,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _showTipBubble
                          ? Icons.lightbulb_rounded
                          : Icons.lightbulb_outline_rounded,
                      color: const Color(0xFFD97706),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
