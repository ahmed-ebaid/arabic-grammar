import 'package:flutter/material.dart';

class ArabicDiacriticsText extends StatelessWidget {
  const ArabicDiacriticsText(
    this.data, {
    this.style,
    this.textAlign,
    this.textDirection,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.textWidthBasis,
    super.key,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final TextWidthBasis? textWidthBasis;

  @override
  Widget build(BuildContext context) {
    final formatted = makeArabicDiacriticsVisible(data);
    final effectiveStyle = style ?? DefaultTextStyle.of(context).style;
    final markStyle = effectiveStyle.copyWith(
      color: Theme.of(context).colorScheme.primary,
      fontSize: (effectiveStyle.fontSize ?? 14) + 6,
      fontWeight: FontWeight.w700,
    );
    final spans = <InlineSpan>[];
    final marks = RegExp(r'ـ[\u064B-\u0652\u0670]+');
    var offset = 0;

    for (final match in marks.allMatches(formatted)) {
      if (match.start > offset) {
        spans.add(TextSpan(text: formatted.substring(offset, match.start)));
      }
      final mark = match.group(0)!.substring(1);
      if (_drawnMarks.contains(mark)) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: HarakaGlyph(mark: mark, color: markStyle.color!),
          ),
        );
      } else {
        spans.add(TextSpan(text: match.group(0), style: markStyle));
      }
      offset = match.end;
    }
    if (offset < formatted.length) {
      spans.add(TextSpan(text: formatted.substring(offset)));
    }

    return Text.rich(
      TextSpan(children: spans),
      style: style,
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textWidthBasis: textWidthBasis,
    );
  }
}

String makeArabicDiacriticsVisible(String text) {
  final withSeparatedMarks = text.replaceAllMapped(
    RegExp(r':\s*([\u064B-\u0652\u0670]+)'),
    (match) => ' (ـ${match[1]})',
  );
  final runes = withSeparatedMarks.runes.toList(growable: false);
  final output = StringBuffer();

  for (var index = 0; index < runes.length; index++) {
    final rune = runes[index];
    if (_isArabicDiacritic(rune) &&
        (index == 0 ||
            (!_isArabicLetter(runes[index - 1]) &&
                runes[index - 1] != 0x0640 &&
                !_isArabicDiacritic(runes[index - 1])))) {
      output.writeCharCode(0x0640);
    }
    output.writeCharCode(rune);
  }
  return output.toString();
}

bool _isArabicDiacritic(int rune) =>
    (rune >= 0x064B && rune <= 0x0652) || rune == 0x0670;

bool _isArabicLetter(int rune) =>
    (rune >= 0x0621 && rune <= 0x064A) ||
    (rune >= 0x066E && rune <= 0x06D3) ||
    (rune >= 0x06FA && rune <= 0x06FC);

const _drawnMarks = {
  '\u064B', // fathatan (ً)
  '\u064C', // dammatan (ٌ)
  '\u064D', // kasratan (ٍ)
  '\u064E', // fatha (َ)
  '\u064F', // damma (ُ)
  '\u0650', // kasra (ِ)
  '\u0652', // sukun (ْ)
};

/// Draws a short vowel, tanween, or sukun over a base stroke so it stays
/// legible regardless of the platform font's mark glyphs.
class HarakaGlyph extends StatelessWidget {
  const HarakaGlyph({required this.mark, required this.color, super.key});

  final String mark;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 36,
      child: CustomPaint(painter: _HarakaPainter(mark, color)),
    );
  }
}

class _HarakaPainter extends CustomPainter {
  _HarakaPainter(this.mark, this.color);

  final String mark;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    final baseY = size.height * 0.5;
    canvas.drawLine(Offset(cx - 10, baseY), Offset(cx + 10, baseY), stroke);

    switch (mark) {
      case '\u064E':
        canvas.drawLine(
          Offset(cx - 6, baseY - 6),
          Offset(cx + 6, baseY - 11),
          stroke..strokeWidth = 2,
        );
      case '\u064B':
        stroke.strokeWidth = 2;
        canvas.drawLine(
          Offset(cx - 6, baseY - 9.5),
          Offset(cx + 6, baseY - 14.5),
          stroke,
        );
        canvas.drawLine(
          Offset(cx - 6, baseY - 4.5),
          Offset(cx + 6, baseY - 9.5),
          stroke,
        );
      case '\u0650':
        canvas.drawLine(
          Offset(cx - 6, baseY + 11),
          Offset(cx + 6, baseY + 6),
          stroke..strokeWidth = 2,
        );
      case '\u064D':
        stroke.strokeWidth = 2;
        canvas.drawLine(
          Offset(cx - 6, baseY + 9.5),
          Offset(cx + 6, baseY + 4.5),
          stroke,
        );
        canvas.drawLine(
          Offset(cx - 6, baseY + 14.5),
          Offset(cx + 6, baseY + 9.5),
          stroke,
        );
      case '\u064F':
        _paintDamma(canvas, cx, baseY - 10);
      case '\u064C':
        _paintSmallDamma(canvas, cx - 4.5, baseY - 10);
        _paintSmallDamma(canvas, cx + 4.5, baseY - 10);
      case '\u0652':
        canvas.drawCircle(Offset(cx, baseY - 9), 4, stroke..strokeWidth = 1.8);
    }
  }

  void _paintDamma(Canvas canvas, double centerX, double loopY) {
    final loopStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final tailStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + 1, loopY),
        width: 4.5,
        height: 3.5,
      ),
      loopStroke,
    );
    canvas.drawPath(
      Path()
        ..moveTo(centerX + 3.25, loopY)
        ..cubicTo(
          centerX + 7,
          loopY + 4,
          centerX + 2,
          loopY + 6,
          centerX - 4,
          loopY + 6,
        ),
      tailStroke,
    );
  }

  void _paintSmallDamma(Canvas canvas, double centerX, double loopY) {
    final loopStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final tailStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + 0.8, loopY),
        width: 3.8,
        height: 3.0,
      ),
      loopStroke,
    );
    canvas.drawPath(
      Path()
        ..moveTo(centerX + 2.7, loopY)
        ..cubicTo(
          centerX + 5.2,
          loopY + 3.5,
          centerX + 1.5,
          loopY + 5.2,
          centerX - 3.2,
          loopY + 5.2,
        ),
      tailStroke,
    );
  }

  @override
  bool shouldRepaint(_HarakaPainter old) =>
      old.mark != mark || old.color != color;
}
